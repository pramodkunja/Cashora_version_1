# Cashora — Backend Requirements (Frontend Contract)

This document is the **single source of truth** the Flutter frontend depends
on. Every HTTP request the app makes, the request body it sends, the query
parameters it sends, the response fields it parses, and the screens that
display each piece of data are listed below. If the backend changes a key,
a status value or an endpoint path, search this document for the screen
that depends on it.

Conventions used throughout:

* **Base URL** — set in `lib/core/config/app_config.dart`.
  Production: `https://cashora.nxsys.in`. Debug: `http://192.168.0.149:8000`.
* **Auth** — every endpoint except `/auth/login`, `/auth/forgot-password`,
  `/auth/verify-otp`, `/auth/reset-password`, `/auth/setup-organization`
  expects an `Authorization: Bearer <JWT>` header. The frontend stores the
  token under `auth_token` in secure storage.
* **Timestamps** — ISO‑8601. Naive strings (no `Z` / `±HH:MM`) are treated
  as *server local time* (i.e. already in IST for this deployment).
* **Currency** — all amounts are plain numbers in INR (rupees with up to 2
  decimals). The frontend formats them with Indian grouping
  (`₹2,30,000.00`).
* **Pagination** — `{ total, page, size, items[] }` whenever a paged list
  is needed.
* **Error envelope** — `4xx` / `5xx` responses must return JSON with one of
  these keys: `detail` (FastAPI default), `message`, or `error`. The
  frontend reads `detail` first.

---

## 1. AUTH & SESSION

### 1.1 `POST /auth/login`

Used on the Login screen.

| Direction | Field | Type | Required | Notes |
|---|---|---|---|---|
| Request body | `email` | string | Yes | |
| Request body | `password` | string | Yes | |
| 200 response | `access_token` | string | Yes | Stored in secure storage. |
| 200 response | `token_type` | string | Yes | Usually `"bearer"`. |
| 200 response | `email` | string | Yes | |
| 200 response | `first_name` | string | Yes | |
| 200 response | `last_name` | string | Yes | |
| 200 response | `phone_number` | string\|null | No | |
| 200 response | `role` | string | Yes | `admin` / `accountant` / `requestor` / `super_admin` (lowercase). |
| 200 response | `organization` | object | Yes | `{ id: int, name: string, org_code: string }` |

### 1.2 `GET /users/me`

Token-validation call on app start. Returns the current logged-in user.

| Field | Type | Required | Used by |
|---|---|---|---|
| `id` | int / string | Yes | profile, edit-user form, change-password |
| `email` | string | Yes | profile, FCM context |
| `first_name`, `last_name` | string | Yes | profile name, dashboards |
| `phone_number` | string\|null | No | profile, edit form |
| `role` | string | Yes | role-based routing |
| `organization` | `{ id, name, org_code }` | Yes | profile, dashboards |
| `department_id` | int\|null | No | edit form |
| `department_name` | string\|null | No | profile |

### 1.3 `POST /auth/forgot-password` / `verify-otp` / `reset-password`

Forgot-password flow. Bodies:

* `POST /auth/forgot-password` → `{ email }`
* `POST /auth/verify-otp` → `{ email, otp }`
* `POST /auth/reset-password` → `{ email, otp, new_password }`

All return `200` on success.

### 1.4 `POST /users/change-password`

Authenticated. Body `{ current_password, new_password }`. Returns `200`.

### 1.5 `POST /auth/logout`

Best-effort. The frontend always clears the local session regardless of
this response (404 is tolerated).

### 1.6 `POST /auth/setup-organization`

First-time organisation bootstrap.

| Field | Type | Required |
|---|---|---|
| `org_name` | string | Yes |
| `admin_details.email` | string | Yes |
| `admin_details.first_name` | string | Yes |
| `admin_details.last_name` | string | Yes |
| `admin_details.phone_number` | string | Yes |

---

## 2. USER & DEPARTMENT MANAGEMENT (ADMIN)

### 2.1 `GET /auth/users`

Returns the list of staff for the admin's organisation. Each item must
include at minimum: `id`, `email`, `first_name`, `last_name`,
`phone_number`, `role`, `is_active`, `department_id`, `department_name`.

### 2.2 `POST /auth/add-staff`

Body: `{ first_name, last_name, email, phone_number, role, department_id? }`.
Returns the created user object.

### 2.3 `PATCH /users/update/{user_id}`

**All fields optional.** Only fields present in the body are updated; the
backend MUST NOT null-out missing fields. **Email is intentionally not
accepted.**

| Field | Type |
|---|---|
| `first_name` | string |
| `last_name` | string |
| `phone_number` | string |
| `role` | string |
| `department_id` | int |
| `is_active` | bool |

The same endpoint is used for soft-deactivation (`{ is_active: false }`)
and for re-activation (`{ is_active: true }`).

### 2.4 `GET /users/approval-limit` and `PATCH /users/approval-limit`

* GET → returns `{ deemed_approval_limit, ... }`
* PATCH body: `{ deemed_approval_limit: number }`

### 2.5 Departments

* `GET /departments?include_inactive=bool` → list of `{ id, name, code, is_active }`
* `POST /departments` → body `{ name, code? }`
* `POST /departments/seed-defaults` → seed defaults
* `GET /departments/{id}` → single department
* `PATCH /departments/{id}` → body `{ name?, code?, is_active? }`
* `DELETE /departments/{id}` → delete
* `GET /departments/{id}/users` → users in department

---

## 3. REQUESTOR FLOW

### 3.1 `GET /requestor/dashboard`

Shown on the requestor home screen. Expected fields (any extras ignored):

* `monthly_spent`, `monthly_budget` — numbers
* `pending_count`, `approved_count`, `rejected_count` — ints
* `recent_requests[]` — list of expense objects (same shape as 3.3 items)

### 3.2 `GET /requestor/categories`

Returns `string[]` — the dropdown options for the "Submit Request"
category picker.

### 3.3 `GET /requestor/requests?status=…&search=…`

Status filter values accepted: `All`, `Pending`, `Clarification`,
`Approved`, `Rejected`, `Unpaid`. Returns an array of expense objects.

| Field | Type | Notes |
|---|---|---|
| `id` | int | numeric DB id |
| `request_id` | string | user-facing id like `EXP-77BD1000` |
| `request_type` | string | `pre_approved` / `post_approved` |
| `purpose` | string | required |
| `description` | string\|null | |
| `category` | string | enum, lowercase `office_supplies`, `travel`, … |
| `amount` | number | |
| `status` | string | `pending` / `approved` / `auto_approved` / `clarification` / `clarification_required` / `clarification_responded` / `rejected` / `paid` |
| `raw_status` | string | optional; precise sub-state |
| `rejection_reason` | string\|null | |
| `receipt_url` | string\|null | Cloudinary URL |
| `payment_qr_url` | string\|null | Cloudinary URL |
| `payment_method` | string\|null | `UPI` / `CASH` / `CUSTOM` once paid |
| `transaction_reference` | string\|null | |
| `payment_note` | string\|null | |
| `created_at` | ISO string | |
| `updated_at` | ISO string | |
| `clarifications[]` | list | see 3.5 |
| `requestor` | `{ first_name, last_name, email }` | required on admin/approver responses |

### 3.4 `POST /requestor/submit` (multipart/form-data)

Used by the "Submit Request" screen. **Text fields:**

| Field | Type | Required |
|---|---|---|
| `request_type` | enum string | Yes |
| `amount` | number-as-string | Yes |
| `purpose` | string | Yes |
| `description` | string | No |
| `category` | enum string | Yes |
| `payment_note` | string | No |

**File parts:**

* `payment_qr_file` — single image, optional
* `receipt_file` — single image, optional (one or many parts allowed for bills)

Returns the created expense object (shape of 3.3).

### 3.5 Clarifications

* `POST /requestor/respond-clarification/{expense_id}` → body `{ response_text }`. Used by the requestor's clarification screen.
* `GET /requestor/history/{expense_id}` → clarification thread.

Each clarification entry:

| Field | Type |
|---|---|
| `id` | int |
| `expense_id` | int |
| `question` | string |
| `response` | string\|null |
| `asked_at` | ISO string |
| `responded_at` | ISO string\|null |

### 3.6 `POST /expenses/process-payment-qr`

Body: `{ expense_id, qr_image_url, qr_data }`. Used by the requestor's
QR scanner widget. Frontend tolerates `404` (falls back to manual entry).

### 3.7 `POST /requestor/upload-payment-qr/{expense_id}` and `POST /requestor/upload-receipt/{expense_id}`

Multipart upload (single `file` field). Used to attach an extra
QR/receipt to an existing expense.

---

## 4. APPROVER / ADMIN FLOW

### 4.1 `GET /admin/dashboard`

Used on the admin dashboard.

| Field | Type | Where it's displayed |
|---|---|---|
| `user.shortName` | string | greeting card (falls back to logged-in user's first name) |
| `overview.pendingRequestsCount` | int | "Pending" stat tile |
| `overview.inClarificationCount` *or* `in_clarification_count` | int | "Clarification" stat tile |
| `overview.approvedAmount` | number | "Approved this period" hero |
| `departmentSummary.totalDepartments` | int | Org-summary card |
| `departmentSummary.activeDepartments` | int | Org-summary card |
| `departmentSummary.unassignedUsers` | int | Org-summary card |

### 4.2 `GET /approver/dashboard-stats`

Optional supplementary stats. `{ pending_count, total_approved_amount }`.

### 4.3 `GET /admin/history?status=…&search=…`

Status filter values: omit for "All", or one of `approved`, `auto_approved`,
`rejected`, `clarification`. Returns an array. Each item should include
the expense shape from 3.3 plus a nested `clarification_history[]` mirroring
the structure described in 3.5. **The frontend reads both `clarifications`
and `clarification_history` as aliases.**

### 4.4 `GET /approver/org-expenses?status=…&payment_status=…`

Same response shape as 3.3.

### 4.5 `POST /approver/expenses/{expense_id}/decision`

Used to approve, reject, or auto-approve.

| Field | Type | Required |
|---|---|---|
| `action` | `"approve"` \| `"reject"` | Yes |
| `rejection_reason` | string | Required when `action == reject` |

### 4.6 `POST /approver/ask-clarification`

Body: `{ expense_id, question }`. Appends a new clarification entry with
empty `response` to the expense's thread.

### 4.7 `GET /approver/history/{expense_id}`

Returns the **canonical** clarification thread for an expense. Accepted
shapes (frontend handles any of them):

* bare array: `[ {…}, {…} ]`
* wrapped: `{ "history": [ … ] }`
* wrapped: `{ "clarifications": [ … ] }`

---

## 5. ACCOUNTANT FLOW

### 5.1 `GET /accountant/dashboard`

Shown on the accountant home. Current shape accepted:

```json
{
  "amount_out": 15708,
  "pending_payments": 3,
  "opening_balance": 100000
}
```

The frontend derives:

* `closingBalance = opening_balance − amount_out`
* `inHandCash = closingBalance`
* `tasksSummary.pendingPaymentsCount = pending_payments`

The legacy nested shape (`accountOverview`, `tasksSummary`,
`todayTransactions[]`) is still accepted when present.

### 5.2 `GET /accountant/balance` *(NEW — required for Manage Balances screen)*

Returns today's balance snapshot.

| Field | Type | Required | Displayed as |
|---|---|---|---|
| `date` | ISO `YYYY-MM-DD` | Yes | header chip ("16 May") |
| `opening_balance` | number | Yes | "Opening" big stat (purple) |
| `closing_balance` | number | Yes | "Closing" big stat (green) |
| `amount_in` | number | Yes | "In" mini-stat |
| `amount_out` | number | Yes | "Out" mini-stat |
| `last_updated_at` | ISO string | No | meta below the snapshot |
| `note` | string\|null | No | amber note pill |

### 5.3 `POST /accountant/balance` *(NEW — Manage Balances + Daily Dialog)*

Body for the simple daily dialog (existing behaviour, still supported):
`{ "openingBalance": number }`.

Body for the Manage Balances screen:

| Field | Type | Required | Validation |
|---|---|---|---|
| `openingBalance` | number | Yes | `>= 0` |
| `closingBalance` | number | No | `>= 0` when provided |
| `note` | string | No | trimmed; ignore if empty |
| `date` | ISO `YYYY-MM-DD` | No | defaults to today on the server |

Returns the updated snapshot (same shape as 5.2).

### 5.4 `GET /accountant/balance/history?page=1&size=30` *(NEW)*

Returns the recent balance edits, newest first. Each item:

| Field | Type | Displayed as |
|---|---|---|
| `date` | ISO string | row title |
| `opening_balance` | number | (used to compute delta) |
| `closing_balance` | number | bold right-side amount |
| `amount_in` | number | (optional, not displayed yet) |
| `amount_out` | number | (optional, not displayed yet) |
| `updated_by` | string | "Updated by Sai" line under row title |
| `updated_at` | ISO string | (reserved for future tooltip) |
| `note` | string\|null | (reserved for future tooltip) |

Accepts either a bare array or `{ items: [...] }` envelope.

### 5.5 Pending / Paid Expenses

* `GET /accountant/expenses/pending-payments` → `{ total, page, size, items[] }`
* `GET /accountant/expenses/paid?page=&size=` → same envelope
* `POST /accountant/expenses/{expense_id}/mark-as-paid` → body
  `{ payment_method, transaction_reference?, payment_note? }`
* `GET /accountant/expenses/{expense_id}/payment-status` → polled during
  the payment flow. Return `{ status: "paid" | "unpaid" | "processing" | … }`.

### 5.6 Analytics

* `GET /accountant/analytics/spend?time_range=&department=&category=`
  Time-range enum (strict): `30d`, `90d`, `180d`, `1y`. Backend returns
  `{ total, by_period[], by_department[], by_category{} }` (current shape)
  — the frontend reshapes this into the rich SpendAnalyticsModel.
* `GET /accountant/analytics/spend-by-category` — lightweight
  `{ category: amount }` map.

### 5.7 Reports

* `GET /accountant/reports/summary?month=&year=&category=`
  Current shape: `{ total_amount, count, by_category{}, by_status{} }`.
* `GET /accountant/reports/export/csv?start_date=&end_date=&category=`
  Returns CSV bytes (`Content-Type: text/csv`).
* `GET /accountant/reports/export/pdf?start_date=&end_date=&category=`
  Returns PDF bytes (`Content-Type: application/pdf`).

### 5.8 Payment-method catalog and payouts

* `GET /accountant/payment-methods` → list of `{ id, name, code, icon? }`
* `POST /accountant/process-payout` → body
  `{ expense_id, reference_number?, accountant_note? }`

---

## 6. PAYMENTS ROUTER (UPI flow)

Currently all of `/payments/*` is wired in the frontend but gated behind a
runtime flag — if any one returns `404`, the entire UI flips to "Payment
processing coming soon". Endpoints expected:

* `POST /payments/record` — `{ amount, payment_method, transaction_id?, note?, timestamp }`
* `GET /payments/history` — list
* `POST /payments/initiate` — `{ request_id, payee_vpa, amount, payee_name?, transaction_note? }` → `{ payment_id }`
* `POST /payments/confirm` — `{ payment_id, status, upi_txn_id?, error_message? }`
* `GET /payments/completed` — `{ payments[] }`

---

## 7. NOTIFICATIONS / FCM

* `POST /notifications/devices/register` — body `{ token, platform: 'android'|'ios'|'web', app_version? }`
* `POST /notifications/devices/unregister` — body `{ token }`

Backend should accept all three platform values (the frontend sends the
real platform; rejecting `"web"` causes the registration to silently fail).

---

## 8. SCREEN ↔ ENDPOINT MAP (quick reference)

| Screen | Endpoint(s) |
|---|---|
| Login | `POST /auth/login` |
| Forgot/reset password | `POST /auth/forgot-password`, `verify-otp`, `reset-password` |
| Splash bootstrap | `GET /users/me` |
| Requestor dashboard | `GET /requestor/dashboard` |
| Requestor — My Requests | `GET /requestor/requests` |
| Requestor — Submit | `POST /requestor/submit`, `POST /expenses/process-payment-qr` |
| Requestor — Provide Clarification | request from args + `POST /requestor/respond-clarification/{id}` + `GET /requestor/history/{id}` |
| Requestor — Rejected detail | request from args |
| Admin dashboard | `GET /admin/dashboard`, `GET /approver/dashboard-stats` |
| Admin approvals list | `GET /approver/org-expenses` (per tab) |
| Admin history | `GET /admin/history` |
| Admin request details (pending / approved / rejected) | request from args + `POST /approver/expenses/{id}/decision` |
| Admin clarification status | `GET /approver/history/{id}`, `POST /approver/ask-clarification`, `POST /approver/expenses/{id}/decision` |
| Admin users / departments / approval limit | section 2 |
| Accountant home | `GET /accountant/dashboard` |
| **Accountant → Profile → Opening & Closing Balances** | **`GET /accountant/balance`**, **`POST /accountant/balance`**, **`GET /accountant/balance/history`** |
| Accountant payments tab | `GET /accountant/expenses/pending-payments`, `paid`, `mark-as-paid`, `payment-status` |
| Accountant Reports — Spend Analytics | `GET /accountant/analytics/spend` |
| Accountant Reports — Financial Reports | `GET /accountant/reports/summary` (+ exports) |
| Profile (all roles) | `GET /users/me`, `PATCH /users/update/{id}`, `POST /users/change-password` |
| Notifications (any role) | `POST /notifications/devices/register` |

---

## 9. STATUS / ENUM REFERENCE

| Field | Allowed values |
|---|---|
| `role` | `super_admin` · `admin` · `accountant` · `requestor` |
| `request_type` | `pre_approved` · `post_approved` |
| `category` | `office_supplies` · `travel` · `software` · `hardware` · `meals` · `transport` · `accommodation` · `entertainment` · `fuel` · plus any custom |
| `status` | `pending` · `approved` · `auto_approved` · `clarification` · `clarification_required` · `clarification_responded` · `rejected` · `paid` |
| `payment_method` | `UPI` · `CASH` · `CUSTOM` |
| `payment_status` | `unpaid` · `paid` · `processing` |
| `DevicePlatform` | `android` · `ios` · `web` |
| `time_range` (analytics) | `30d` · `90d` · `180d` · `1y` |

---

## 10. NEW WORK FOR THIS RELEASE

Backend work required to ship the new **Opening & Closing Balances**
screen on the accountant profile:

1. **`GET /accountant/balance`** — return today's snapshot. See 5.2 for
   the exact field list. If no balance has been set yet, return
   `opening_balance = 0`, `closing_balance = 0`, etc., with `date` =
   today.
2. **`POST /accountant/balance`** — must accept the extended body
   (`closingBalance`, `note`, `date`) on top of the existing
   `openingBalance` field. See 5.3.
3. **`GET /accountant/balance/history`** — paginated history list, newest
   first. See 5.4.

All three must be available to users with role `accountant` (and ideally
`admin` for audit). They power the screen at
`AppRoutes.ACCOUNTANT_MANAGE_BALANCES` (`/accountant/manage-balances`).

Anything else not listed here — the frontend is already happy with the
current backend.
