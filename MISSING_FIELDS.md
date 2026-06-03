# Cashora — Missing Backend Fields & Endpoints

> Generated: 2026-05-25
> Scope: only fields/endpoints the frontend reads but backend does not currently send (or sends inconsistently). Working endpoints are intentionally NOT listed.
>
> Format per item: **endpoint → what's missing → exact JSON shape backend should return → where frontend uses it.**

---

## ⚡ TL;DR — what's actually broken right now

1. **Accountant dashboard opening balance doesn't reflect updates from "Manage Balances".**
   - `GET /accountant/dashboard` is returning a different `opening_balance` than `GET /accountant/balance`. The two endpoints must share the same data source.
2. **Accountant dashboard "closing balance" is always wrong / missing.**
   - Backend either doesn't send `closing_balance`, or sends it as `opening − amount_out`. The frontend currently computes it the same way, masking the bug. Backend should send the **actual** closing (opening + amount_in − amount_out).
3. **Completed payment "Paid date" === "Requested date".**
   - Backend is not sending `paid_at` on the completed-payments payload. Frontend falls back to `created_at`, so both dates render identically.
4. **Admin request details: "Approved on" / "Rejected on" / "Paid on" dates are missing.**
   - Backend only sends `created_at` and `updated_at`. Frontend uses `updated_at` as a proxy for the approval/rejection timestamp, which is fragile and incorrect once the record is touched again.

---

# 1. Accountant Flow

## 1.1 `GET /accountant/dashboard` — opening/closing balance not in sync with `/accountant/balance`

**Bug:** After accountant updates today's opening balance via `POST /accountant/balance`, the dashboard tile (top of accountant home) keeps showing the previous value.

**Root cause (backend side):** `/accountant/dashboard` is reading `opening_balance` from a different source than `/accountant/balance`. Both endpoints must hit the **same** daily balance row.

**Required response shape:**
```json
{
  "user": { "shortName": "Sai" },
  "accountOverview": {
    "openBalance": 100000.00,        // === GET /accountant/balance.opening_balance for TODAY
    "closingBalance": 84292.00,      // === GET /accountant/balance.closing_balance for TODAY
                                     // ⚠ Send this directly. Do NOT rely on frontend to compute.
    "amountIn": 0.00,
    "amountOut": 15708.00,
    "inHandCash": 84292.00,          // = openBalance + amountIn − amountOut
    "inHandCashGrowth": "+2.4%"      // optional, displayed as growth chip on home
  },
  "tasksSummary": {
    "pendingPaymentsCount": 3
  },
  "todayTransactions": [
    {
      "id": "EXP-...",
      "title": "Office supplies",
      "subtitle": "Stationery",
      "vendor_name": "Staples",
      "timestamp": "2026-05-25T09:15:00",   // ISO8601 server-local (no Z)
      "amount": 4500.00,
      "icon_type": "office_supplies"
    }
  ]
}
```

**Frontend usage:**
- `accountant_home_view.dart` → in-hand card + open/closing balance row + today's txn list.

---

## 1.2 `GET /accountant/balance` — current snapshot

**Status:** endpoint exists. Just need to confirm the **full** shape and the field names below.

**Required response shape (today's row):**
```json
{
  "date": "2026-05-25",                   // YYYY-MM-DD
  "opening_balance": 100000.00,
  "closing_balance": 84292.00,            // actual closing = opening + in − out
  "amount_in": 0.00,
  "amount_out": 15708.00,
  "last_updated_at": "2026-05-25T11:42:00",
  "note": "Vendor payouts for ABC",
  "updated_by": "Sai Kumar"               // optional, displayed in history
}
```

**Frontend usage:**
- `manage_balances_controller.dart::fetchCurrent()` → summary card + mini-stats (In / Out) + note box + date badge.

---

## 1.3 `POST /accountant/balance` — set balance

**Status:** endpoint exists. Confirming exact contract.

**Request body sent by frontend:**
```json
{
  "openingBalance": 120000.00,
  "closingBalance": 95000.00,   // optional
  "note": "Adjusted for petty cash refill",  // optional
  "date": "2026-05-25"           // optional, defaults to today
}
```

**Required response:** same shape as `GET /accountant/balance` (the freshly-saved row), so the form can re-seed.

**⚠ Important side effect:** after this POST, `GET /accountant/dashboard` MUST return the updated `opening_balance` / `closing_balance`. Today it does not.

---

## 1.4 `GET /accountant/balance/history` — past snapshots

**Required response shape (list, newest first):**
```json
[
  {
    "date": "2026-05-25",
    "opening_balance": 100000.00,
    "closing_balance": 84292.00,
    "amount_in": 0.00,
    "amount_out": 15708.00,
    "updated_by": "Sai Kumar",
    "updated_at": "2026-05-25T11:42:00",
    "note": "Vendor payouts for ABC"
  },
  { "date": "2026-05-24", "...": "..." }
]
```

**Frontend usage:**
- `manage_balances_view.dart` → history list rows.

---

## 1.5 `GET /accountant/expenses/paid` — completed payments list

**Bug:** opening any completed request shows "Paid date" == "Requested date" because backend isn't sending `paid_at`.

**Required fields per item (add the ones marked ⛔ MISSING):**
```json
{
  "id": 77,
  "request_id": "EXP-77BD1000",
  "amount": 4500.00,
  "purpose": "...",
  "description": "...",
  "category": "office_supplies",
  "department": "Operations",
  "status": "approved",
  "payment_status": "paid",

  "created_at": "2026-05-20T09:15:00",     // ✅ already sent — "Requested on"

  "approved_at": "2026-05-21T10:00:00",    // ⛔ MISSING — "Approved on" in completed details
  "paid_at":     "2026-05-22T14:30:00",    // ⛔ MISSING — "Paid on" in completed details
                                            //   (today frontend falls back to created_at,
                                            //   making paid date === requested date)

  "payment_method": "UPI",                  // ⛔ often null — needed for payment card chip
  "transaction_reference": "TXN1234567",    // ⛔ often null — needed for payment card row

  "requestor": {                            // already sent, confirm shape
    "first_name": "Asha",
    "last_name":  "Rao",
    "email":      "asha@..."
  },

  "audit_trail": [                          // ⛔ MISSING — optional but used if present
    {
      "action": "submitted",   // submitted | approved | clarification_asked | clarification_responded | paid | rejected
      "actor":  "Asha Rao",
      "at":     "2026-05-20T09:15:00",
      "note":   "optional"
    }
  ]
}
```

**Frontend usage:**
- `completed_request_details_view.dart` line 79 — `paid_at ?? payment_date ?? created_at`. Backend must send `paid_at`.

---

## 1.6 `GET /accountant/expenses/pending-payments` — pending payments list

**Required fields per item (add the ones marked ⛔ MISSING):**
```json
{
  "id": 80,
  "request_id": "EXP-80AB...",
  "amount": 7200.00,
  "purpose": "...",
  "description": "...",
  "category": "travel",
  "department": "Sales",
  "status": "approved",
  "payment_status": "pending",

  "created_at":  "2026-05-23T09:00:00",    // "Requested on"
  "approved_at": "2026-05-24T16:00:00",    // ⛔ MISSING — "Approved on" in pending bill view

  "payment_qr_url":  "https://.../qr.png",  // already sent if QR exists
  "receipt_url":     null,                  // null until receipt uploaded
  "requestor": { "first_name": "...", "last_name": "...", "email": "..." }
}
```

**Frontend usage:**
- `bill_details_view.dart` (pending payment) — currently does not show approved_at because backend doesn't send it. Add the field so the pending-payment screen can show "Approved on …".

---

## 1.7 `GET /accountant/analytics/spend` — already audited, confirm shape

Backend currently sends:
```json
{ "total": 56000, "by_period": [...], "by_department": [...], "by_category": {...} }
```

**Required addition:**
- `by_period[]` items must include `year`, `month`, `total` (currently OK).
- `by_department[]` items must include `department` (name) and `total`.
- `by_category` must be a flat `{ "office_supplies": 4500, ... }` map.

No new fields needed here, just confirming the contract.

---

# 2. Admin Flow

## 2.1 `GET /approver/org-expenses` — list of requests (all tabs)

**Bug:** Request detail screens show **submitted date** correctly (`created_at`), but **approved date / rejected date / paid date** are missing or fall back to `updated_at`, which mutates on any record change.

**Required fields per item (mark ⛔ as MISSING, ✅ as already sent):**
```json
{
  "id": 77,                                 // ✅ numeric, used for API calls
  "request_id": "EXP-77BD1000",             // ✅ display id
  "title":   "Stationery",                  // ✅ or use purpose
  "purpose": "Stationery for Q2",           // ✅
  "description": "...",                     // ✅
  "category": "office_supplies",            // ✅
  "request_type": "expense",                // ✅
  "amount": 4500.00,                        // ✅

  "status": "approved",                     // ✅ — see 2.6 for allowed values
  "payment_status": "pending",              // ✅ pending | paid

  "department": "Operations",               // ✅ flat string (preferred)

  "requestor": {                            // ✅ confirm always present
    "first_name": "Asha",
    "last_name":  "Rao",
    "email":      "asha@..."
  },

  "created_at":  "2026-05-20T09:15:00",     // ✅ "Submitted on" / "Requested on"

  "approved_at": "2026-05-21T10:00:00",     // ⛔ MISSING — needed on approved/unpaid/paid cards
  "rejected_at": null,                      // ⛔ MISSING — needed on rejected card
  "paid_at":     "2026-05-22T14:30:00",     // ⛔ MISSING — needed on unpaid→paid transition

  "rejection_reason": null,                 // ✅ when rejected
  "admin_remarks":    null                  // ✅ optional, alternative key

  // ⚠ DO NOT use `updated_at` as the timestamp for these. updated_at changes
  //   on ANY edit (e.g. when a clarification thread is updated), and the
  //   frontend is currently misusing it as "approved/rejected on".
}
```

**Frontend usage:**
- `admin_approvals_view.dart::_buildCard()` → card date chip reads `date ?? created_at`.
- `request_details_layout.dart` → renders timeline using `created_at` + `updated_at`. After backend adds the explicit timestamps, frontend will switch to using them.
- `admin_request_details_view.dart` → same.

---

## 2.2 `GET /admin/dashboard` — counts & summary

**Required response shape (snake_case OR camelCase — pick ONE and stick with it):**
```json
{
  "user": { "shortName": "Admin" },
  "overview": {
    "pendingRequestsCount": 12,
    "inClarificationCount": 4,                // ⚠ FRONTEND TRIES BOTH camelCase AND snake_case
                                              //   ("in_clarification_count"). Pick one canonical
                                              //   key and remove the other.
    "approvedAmount": 234500.00
  },
  "departmentSummary": {
    "totalDepartments": 8,
    "activeDepartments": 7,
    "unassignedUsers": 2
  }
}
```

**Frontend usage:**
- `admin_dashboard_view.dart` → top stat tiles (Pending / In Clarification / Departments).

---

## 2.3 `GET /approver/dashboard-stats` — approver mini stats

**Required:**
```json
{
  "pending_count": 12,
  "total_approved_amount": 234500.00
}
```
Already sent. No changes needed — listed only because the frontend uses it.

---

## 2.4 `GET /approver/history/{expense_id}` — clarification thread

**Bug:** Several wrapper-key shapes are tried by the frontend (`history`, `clarifications`, `data`, `items`, `results`). Pick **one** and document it.

**Required response (preferred — raw list at top level):**
```json
[
  {
    "id": 1,
    "question":     "Please attach the GST invoice.",
    "asked_by":     "Admin",
    "asked_at":     "2026-05-21T10:00:00",
    "response":     "Attached.",                  // empty string until requestor replies
    "responded_by": "Asha Rao",
    "responded_at": "2026-05-21T13:30:00"         // empty until reply
  }
]
```

**⚠ Important:** the frontend builds the chat bubbles from `asked_at` / `responded_at`. Both must be ISO8601 server-local. Empty string (not null) is OK for the unanswered case.

**Frontend usage:**
- `admin_clarification_status_controller.dart` → `clarifications` rx list.

---

## 2.5 `GET /admin/users` (or `/admin/users/list`) — user management list

**Required fields per user:**
```json
{
  "id": 12,
  "full_name": "Sai Kumar",                  // ⛔ if not present, frontend concats first_name + last_name
  "first_name": "Sai",
  "last_name":  "Kumar",
  "email":      "sai@...",
  "role":       "requestor",                 // requestor | accountant | admin | super_admin
  "is_active":  true,
  "department": { "id": 3, "name": "Ops" }   // can be flat string OR nested object — pick one
}
```

**Frontend usage:**
- `admin_user_list_view.dart::_buildUserCard()` — name, role badge, email, dept chip, active state.

---

## 2.6 Status string canonical values

Backend currently mixes casing on some statuses. Lock these in:

| Frontend expects (lowercase) | Meaning |
|---|---|
| `pending` | newly submitted, awaiting admin |
| `approved` | admin approved, payment pending |
| `auto_approved` | rule-based auto approval (rendered as APPROVED in UI) |
| `rejected` | admin rejected |
| `clarification` | admin asked, requestor not yet responded |
| `clarification_responded` | requestor replied, awaiting admin re-review |

And for `payment_status`: `pending` or `paid` only.

---

# 3. Cross-Cutting Requirements

## 3.1 Date/time format — IST, no timezone suffix

All ISO8601 datetimes should be **server-local (IST), without a `Z` suffix**:

```
✅ "2026-05-25T14:30:00"
❌ "2026-05-25T14:30:00Z"          (will be re-interpreted as UTC → shows as 8:00 PM)
❌ "2026-05-25T14:30:00+05:30"     (works but inconsistent with rest of API)
```

Date-only fields (no time): `YYYY-MM-DD`.

The frontend (`lib/utils/date_helper.dart::_parseUtcThenLocal`) treats naive timestamps as already-local. If backend sends `Z`-suffixed UTC, every timestamp in the app will display 5h 30m off.

## 3.2 Numeric fields

- Money: numeric (not string). `4500.00`, not `"4500.00"`.
- IDs: numeric for API calls (`id`); separate `request_id` string for display (`"EXP-77BD1000"`).

## 3.3 Null vs empty string

For optional text fields the app reads (`note`, `description`, `rejection_reason`, `transaction_reference`, `payment_method`, …):
- `null` is fine — frontend treats it as "absent".
- Avoid the string `"null"`.

---

# 4. Backend Checklist (paste this into the ticket)

### Accountant
- [ ] `/accountant/dashboard` `accountOverview.openBalance` reads from the **same** row as `/accountant/balance` (today's snapshot).
- [ ] `/accountant/dashboard` returns `accountOverview.closingBalance` as the **actual** closing (opening + amount_in − amount_out), not the same value as `openBalance`.
- [ ] `/accountant/balance` returns: `date, opening_balance, closing_balance, amount_in, amount_out, last_updated_at, note, updated_by`.
- [ ] `/accountant/balance/history` returns list with the same fields per row.
- [ ] After `POST /accountant/balance`, the very next call to `GET /accountant/dashboard` reflects the new values.
- [ ] `/accountant/expenses/paid` items include `approved_at` and `paid_at` (not just `created_at`/`updated_at`).
- [ ] `/accountant/expenses/paid` items include `payment_method` and `transaction_reference` when known.
- [ ] `/accountant/expenses/pending-payments` items include `approved_at`.

### Admin
- [ ] `/approver/org-expenses` items include `approved_at`, `rejected_at`, `paid_at` (in addition to `created_at`).
- [ ] Stop relying on `updated_at` as a proxy for the approval timestamp.
- [ ] `/admin/dashboard` `overview` uses a single casing convention. Pick `inClarificationCount` (camelCase) and drop `in_clarification_count`.
- [ ] `/approver/history/{id}` returns a raw list at the top level (not wrapped in `history`/`clarifications`/`data`/`items`/`results`).
- [ ] `/approver/history/{id}` items include `asked_at` AND `responded_at` (both ISO8601, empty string when not yet responded).
- [ ] `/admin/users` items include `full_name` OR consistently `first_name` + `last_name`, plus `role`, `is_active`, and `department` as `{id, name}`.

### Cross-cutting
- [ ] All ISO8601 timestamps are **server-local IST, no `Z` suffix, no offset**.
- [ ] Money fields are numbers, not strings.
- [ ] Numeric `id` and string `request_id` both present on every expense.

---

**End of main spec.** Frontend will switch over to the explicit `approved_at` / `rejected_at` / `paid_at` fields the moment backend starts sending them; today's `updated_at` fallback will be removed.

---

# Appendix A — Accountant home "Today's Transactions"

> Added on 2026-05-25. Two new endpoints are needed.
>
> **The bug today**: the accountant home shows a "Today's Transactions" list under the dashboard header. The data comes from the existing `GET /accountant/dashboard` response (`todayTransactions[]`), but:
> 1. Each transaction row is missing several display fields (vendor, timestamp text, status, navigable id) so it renders almost empty.
> 2. The "View All" link currently navigates to a generic monthly-report screen, **not** the full today list.
> 3. Tapping a transaction does **nothing** — there's no detail endpoint.

We need **(1)** an enriched payload on the dashboard so the inline list looks complete, **(2)** a dedicated "View All today" endpoint, and **(3)** a per-transaction detail endpoint for tap-to-details.

---

## A.1 — `GET /accountant/dashboard` → enrich `todayTransactions[]`

The list block on the home screen currently shows: icon, title, subtitle, amount. That's it. Add the fields below so each row is informative AND tappable.

**Required response shape per row in `todayTransactions[]`:**
```json
{
  "id": 106,                                // ⛔ MUST be the numeric DB id (used for tap → detail fetch)
  "request_id": "EXP-0E3247D9",             // ⛔ string id (used for the "Request ID" subtitle line)

  "title": "Office Supplies",               // ✅ category display name OR purpose summary
  "subtitle": "Stationery for Q2",          // ✅ short purpose / description preview
  "icon_type": "office_supplies",           //   one of: office_supplies | travel | meals | software | hardware | other

  "vendor_name": "Staples",                 // ⛔ vendor / payee — currently null on every row
  "department": "Operations",               // ⛔ requestor's department, for the row's slate line

  "timestamp": "2026-05-25T11:42:00",       // ⛔ server-local ISO8601, no Z — used to render "11:42 AM"
                                            //   today only (the home screen filters server-side)

  "amount": 4500.00,                        // ✅ already sent; signed (negative for outflow / payout,
                                            //   positive for inflow / refund)

  "status": "paid",                         // ⛔ paid | approved | pending | rejected
                                            //   drives the row's status chip colour
  "requestor_name": "Asha Rao"              // ⛔ used in the row's bottom line
}
```

Only today's records (server time, IST) — at most ~10 entries. If there are more than 10, send 10 newest + the user taps "View All" for the full list.

---

## A.2 — `GET /accountant/transactions/today`  *(NEW endpoint)*

Backs the "View All" → today's transactions screen.

**Query parameters:** none (server filters by current IST day).

**Required response shape:**
```json
{
  "date":           "2026-05-25",            // YYYY-MM-DD (today, server-local)
  "total_in":       0.00,                    // sum of positive amounts
  "total_out":      15708.00,                // sum of negative amounts (absolute)
  "net":            -15708.00,               // total_in − total_out
  "count":          7,
  "transactions":   [ /* same per-row shape as A.1 */ ]
}
```

Each `transactions[]` entry uses the **exact same field shape as A.1** — frontend will share a single parser.

**Errors:** 401 if unauthenticated, 403 if the user isn't an accountant.

---

## A.3 — `GET /accountant/transactions/{id}`  *(NEW endpoint)*

Backs the tap-to-details flow when the accountant taps any transaction row.

**Path param:** `id` accepts either:
- numeric DB id (e.g. `106`) — preferred, taken from `todayTransactions[i].id`
- string request id (e.g. `EXP-0E3247D9`) — fallback, from `request_id`

**Required response shape — exactly the same as the completed-payment detail shape the frontend already handles (see §1.5 of the main spec).** Including:
```json
{
  "id":         106,
  "request_id": "EXP-0E3247D9",
  "amount":     4500.00,
  "purpose":    "...",
  "description":"...",
  "category":   "office_supplies",
  "department": "Operations",

  "status":         "approved",         // approved | auto_approved | pending | rejected
  "payment_status": "paid",             // pending | paid

  "created_at":  "2026-05-20T09:15:00",  // submitted
  "approved_at": "2026-05-21T10:00:00",  // ⛔ MUST be present when status is approved
  "rejected_at":  null,
  "paid_at":     "2026-05-25T11:42:00",  // ⛔ MUST be present when payment_status is paid

  "requestor": {
    "first_name": "Asha",
    "last_name":  "Rao",
    "email":      "asha@..."
  },
  "requestor_name":  "Asha Rao",
  "requestor_email": "asha@...",

  "vendor_name":           "Staples",          // payee/vendor if known
  "payment_method":        "UPI",              // UPI | NEFT | CASH | OTHER
  "transaction_reference": "TXN1234567",       // reference number from the payout
  "receipt_url":           "https://...",      // signed Cloudinary url, nullable
  "payment_qr_url":        "https://...",      // signed Cloudinary url, nullable

  "audit_trail": [                              // optional but used if present
    {
      "label":     "Submitted",      // OR  "action": "submitted"
      "actor":     "Asha Rao",
      "actor_role":"requestor",
      "timestamp": "2026-05-20T09:15:00",  // OR  "at": "..."
      "note":      "optional"
    },
    {
      "label":     "Approved",
      "actor":     "Admin",
      "actor_role":"admin",
      "timestamp": "2026-05-21T10:00:00"
    },
    {
      "label":     "Paid",
      "actor":     "Sai Kumar",
      "actor_role":"accountant",
      "timestamp": "2026-05-25T11:42:00",
      "note":      "UPI to vendor"
    }
  ]
}
```

The frontend already accepts multiple key aliases for `audit_trail` entries (`label || action || event`, `timestamp || at || created_at`, etc.) — so either naming convention works, but please pick **one** and stick with it.

**Errors:**
- 401 — unauthenticated
- 403 — not an accountant **OR** the transaction is from another organisation
- 404 — transaction id does not exist

---

## A.4 — Field source guide

For the backend team, here's where each of the above fields should come from on your side:

| Frontend field | Likely DB / source |
|---|---|
| `id` | `expenses.id` (or whichever table holds the request) |
| `request_id` | `expenses.request_id` |
| `title` | `expenses.category` mapped to display name (or `purpose` if `category` is null) |
| `subtitle` | `expenses.purpose` or first ~40 chars of `description` |
| `icon_type` | `expenses.category` (raw enum value) |
| `vendor_name` | `expenses.vendor_name` OR parsed from `payment_qr` payload |
| `department` | join → `departments.name` via `users.department_id` |
| `timestamp` | for today's transactions list: `expenses.paid_at` if paid, else `created_at` |
| `amount` | `expenses.amount`; sign according to flow direction |
| `status` | `expenses.status` |
| `payment_status` | `expenses.payment_status` (in detail) |
| `requestor_name` | concat `users.first_name + ' ' + users.last_name` |
| `requestor_email` | `users.email` |
| `audit_trail[]` | join → `expense_audit_log` ordered by `created_at ASC` |

---

## A.5 — Quick backend checklist (paste into the ticket)

- [ ] **`GET /accountant/dashboard`** — each `todayTransactions[]` row includes: `id` (numeric), `request_id`, `vendor_name`, `department`, `timestamp`, `status`, `requestor_name`. Up to 10 newest.
- [ ] **`GET /accountant/transactions/today`** — new endpoint. Returns `{ date, total_in, total_out, net, count, transactions[] }` with the same per-row shape as the dashboard.
- [ ] **`GET /accountant/transactions/{id}`** — new endpoint. Accepts integer OR string id. Returns the full request detail shape (same as §1.5 completed-payment detail) including `approved_at`, `paid_at`, `payment_method`, `transaction_reference`, `receipt_url`, `audit_trail[]`.
- [ ] All timestamps are server-local IST, no `Z` suffix.
- [ ] All money fields are numbers, not strings.
- [ ] 403/404 on cross-org access for the by-id endpoint.

Once these three endpoints land, the accountant's home "Today's Transactions" list will render fully, "View All" will open the day's complete transactions, and tapping any row will fetch the full request via id and show the detail page.
