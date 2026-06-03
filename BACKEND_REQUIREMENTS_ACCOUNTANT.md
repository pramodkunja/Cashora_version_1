# Cashora — Accountant Flow Backend Requirements

Single source of truth for every HTTP call the **Accountant** side of the
Flutter app makes. For each endpoint: request body, query params, response
fields, types, required flags, and the screen that displays each value.

## Conventions

* **Base URL** — `lib/core/config/app_config.dart`. Production
  `https://cashora.nxsys.in`. Debug `http://192.168.0.149:8000`.
* **Auth** — every endpoint expects `Authorization: Bearer <JWT>`. Token
  stored under `auth_token` in secure storage.
* **Timestamps** — ISO‑8601. Naive strings (no `Z`/offset) are treated as
  server local time (currently IST).
* **Currency** — plain numbers in INR. Frontend formats with Indian
  grouping (`₹2,30,000.00`).
* **Pagination** — `{ total, page, size, items[] }`.
* **Error envelope** — JSON with `detail` (preferred), `message`, or
  `error`. Frontend reads `detail` first.
* **IDs** — backend uses **numeric `id`** as the primary key. The
  user-facing string id is `request_id` (e.g. `EXP-77BD1000`). Both must
  appear on every expense response. The frontend uses `id` for API calls
  keyed on a specific expense; it shows `request_id` in the UI.

---

## 1. Accountant Home (Dashboard)

**Screen**: [`accountant_home_view.dart`](lib/modules/accountant/views/accountant_home_view.dart).
Shows in-hand cash card, balance row, pending-payments banner, today's
transactions list.

### 1.1 `GET /accountant/dashboard`

Current accepted shape (flat, the version the live backend serves today):

| Response field | Type | Required | Displayed as |
|---|---|---|---|
| `opening_balance` | number | Yes | "Open balance" pill |
| `amount_out` | number | Yes | derived → `closingBalance = opening_balance − amount_out`; also used directly when shown |
| `pending_payments` | int | Yes | "Pending payments" banner count |

Frontend derives:

* `closingBalance = opening_balance − amount_out`
* `inHandCash = closingBalance` (headline "₹" on the page)
* `tasksSummary.pendingPaymentsCount = pending_payments`

The richer nested shape below is also accepted if you adopt it later
(frontend prefers it when present):

```jsonc
{
  "user": { "shortName": "Sai" },
  "accountOverview": {
    "inHandCash":       4250.00,
    "inHandCashGrowth": "+2.4%",
    "openBalance":      5000.00,
    "closingBalance":   4250.00
  },
  "tasksSummary":   { "pendingPaymentsCount": 5 },
  "todayTransactions": [
    {
      "id":         "T-001",
      "title":      "Office Supplies",
      "subtitle":   "Staples · 10:45 AM",
      "vendorName": "Staples",
      "timestamp":  "2026-05-16T10:45:00",
      "amount":     -45.00,
      "iconType":   "PRINT"
    }
  ]
}
```

`iconType` enum recognised by the frontend (anything else falls back to a
receipt icon): `OFFICE_SUPPLIES` · `CLIENT_MEETING` · `FOOD` · `TRAVEL` ·
`SOFTWARE`.

### 1.2 Daily-balance dialog on first dashboard open of the day

The dashboard pops a dialog asking the accountant to confirm the opening
balance once per day. On submit it calls:

`POST /accountant/balance` with body `{ "openingBalance": number }`.
See section 5 for full Manage-Balances contract — this dialog is the
minimal form of that flow.

---

## 2. Payments tab

**Screen**: [`accountant_payments_view.dart`](lib/modules/accountant/views/accountant_payments_view.dart).
Two sub-tabs: **Pending** (unpaid approved expenses) and **Completed**
(paid). Each row taps into the Payment Flow (section 3).

### 2.1 `GET /accountant/expenses/pending-payments`

Returns the paginated envelope with all currently unpaid approved
expenses.

| Field | Type | Required |
|---|---|---|
| `total` | int | Yes |
| `page` | int | Yes |
| `size` | int | Yes |
| `items[]` | list | Yes |

Each `items[]` element:

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | int | **Yes** | numeric DB id, used in `/mark-as-paid`, `/payment-status` |
| `request_id` | string | Yes | EXP-… for display |
| `request_type` | string | Yes | `pre_approved` / `post_approved` |
| `purpose` | string | Yes | |
| `description` | string\|null | No | |
| `category` | string | Yes | lowercase enum (section 9) |
| `amount` | number | Yes | |
| `status` | string | Yes | typically `approved` here |
| `expense_status` | string | No | same as `status` if present |
| `payment_status` | string\|null | No | usually `unpaid` here |
| `receipt_url` | string\|null | No | |
| `payment_qr_url` | string\|null | No | |
| `payment_note` | string\|null | No | |
| `created_at` | ISO string | Yes | |
| `updated_at` | ISO string | Yes | |
| `requestor.first_name` | string | Yes | |
| `requestor.last_name` | string | Yes | |
| `requestor.email` | string | Yes | |

> Both `items[]` and the legacy `payments[]` envelope name are read by
> the frontend, but `items[]` is the canonical name.

### 2.2 `GET /accountant/expenses/paid?page=&size=`

Same envelope as 2.1. Each `items[]` element additionally carries:

| Field | Type | Required |
|---|---|---|
| `payment_method` | string | Yes (after payment) — `UPI` / `CASH` / `CUSTOM` |
| `transaction_reference` | string\|null | No |
| `paid_at` / `processed_at` | ISO string | Yes |

---

## 3. Payment Flow (mark as paid)

**Screens**: Request Details → Mark As Paid → Verify → Confirm → Success / Failed.

### 3.1 `GET /accountant/payment-methods`

Returns the list of supported payment methods the "Mark As Paid" picker
shows. Each item:

| Field | Type | Required |
|---|---|---|
| `id` | int | Yes |
| `name` | string | Yes (display label) |
| `code` | string | Yes — one of `UPI`, `CASH`, `CUSTOM` |
| `icon` | string\|null | No (optional icon hint) |

If the list is empty, the picker shows a shimmer block until data lands.

### 3.2 `POST /accountant/expenses/{expense_id}/mark-as-paid`

Body:

| Field | Type | Required | Validation |
|---|---|---|---|
| `payment_method` | string | Yes | one of `UPI`, `CASH`, `CUSTOM` |
| `transaction_reference` | string | No | trimmed, ignored if empty |
| `payment_note` | string | No | trimmed, ignored if empty |

Returns the updated expense (same shape as 2.1).

### 3.3 `GET /accountant/expenses/{expense_id}/payment-status`

Polled by `PaymentStatusService` after `mark-as-paid`. Returns
`{ "status": "paid" | "unpaid" | "processing" | … }`. On `404` the
frontend falls back to label "Status unknown".

### 3.4 `POST /accountant/process-payout`

Used by the payout flow. Body:

| Field | Type | Required |
|---|---|---|
| `expense_id` | int | Yes |
| `reference_number` | string | No |
| `accountant_note` | string | No |

Returns any JSON; frontend treats `2xx` as success.

### 3.5 Payment router (`/payments/*`)

These endpoints are wired in `payment_repository.dart` and gated behind a
runtime flag — if any returns `404`, the entire UI flips to "Payment
processing coming soon".

* `POST /payments/record` — `{ amount, payment_method, transaction_id?, note?, timestamp }`
* `GET /payments/history` — list of payment maps
* `POST /payments/initiate` — `{ request_id, payee_vpa, amount, payee_name?, transaction_note? }` → `{ payment_id, … }`
* `POST /payments/confirm` — `{ payment_id, status, upi_txn_id?, error_message? }`
* `GET /payments/completed` — `{ payments[] }`

UPI regex enforced client-side for `payee_vpa`:
`^[a-zA-Z0-9._-]{2,}@[a-zA-Z]{2,}$`.

---

## 4. Reports tab

**Screens**: Spend Analytics + Financial Reports
([`spend_analytics_view.dart`](lib/modules/accountant/views/analytics/spend_analytics_view.dart),
[`financial_reports_view.dart`](lib/modules/accountant/views/analytics/financial_reports_view.dart)).

### 4.1 `GET /accountant/analytics/spend?time_range=&department=&category=`

| Query param | Type | Required | Allowed values |
|---|---|---|---|
| `time_range` | string | No | **strict enum**: `30d` · `90d` · `180d` · `1y` — the frontend maps UI labels ("This Month", "Last 3 Months", "Last 6 Months", "Last Year") to these tokens before sending. |
| `department` | string | No | placeholder "Department" / "All Departments" stripped client-side |
| `category` | string | No | placeholder "Category" / "All Categories" stripped client-side |

Current accepted shape (the version on the live backend):

```jsonc
{
  "total": 22752.0,
  "by_period": [
    { "year": 2026, "month": 4, "total": 19152.0 },
    { "year": 2026, "month": 5, "total":  3600.0 }
  ],
  "by_department": [
    { "department": "Development", "total": 22752.0 }
  ],
  "by_category": {
    "travel":          7000.0,
    "software":       12132.0,
    "office_supplies": 3620.0
  }
}
```

Frontend reshapes into the rich `SpendAnalyticsModel` the views consume:

| Backend → | UI element |
|---|---|
| `total` | "Total Spend" score card |
| `total / by_period.length` | "Avg Transaction" score card |
| `by_category` (map) | Top Categories breakdown — each entry's percentage is computed from the category sum |
| `by_department` (list) | Department bars — `progressRatio = amount / max(amount)` |
| `by_period` (list) | Monthly Trend line chart with labels like `"Apr 26"` |
| last vs previous period | `monthlyTrend.trendSummaryText` (e.g. `"-81.2%"`) |

### 4.2 `GET /accountant/analytics/spend-by-category`

Lightweight `{ category: amount }` map. Used by simpler widgets that only
need a breakdown by category. Optional — frontend has a cached helper.

### 4.3 `GET /accountant/reports/summary?month=&year=&category=`

Used by the "Generate Preview" button on Financial Reports.

| Query param | Type | Required |
|---|---|---|
| `month` | int | No |
| `year` | int | No |
| `category` | string | No (`All Categories` stripped) |

Current accepted shape:

```jsonc
{
  "total_amount": 19152.0,
  "count":        3,
  "by_category": {
    "software":       12132.0,
    "travel":          5000.0,
    "office_supplies": 2020.0
  },
  "by_status": {
    "approved":               2020.0,
    "paid":                  12132.0,
    "clarification_required": 5000.0
  }
}
```

Mapped to the UI as:

| Backend → | UI |
|---|---|
| `total_amount` | "Total Expenses" hero amount |
| `count` | "Transactions" hero stat |
| `by_category` (map) | "Transactions" rows — one per `(category, amount)` pair |
| current month | `monthYear` header pill ("May 2026") — synthesised client-side |

`by_status` is parsed but not yet displayed — keeping it for a future
status-breakdown widget.

### 4.4 `GET /accountant/reports/export/csv` and `pdf`

| Query param | Type | Required |
|---|---|---|
| `start_date` | ISO `YYYY-MM-DD` | No |
| `end_date` | ISO `YYYY-MM-DD` | No |
| `category` | string | No (`All Categories` stripped) |

Return binary bytes (`Content-Type: text/csv` and `application/pdf`).
Frontend writes to the temp directory and calls `OpenFile.open(path,
type: mime)`. If your build returns the CSV/PDF inline, please set the
correct `Content-Type` so the viewer launches.

### 4.5 First-fetch behaviour

The Reports tab is **lazy**. Both `/accountant/analytics/spend` and
`/accountant/reports/summary` are only called the first time the tab is
opened (driven by a reactive worker on the bottom-nav index). Filter
changes re-fetch on demand.

---

## 5. Opening & Closing Balances *(NEW screen — needs three new endpoints)*

**Screen**: [`manage_balances_view.dart`](lib/modules/accountant/views/manage_balances_view.dart).
Reachable from **Accountant → Profile → "Opening & Closing Balances"**
(route `AppRoutes.ACCOUNTANT_MANAGE_BALANCES` = `/accountant/manage-balances`).

Three endpoints required.

### 5.1 `GET /accountant/balance`

Returns today's balance snapshot. Used to populate the summary card.

| Field | Type | Required | Displayed as |
|---|---|---|---|
| `date` | ISO `YYYY-MM-DD` | Yes | header chip ("16 May") |
| `opening_balance` | number | Yes | "OPENING" big stat (purple) |
| `closing_balance` | number | Yes | "CLOSING" big stat (green) |
| `amount_in` | number | Yes | "In" mini-stat row |
| `amount_out` | number | Yes | "Out" mini-stat row |
| `last_updated_at` | ISO string | No | reserved for future tooltip |
| `note` | string\|null | No | amber note pill shown when present |

If no balance has been set yet for today, return `opening_balance = 0`,
`closing_balance = 0`, with `date` = today (don't 404).

### 5.2 `POST /accountant/balance` *(extended body)*

Existing daily dialog still works with `{ "openingBalance": number }`.
The Manage Balances screen sends the extended body:

| Field | Type | Required | Validation |
|---|---|---|---|
| `openingBalance` | number | Yes | `>= 0` |
| `closingBalance` | number | No | `>= 0` when provided |
| `note` | string | No | trimmed, ignore if empty |
| `date` | ISO `YYYY-MM-DD` | No | defaults to today on the server |

Returns the updated snapshot (same shape as 5.1). The frontend re-fetches
the snapshot + history after a successful save, so anything you return
is fine as long as it's a 2xx JSON.

### 5.3 `GET /accountant/balance/history?page=1&size=30`

Used to render the "History" card. Returns past balance snapshots, newest
first. Accepts either a bare array or `{ items: [...] }` envelope.

Each item:

| Field | Type | Required | Displayed as |
|---|---|---|---|
| `date` | ISO string | Yes | row title ("16 May") |
| `opening_balance` | number | Yes | (used to compute delta) |
| `closing_balance` | number | Yes | bold right-side amount |
| `amount_in` | number | No | (reserved) |
| `amount_out` | number | No | (reserved) |
| `updated_by` | string | No | "Updated by Sai" subtitle |
| `updated_at` | ISO string | No | (reserved for tooltip) |
| `note` | string\|null | No | (reserved for tooltip) |

The delta shown on each row is computed client-side as
`closing - opening`, coloured green for ≥ 0 and red otherwise.

---

## 6. Profile (accountant)

**Screen**: [`accountant_profile_view.dart`](lib/modules/accountant/views/accountant_profile_view.dart).
Tab order: Personal Info → **Cash Management** (new) → Settings.

### 6.1 `GET /users/me`

Same call as everywhere else.

| Field | Type | Required | Displayed as |
|---|---|---|---|
| `email` | string | Yes | header email + Info row |
| `first_name`, `last_name` | string | Yes | header name |
| `phone_number` | string\|null | No | Info row |
| `role` | string | Yes | role pill ("ACCOUNTANT") |
| `organization` | `{ id, name, org_code }` | Yes | not displayed on this screen but cached |
| `department_id` | int\|null | No | edit form |
| `department_name` | string\|null | No | "Department" Info row |

### 6.2 `PATCH /users/update/{user_id}`

Used by the "Edit" button in the header. **Email is intentionally not
accepted** — read-only on the form.

All other fields optional (`first_name`, `last_name`, `phone_number`).
Returns the updated user.

### 6.3 `POST /users/change-password`

Body: `{ current_password, new_password }`. Triggered from Settings.

### 6.4 `POST /auth/logout`

Best-effort. Frontend clears the local session regardless of response —
404 is tolerated.

---

## 7. Notifications / FCM

### 7.1 `POST /notifications/devices/register`

Called after a successful login and on FCM token refresh.

| Field | Type | Required |
|---|---|---|
| `token` | string | Yes |
| `platform` | string | Yes — `android` · `ios` · `web` |
| `app_version` | string | No |

Backend must accept all three platforms — rejecting `"web"` causes the
registration to silently fail and the accountant misses push events.

### 7.2 `POST /notifications/devices/unregister`

Body `{ token }`. Best-effort, called on logout.

### 7.3 Push notification event types the accountant cares about

The accountant listens for these `data.event_type` values (sent by FCM as
data-only payload alongside the visible `notification` block):

* `expense_approved` — refresh pending-payments list
* `clarification_responded` — same as above
* `expense_paid` — refresh paid list

The frontend routes notification taps using
`AppRoutes.ACCOUNTANT_PAYMENT_REQUEST_DETAILS` with
`{ expense_id, request_id, from_notification: true }` in the arguments.

---

## 8. Enum reference

| Field | Allowed values |
|---|---|
| `role` | `accountant` (this flow) |
| `category` | `office_supplies` · `travel` · `software` · `hardware` · `meals` · `transport` · `accommodation` · `entertainment` · `fuel` (plus any custom) |
| `request_type` | `pre_approved` · `post_approved` |
| `status` | `approved` · `auto_approved` · `paid` (typical for the accountant view) |
| `payment_method` | `UPI` · `CASH` · `CUSTOM` |
| `payment_status` | `unpaid` · `paid` · `processing` |
| `time_range` (analytics) | `30d` · `90d` · `180d` · `1y` |
| `DevicePlatform` | `android` · `ios` · `web` |
| `iconType` (today transactions) | `OFFICE_SUPPLIES` · `CLIENT_MEETING` · `FOOD` · `TRAVEL` · `SOFTWARE` |

---

## 9. Screen ↔ Endpoint map

| Accountant screen | Endpoint(s) used |
|---|---|
| Home (dashboard) | `GET /accountant/dashboard`, opening-balance dialog → `POST /accountant/balance` |
| Payments → Pending | `GET /accountant/expenses/pending-payments` |
| Payments → Completed | `GET /accountant/expenses/paid` |
| Request Details (in payment flow) | data from `Get.arguments` |
| Bill Details | data from `Get.arguments` (image download for save uses Dio) |
| Mark As Paid | `GET /accountant/payment-methods`, `POST /accountant/expenses/{id}/mark-as-paid` |
| Verify / Confirm Payment | `PaymentStatusService` polling `GET /accountant/expenses/{id}/payment-status` |
| Reports → Spend Analytics | `GET /accountant/analytics/spend` |
| Reports → Financial Reports preview | `GET /accountant/reports/summary` |
| Reports → Export CSV / PDF | `GET /accountant/reports/export/csv`, `…/pdf` |
| **Profile → Opening & Closing Balances** | **`GET /accountant/balance`**, **`POST /accountant/balance`**, **`GET /accountant/balance/history`** |
| Profile (Personal Info, Edit, Settings) | `GET /users/me`, `PATCH /users/update/{id}`, `POST /users/change-password` |
| Logout | `POST /auth/logout` (best-effort) |
| Push notifications | `POST /notifications/devices/register` / `unregister` |

---

## 10. New work for this release

Backend work required to ship the new **Opening & Closing Balances**
screen on the accountant profile (already wired and shipping in the
frontend):

1. **`GET /accountant/balance`** — return today's snapshot. See 5.1.
   When no record exists yet for today, return zeros with `date = today`
   rather than 404.
2. **`POST /accountant/balance`** — must accept the extended body
   (`closingBalance`, `note`, `date`) on top of the existing
   `openingBalance` field. See 5.2.
3. **`GET /accountant/balance/history`** — paginated history list,
   newest first. See 5.3.

All three must be available to users with role `accountant` (and ideally
`admin` for audit). They power the screen at
`AppRoutes.ACCOUNTANT_MANAGE_BALANCES` (`/accountant/manage-balances`).

---

## 11. Open issues / inconsistencies for the backend to align on

These are observed gaps where backend responses don't match what the
frontend would prefer. Each one has a graceful fallback in the app, but
shipping a consistent contract would let us delete those fallbacks.

1. **`/accountant/dashboard` shape**: currently flat
   (`opening_balance` / `amount_out` / `pending_payments`). The frontend
   would prefer the nested `accountOverview` / `tasksSummary` /
   `todayTransactions` shape so it can show the in-hand cash growth %,
   recent transactions, and avoid the manual derivation. Pick one and
   stick with it.

2. **`time_range` enum** on `/accountant/analytics/spend` — confirm the
   strict tokens `30d` · `90d` · `180d` · `1y` are the canonical set.
   Frontend currently maps UI labels to these tokens before sending.

3. **Pending-payments envelope** — the canonical key for the items array
   is `items[]`. The frontend has a fallback that reads `payments[]` for
   legacy responses; please standardize on `items[]`.

4. **`GET /accountant/expenses/{id}/payment-status`** — confirm the
   exact lifecycle values. Frontend recognises `paid`, `unpaid`,
   `processing`, `error`, and any other string ends up as "Status
   unknown".

5. **`/accountant/payment-methods`** — confirm whether this returns the
   org-level configured methods or a fixed `UPI / CASH / CUSTOM` set. The
   frontend's "Mark As Paid" picker currently expects an array of `{ id,
   name, code, icon? }` and the `code` field drives the payment_method
   submitted to `/mark-as-paid`.

6. **Notification `platform="web"`** — please accept `web` alongside
   `android` / `ios`. Currently rejected, causing web push registration
   to silently fail.

7. **`/payments/*` router** — frontend has feature-flagged this entire
   namespace behind a runtime 404 check (`paymentsAvailable.value =
   false` flips the UI to "coming soon"). If/when the router is live,
   the flag flips automatically on the first successful call. Confirm
   the five endpoints listed in 3.5 (record / history / initiate /
   confirm / completed) are the canonical set.
