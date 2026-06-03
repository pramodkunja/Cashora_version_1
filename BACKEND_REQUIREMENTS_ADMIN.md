# Cashora — Admin Flow Backend Requirements

Single source of truth for every HTTP call the **Admin** side of the Flutter
app makes. For each endpoint: request body, query params, response fields,
types, required flags, and the screen that displays each piece of data.

## Conventions

* **Base URL** — `lib/core/config/app_config.dart`. Production
  `https://cashora.nxsys.in`. Debug `http://192.168.0.149:8000`.
* **Auth** — every endpoint expects `Authorization: Bearer <JWT>`. The
  frontend stores the token under `auth_token` in secure storage.
* **Timestamps** — ISO‑8601. Naive strings (no `Z`/offset) are treated as
  server local time (currently IST).
* **Currency** — plain numbers in INR. Frontend formats with Indian
  grouping (`₹2,30,000.00`).
* **Pagination** — `{ total, page, size, items[] }` when paged.
* **Error envelope** — JSON with `detail` (preferred), `message`, or
  `error`. The frontend reads `detail` first.
* **IDs** — backend uses **numeric `id`** as the primary key. The
  user-facing string id is `request_id` (e.g. `EXP-77BD1000`). Both fields
  must be present on every expense response. The frontend uses `id` for
  API calls keyed on a specific expense; it shows `request_id` in the UI.

---

## 1. Admin Dashboard

**Screen**: [`admin_dashboard_view.dart`](lib/modules/admin/views/admin_dashboard_view.dart).
Shows greeting, three hero metrics, organization summary, quick actions.

### 1.1 `GET /admin/dashboard`

| Response field | Type | Required | Displayed as |
|---|---|---|---|
| `user.shortName` | string | No | Greeting headline (falls back to logged-in user's first name). |
| `overview.pendingRequestsCount` | int | Yes | **Pending** hero stat tile. |
| `overview.inClarificationCount` (alias `in_clarification_count`) | int | Yes | **Clarification** hero stat tile. |
| `overview.approvedAmount` | number | Yes | "Approved this period" green strip (Indian-grouped). |
| `departmentSummary.totalDepartments` | int | Yes | "Total departments" row. |
| `departmentSummary.activeDepartments` | int | Yes | "Active departments" row. |
| `departmentSummary.unassignedUsers` | int | Yes | "Unassigned users" row. |

Either camelCase or snake_case is accepted for these keys, but please
choose one and stick with it.

### 1.2 `GET /approver/dashboard-stats`

Optional supplementary summary used by the same screen. Non-blocking — if
it fails the dashboard still renders.

| Response field | Type | Required |
|---|---|---|
| `pending_count` | int | Yes |
| `total_approved_amount` | number | Yes |

### Dashboard tile taps

* **Pending tile** → navigates to Approvals tab → "Pending" sub-tab.
* **Clarification tile** → navigates to Approvals tab → "Clarification"
  sub-tab.
* **Total / Active departments rows** → `/admin/departments` page.
* **Unassigned users row** → `/admin/users` page.

---

## 2. Approvals (5 sub-tabs)

**Screen**: [`admin_approvals_view.dart`](lib/modules/admin/views/admin_approvals_view.dart).
Pending · Approved · Unpaid · Clarification · Rejected.

### 2.1 `GET /approver/org-expenses?status=…&payment_status=…`

Used to populate each sub-tab. Called four times in parallel on the screen
load with the following filter values:

| Tab | Query |
|---|---|
| Pending | `status=pending` |
| Approved + Unpaid (split client-side) | `status=approved` (frontend filters by `payment_status`) |
| Clarification | `status=clarification` |
| Rejected | `status=rejected` |

Returns an array of expense objects. Each item:

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | int | **Yes** | numeric DB id used in `/approver/expenses/{id}/decision`, `/approver/history/{id}`, etc. |
| `request_id` | string | **Yes** | user-facing id, displayed as `REQUEST ID #EXP-…`. |
| `request_type` | string | Yes | `pre_approved` / `post_approved` |
| `purpose` | string | Yes | |
| `description` | string\|null | No | |
| `category` | string | Yes | lowercase enum (see section 9) |
| `amount` | number | Yes | |
| `status` | string | Yes | see section 9 |
| `raw_status` | string | No | precise sub-state (`clarification_required` / `clarification_responded`) when `status` is the broader `clarification` |
| `rejection_reason` | string\|null | When `status=rejected` | |
| `receipt_url` | string\|null | No | Cloudinary URL |
| `payment_qr_url` | string\|null | No | Cloudinary URL |
| `payment_note` | string\|null | No | |
| `payment_method` | string\|null | No | `UPI` / `CASH` / `CUSTOM` when paid |
| `transaction_reference` | string\|null | No | |
| `created_at` | ISO string | Yes | |
| `updated_at` | ISO string | Yes | |
| `clarifications[]` | list | No | see section 4 |
| `requestor.first_name` | string | Yes | |
| `requestor.last_name` | string | Yes | |
| `requestor.email` | string | Yes | |
| `requestor.department` (or `department_name`) | string\|null | No | shown on details cards |

---

## 3. History tab

**Screen**: [`admin_history_view.dart`](lib/modules/admin/views/admin_history_view.dart).
Filter chips: All · Approved · Rejected · Clarified.

### 3.1 `GET /admin/history?status=…&search=…`

| Query param | Type | Required | Allowed values |
|---|---|---|---|
| `status` | string | No (omit for "All") | `approved`, `auto_approved`, `rejected`, `clarification` |
| `search` | string | No | free-text |

Returns an array. Each item should use the **same shape as 2.1** but
note the frontend has observed `/admin/history` returns:

* `id` as the **EXP-string** in some responses — please align this with
  the rest of the API so `id` is always the numeric DB id and
  `request_id` is the EXP string. Until then, the frontend reads
  whichever is numeric.
* `clarification_history[]` instead of `clarifications[]`. The frontend
  accepts both keys as aliases, but a single name across endpoints is
  preferred.

### History list tap

When the user taps a row:

* If `status` contains `clarification` → navigates to **Clarification
  Status** screen (section 4).
* Otherwise → navigates to **Request Details** screen (section 5).

---

## 4. Clarification Status screen

**Screen**: [`admin_clarification_status_view.dart`](lib/modules/admin/views/admin_clarification_status_view.dart).
Three sub-states:

* `pending` — waiting for the requestor to respond.
* `responded` — requestor replied; admin can Approve / Reject / Ask Again.
* `askingAgain` — admin is composing a follow-up question.

### 4.1 Sources of data

On open, the controller does three things in order:

1. **Reads `Get.arguments`** — the expense row the user tapped on, full
   shape.
2. **`GET /approver/org-expenses?status=clarification`** — finds the
   matching item by `id`, merges fresh fields (never wholesale replaces).
3. **`GET /approver/history/{expense_id}`** — the **canonical source of
   truth** for the clarification thread (see 4.3).

### 4.2 Hero card fields

Same expense shape as 2.1. Displays amount, REQUEST ID, category chip,
request-type chip, requestor row with avatar.

### 4.3 `GET /approver/history/{expense_id}`

Returns the clarification thread. Frontend accepts:

* bare array — `[ {…}, {…} ]`
* `{ "history": [ … ] }`
* `{ "clarifications": [ … ] }`
* `{ "data": [ … ] }`, `{ "items": [ … ] }`, `{ "results": [ … ] }`

Each clarification entry:

| Field | Type | Required | Displayed as |
|---|---|---|---|
| `id` | int | Yes | (key only) |
| `expense_id` | int | Yes | (key only) |
| `question` | string | Yes | left-aligned purple bubble |
| `response` | string\|null | No (null until requestor replies) | right-aligned green bubble |
| `asked_at` | ISO string | Yes | timestamp above question bubble |
| `responded_at` | ISO string\|null | No | timestamp above response bubble |

### 4.4 `POST /approver/ask-clarification`

Triggered from the "Ask Clarification" or "Ask Another Question" button.

| Field | Type | Required |
|---|---|---|
| `expense_id` | int | Yes |
| `question` | string | Yes (trimmed, non-empty) |

200 response: any JSON; frontend doesn't read it. Server should append a
new clarification entry with `response: null` to the thread.

### 4.5 `POST /approver/expenses/{expense_id}/decision`

Approve/Reject from inside the Clarification Status screen.

| Field | Type | Required | Notes |
|---|---|---|---|
| `action` | `"approve"` \| `"reject"` | Yes | |
| `rejection_reason` | string | Required when `action == reject` | |

### State determination rules

The frontend computes `pending` vs `responded` like this (in order):

1. If `status == "clarification_responded"` or
   `raw_status == "clarification_responded"` → responded.
2. If `status == "clarification_required"` or
   `raw_status == "clarification_required"` → pending.
3. Otherwise inspect the **latest** entry in the clarification thread:
   non-empty `response` → responded; empty/null → pending.

---

## 5. Request Details screen (pending / approved / rejected)

**Screen**: [`admin_request_details_view.dart`](lib/modules/admin/views/admin_request_details_view.dart).
One unified design with three accent variants:

| Variant | Trigger | Accent | Bottom bar |
|---|---|---|---|
| Pending | `status` is anything not approved/rejected | Purple | Ask Clarification + Reject + Approve |
| Approved | `status` ∈ {`approved`, `auto_approved`} | Green | hidden |
| Rejected | `status == "rejected"` | Red | hidden |

Fields displayed are the same shape as section 2.1 — `amount` (Indian
formatted), `request_id`, `purpose`, optional `description`, `category`
chip, `request_type` chip, `requestor` card, `created_at` (Submitted),
`updated_at` (Action date), `rejection_reason` (rejected only),
`receipt_url`/`payment_qr_url` (attachments).

### 5.1 Approve / Reject

Same call as 4.5 — `POST /approver/expenses/{expense_id}/decision`.

### 5.2 Attachments

The frontend dedupes by URL. It reads, in order:

1. Any pre-built `attachments[]` array
2. `receipt_url`
3. `payment_qr_url` (or `qr_url`)
4. `bill_urls[]` (or `bill_url`)

Each unique URL renders once. Tap opens the file viewer.

---

## 6. User Management

### 6.1 `GET /auth/users`

Lists all staff for the admin's organization. Each item:

| Field | Type | Required |
|---|---|---|
| `id` | int | Yes |
| `email` | string | Yes |
| `first_name` | string | Yes |
| `last_name` | string | Yes |
| `phone_number` | string\|null | No |
| `role` | string | Yes |
| `is_active` | bool | Yes |
| `department_id` | int\|null | No |
| `department_name` | string\|null | No |

The current logged-in admin's own row is filtered out client-side.

### 6.2 `POST /auth/add-staff`

**Screen**: Admin → Add User.

| Field | Type | Required |
|---|---|---|
| `first_name` | string | Yes |
| `last_name` | string | Yes |
| `email` | string | Yes |
| `phone_number` | string | Yes |
| `role` | string | Yes (`admin` / `accountant` / `requestor`) |
| `department_id` | int | No |

Returns the created user object.

### 6.3 `PATCH /users/update/{user_id}`

**Screen**: Admin → Edit User AND Profile → Edit (own profile).

**All fields are optional.** The backend MUST NOT null-out missing fields.
**The `email` field is intentionally not accepted** — email cannot be
changed through this endpoint.

| Field | Type |
|---|---|
| `first_name` | string |
| `last_name` | string |
| `phone_number` | string |
| `role` | string |
| `department_id` | int |
| `is_active` | bool |

Same endpoint serves three purposes:

* **Update**: body has the changed profile fields.
* **Soft delete (deactivate)**: body `{ "is_active": false }`.
* **Reactivate**: body `{ "is_active": true }`.

Returns the updated user object.

---

## 7. Departments

### 7.1 `GET /departments?include_inactive=bool`

| Item field | Type | Required |
|---|---|---|
| `id` | int | Yes |
| `name` | string | Yes |
| `code` | string\|null | No |
| `is_active` | bool | Yes |

### 7.2 `POST /departments`

Body: `{ "name": string, "code"?: string }`. Returns the new department.

### 7.3 `POST /departments/seed-defaults`

No body. Creates a starter set of departments. Returns the seeded list.

### 7.4 `GET /departments/{department_id}`

Returns the single department object.

### 7.5 `PATCH /departments/{department_id}`

All fields optional: `{ "name"?: string, "code"?: string, "is_active"?: bool }`.

### 7.6 `DELETE /departments/{department_id}`

Soft or hard delete — frontend doesn't care, just expects `2xx`.

### 7.7 `GET /departments/{department_id}/users`

Returns the list of users in that department (same item shape as 6.1).

---

## 8. Approval Limit

### 8.1 `GET /users/approval-limit`

Returns `{ "deemed_approval_limit": number, … }`. Shown on
**Admin → Set Approval Limits** screen.

### 8.2 `PATCH /users/approval-limit`

Body: `{ "deemed_approval_limit": number }`. Returns the updated record.

---

## 9. Enum reference

The frontend assumes the backend serializes these exact lowercase values.

| Field | Allowed values |
|---|---|
| `role` | `super_admin` · `admin` · `accountant` · `requestor` |
| `request_type` | `pre_approved` · `post_approved` |
| `category` | `office_supplies` · `travel` · `software` · `hardware` · `meals` · `transport` · `accommodation` · `entertainment` · `fuel` (plus any custom string) |
| `status` | `pending` · `approved` · `auto_approved` · `clarification` · `clarification_required` · `clarification_responded` · `rejected` · `paid` |
| `payment_method` | `UPI` · `CASH` · `CUSTOM` |
| `payment_status` | `unpaid` · `paid` · `processing` |

---

## 10. Screen ↔ Endpoint map

| Admin screen | Endpoint(s) used |
|---|---|
| Admin Dashboard | `GET /admin/dashboard`, `GET /approver/dashboard-stats` |
| Approvals tab (5 sub-tabs) | `GET /approver/org-expenses` (called 4×, one per status group) |
| History tab | `GET /admin/history` |
| Request Details (pending / approved / rejected) | data from `Get.arguments` + `POST /approver/expenses/{id}/decision` |
| Clarification Status | `GET /approver/org-expenses?status=clarification` (merge refresh) + `GET /approver/history/{id}` + `POST /approver/ask-clarification` + `POST /approver/expenses/{id}/decision` |
| User list | `GET /auth/users` |
| Add user | `POST /auth/add-staff` |
| Edit user / Deactivate / Reactivate | `PATCH /users/update/{id}` |
| Departments list / CRUD | section 7 |
| Set Approval Limits | `GET /users/approval-limit`, `PATCH /users/approval-limit` |
| Profile (admin's own) | `GET /users/me`, `PATCH /users/update/{id}` |
| Notifications | `POST /notifications/devices/register` on login, `unregister` on logout |

---

## 11. Open issues for the backend to align on

These are observed gaps where backend responses don't match what the
frontend would prefer. Each one has a graceful fallback in the app, but
shipping a consistent contract would let us delete those fallbacks.

1. **`/admin/history` field naming**:
   - Returns `id` as the EXP-string in some responses (should be the
     numeric DB id, with `request_id` carrying the EXP string).
   - Uses `clarification_history` for the thread (other endpoints use
     `clarifications`). Pick one.

2. **`/approver/dashboard-stats`** — supplementary endpoint that is
   currently optional. Confirm whether to keep it or fold its two values
   into `/admin/dashboard`.

3. **`overview.inClarificationCount` vs `in_clarification_count`** —
   choose one casing for the entire payload.

4. **Status filter `clarification` on `/approver/org-expenses`** — confirm
   whether it returns both `clarification_required` and
   `clarification_responded` items or only one of them. Frontend currently
   merges fields without assuming.

5. **`requestor.department`** — currently not populated on most responses.
   Frontend falls back to "General". Including it would let the admin
   request-details page show department reliably.
