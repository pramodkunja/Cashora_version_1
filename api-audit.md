# Cashora Flutter App — HTTP API Surface Audit

**Audit Date:** 2026-05-15
**App:** Cashora v1
**Base URL (active):** `https://cashora.nxsys.in`
**Authentication:** Bearer token (JWT) injected via Dio interceptor on all requests

---

## Configuration

### Base URLs
- **Production (active):** `https://cashora.nxsys.in`
- **Development (commented):** `http://10.0.2.2:8000` (Android emulator)
- **Development (commented):** `http://127.0.0.1:8000` (iOS simulator)
- **Development (commented):** `http://192.168.0.149:8000` (Local IP)

Set in [lib/core/config/app_config.dart](lib/core/config/app_config.dart#L16).

### Network Configuration
- **Framework:** Dio + GetX
- **HTTP Client:** [lib/core/services/network_service.dart](lib/core/services/network_service.dart)
- **Connection Timeout:** 15 seconds
- **Receive Timeout:** 15 seconds
- **Debug Logs:** Enabled

### Authentication & Interceptors

- **Header:** `Authorization: Bearer <token>` automatically added via Dio interceptor — [NetworkService.init()](lib/core/services/network_service.dart#L24-L67)
- **Token storage:** `auth_token` key in secure storage
- **Token source:** Returned from `/auth/login` (the client accepts `token`, `access_token`, or `auth_token` keys)
- **401 handling:** Triggers auto-logout globally
- **Logging:** All requests/responses logged in debug mode

---

## API Endpoints by Feature Area

### Authentication & User Management (13 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 1 | POST | `/auth/login` | `email`, `password` | — | — | `user`, `token`/`access_token`/`auth_token` | No | [auth_repository.dart:9](lib/data/repositories/auth_repository.dart#L9) |
| 2 | GET | `/auth/me` | — | — | — | `id`, `email`, `name`, `first_name`, `last_name`, `role`, `organization`, `phone_number`, `department_id` | Yes | [auth_repository.dart:196](lib/data/repositories/auth_repository.dart#L196) |
| 3 | POST | `/auth/forgot-password` | `email` | — | — | Success response | No | [auth_repository.dart:39](lib/data/repositories/auth_repository.dart#L39) |
| 4 | POST | `/auth/verify-otp` | `email`, `otp` | — | — | Success response | No | [auth_repository.dart:50](lib/data/repositories/auth_repository.dart#L50) |
| 5 | POST | `/auth/reset-password` | `email`, `otp`, `new_password` | — | — | Success response | No | [auth_repository.dart:61](lib/data/repositories/auth_repository.dart#L61) |
| 6 | POST | `/users/change-password` | `current_password`, `new_password` | — | — | Success response | Yes | [auth_repository.dart:81](lib/data/repositories/auth_repository.dart#L81) |
| 7 | POST | `/auth/logout` | — | — | — | N/A | Yes | [auth_repository.dart:98](lib/data/repositories/auth_repository.dart#L98) |
| 8 | GET | `/auth/users` | — | — | — | List of user maps | Yes | [auth_repository.dart:102](lib/data/repositories/auth_repository.dart#L102) |
| 9 | POST | `/auth/add-staff` | `first_name`, `last_name`, `email`, `phone_number`, `role`, `department_id?` | — | — | User map | Yes | [auth_repository.dart:122](lib/data/repositories/auth_repository.dart#L122) |
| 10 | PATCH | `/users/update/{userId}` | `first_name`, `last_name`, `email`, `phone_number`, `role`, `is_active`, `department_id?` | — | `userId` | User map | Yes | [auth_repository.dart:151](lib/data/repositories/auth_repository.dart#L151) |
| 11 | PATCH | `/users/update/{userId}` | `is_active: false` (soft delete) | — | `userId` | User map | Yes | [auth_repository.dart:183](lib/data/repositories/auth_repository.dart#L183) |
| 12 | GET | `/users/me` | — | — | — | User object | Yes | [user_repository.dart:11](lib/data/repositories/user_repository.dart#L11) |
| 13 | PATCH | `/users/update/{userId}` | Dynamic map (context-dependent) | — | `userId` | User object | Yes | [user_repository.dart:37](lib/data/repositories/user_repository.dart#L37) |

---

### Organization & Setup (3 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 14 | POST | `/auth/setup-organization` | `org_name`, `admin_details: {email, first_name, last_name, phone_number}` | — | — | Success response | No | [organization_repository.dart:8](lib/data/repositories/organization_repository.dart#L8) |
| 15 | GET | `/users/approval-limit` | — | — | — | `deemed_approval_limit`, other fields | Yes | [organization_repository.dart:32](lib/data/repositories/organization_repository.dart#L32) |
| 16 | PATCH | `/users/approval-limit` | `deemed_approval_limit` | — | — | Success response | Yes | [organization_repository.dart:41](lib/data/repositories/organization_repository.dart#L41) |

---

### Departments (7 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 17 | POST | `/departments` | `name`, `code?` | — | — | Department map | Yes | [department_repository.dart:10](lib/data/repositories/department_repository.dart#L10) |
| 18 | GET | `/departments` | — | `include_inactive?` | — | List of department maps | Yes | [department_repository.dart:22](lib/data/repositories/department_repository.dart#L22) |
| 19 | POST | `/departments/seed-defaults` | — | — | — | Department map | Yes | [department_repository.dart:36](lib/data/repositories/department_repository.dart#L36) |
| 20 | GET | `/departments/{id}` | — | — | `id` | Department map | Yes | [department_repository.dart:42](lib/data/repositories/department_repository.dart#L42) |
| 21 | PATCH | `/departments/{id}` | `name?`, `code?`, `is_active?` | — | `id` | Department map | Yes | [department_repository.dart:48](lib/data/repositories/department_repository.dart#L48) |
| 22 | DELETE | `/departments/{id}` | — | — | `id` | Success response | Yes | [department_repository.dart:65](lib/data/repositories/department_repository.dart#L65) |
| 23 | GET | `/departments/{id}/users` | — | — | `id` | User map | Yes | [department_repository.dart:70](lib/data/repositories/department_repository.dart#L70) |

---

### Requestor — Expense Submission & Management (6 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 24 | GET | `/requestor/categories` | — | — | — | List of strings | Yes | [request_repository.dart:15](lib/data/repositories/request_repository.dart#L15) |
| 25 | GET | `/requestor/dashboard` | — | — | — | Dashboard map | Yes | [request_repository.dart:24](lib/data/repositories/request_repository.dart#L24) |
| 26 | POST | `/requestor/submit` | **Multipart**: `request_type`, `amount`, `purpose`, `description`, `category`, `payment_note?` + files (`payment_qr_file?`, `receipt_file?`) | — | — | Response map | Yes | [request_repository.dart:32](lib/data/repositories/request_repository.dart#L32) |
| 27 | GET | `/requestor/requests` | — | `status?`, `search?` | — | List of request maps | Yes | [request_repository.dart:134](lib/data/repositories/request_repository.dart#L134) |
| 28 | POST | `/expenses/process-payment-qr` | `expense_id`, `qr_image_url`, `qr_data` | — | — | Payment details map | Yes | [request_repository.dart:160](lib/data/repositories/request_repository.dart#L160) |
| 29 | POST | `/requestor/respond-clarification/{id}` | `response_text` | — | `id` | Success response | Yes | [request_repository.dart:182](lib/data/repositories/request_repository.dart#L182) |

---

### Admin / Approver — Approval & Decision Making (8 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 30 | GET | `/admin/dashboard` | — | — | — | Dashboard map | Yes | [admin_repository.dart:10](lib/data/repositories/admin_repository.dart#L10) |
| 31 | GET | `/admin/history` | — | `search?`, `status?` | — | List of maps | Yes | [admin_repository.dart:19](lib/data/repositories/admin_repository.dart#L19) |
| 32 | GET | `/approver/org-expenses` | — | `status?`, `payment_status?` | — | List of expense maps | Yes | [admin_repository.dart:37](lib/data/repositories/admin_repository.dart#L37) |
| 33 | GET | `/approver/org-expenses` | — | `status=rejected` | — | List of expense maps | Yes | [admin_repository.dart:61](lib/data/repositories/admin_repository.dart#L61) |
| 34 | POST | `/approver/expenses/{id}/decision` | `action` ('approve'/'reject'), `rejection_reason?` | — | `id` | Success response | Yes | [admin_repository.dart:65](lib/data/repositories/admin_repository.dart#L65) |
| 35 | POST | `/approver/expenses/{id}/decision` | `action: 'approve'` | — | `id` | Success response | Yes | [admin_repository.dart:85](lib/data/repositories/admin_repository.dart#L85) |
| 36 | POST | `/approver/expenses/{id}/decision` | `action: 'reject'`, `rejection_reason` | — | `id` | Success response | Yes | [admin_repository.dart:89](lib/data/repositories/admin_repository.dart#L89) |
| 37 | POST | `/approver/ask-clarification` | `expense_id`, `question` | — | — | Success response | Yes | [admin_repository.dart:93](lib/data/repositories/admin_repository.dart#L93) |

---

### Accountant — Payment Processing & Reports (9 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 38 | GET | `/accountant/dashboard` | — | — | — | Dashboard map | Yes | [accountant_repository.dart:12](lib/data/repositories/accountant_repository.dart#L12) |
| 39 | POST | `/accountant/balance` | `openingBalance` (>= 0) | — | — | Balance map | Yes | [accountant_repository.dart:23](lib/data/repositories/accountant_repository.dart#L23) |
| 40 | GET | `/accountant/reports/summary` | — | `month?`, `year?`, `category?` | — | Summary map | Yes | [accountant_repository.dart:34](lib/data/repositories/accountant_repository.dart#L34) |
| 41 | GET | `/accountant/analytics/spend` | — | `time_range?`, `department?`, `category?` | — | Analytics map | Yes | [accountant_repository.dart:51](lib/data/repositories/accountant_repository.dart#L51) |
| 42 | GET | `/accountant/reports/export/csv` | — | `start_date?`, `end_date?`, `category?` | — | Binary (List<int>) | Yes | [accountant_repository.dart:66](lib/data/repositories/accountant_repository.dart#L66) |
| 43 | GET | `/accountant/reports/export/pdf` | — | `start_date?`, `end_date?`, `category?` | — | Binary (List<int>) | Yes | [accountant_repository.dart:70](lib/data/repositories/accountant_repository.dart#L70) |
| 44 | GET | `/accountant/expenses/pending-payments` | — | — | — | `items[]`/`payments[]`, `total`, `page`, `size` | Yes | [accountant_repository.dart:94](lib/data/repositories/accountant_repository.dart#L94) |
| 45 | GET | `/accountant/expenses/paid` | — | `page?`, `size?` | — | `items[]`/`payments[]`, `total`, `page`, `size` | Yes | [accountant_repository.dart:113](lib/data/repositories/accountant_repository.dart#L113) |
| 46 | GET | `/accountant/expenses/pending-payments` | — | — | — | PaymentResponse: `total`, `page`, `size`, `items[]` | Yes | [accountant_repository.dart:136](lib/data/repositories/accountant_repository.dart#L136) |

---

### Payment Processing (8 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 47 | POST | `/payments/record` | `amount`, `payment_method` ('UPI'/'CASH'/'CUSTOM'), `transaction_id?`, `note?`, `timestamp` | — | — | Success response | Yes | [payment_repository.dart:12](lib/data/repositories/payment_repository.dart#L12) |
| 48 | GET | `/payments/history` | — | — | — | List of payment maps | Yes | [payment_repository.dart:34](lib/data/repositories/payment_repository.dart#L34) |
| 49 | POST | `/payments/initiate` | `request_id`, `payee_vpa` (UPI regex), `amount` (> 0), `payee_name?`, `transaction_note?` | — | — | `payment_id`, other fields | Yes | [payment_repository.dart:52](lib/data/repositories/payment_repository.dart#L52) |
| 50 | POST | `/payments/confirm` | `payment_id`, `status`, `upi_txn_id?`, `error_message?` | — | — | Response map | Yes | [payment_repository.dart:90](lib/data/repositories/payment_repository.dart#L90) |
| 51 | GET | `/payments/completed` | — | — | — | `payments[]` | Yes | [payment_repository.dart:117](lib/data/repositories/payment_repository.dart#L117) |
| 52 | POST | `/accountant/expenses/{id}/mark-as-paid` | `payment_method`, `transaction_reference?`, `payment_note?` | — | `id` | Success response | Yes | [payment_repository.dart:136](lib/data/repositories/payment_repository.dart#L136) |
| 53 | GET | `/accountant/payment-methods` | — | — | — | List of method maps | Yes | [payment_repository.dart:168](lib/data/repositories/payment_repository.dart#L168) |
| 54 | GET | `/accountant/expenses/{id}/payment-status` | — | — | `id` | `status`, other fields | Yes | [payment_repository.dart:176](lib/data/repositories/payment_repository.dart#L176) |

---

### Notifications & Device Management (2 endpoints)

| # | Method | Path | Request Body | Query Params | Path Params | Response Fields | Auth | Source |
|---|--------|------|--------------|--------------|-------------|-----------------|------|--------|
| 55 | POST | `/notifications/devices/register` | `token`, `platform` ('android'/'ios'/'web'), `app_version?` | — | — | `success`, `message?` | Yes | [notification_repository.dart:24](lib/data/repositories/notification_repository.dart#L24) |
| 56 | POST | `/notifications/devices/unregister` | `token` | — | — | `success`, `message?` | Yes | [notification_repository.dart:52](lib/data/repositories/notification_repository.dart#L52) |

---

## Summary Statistics

| HTTP Method | Count |
|-------------|-------|
| GET | 23 |
| POST | 26 |
| PATCH | 6 |
| DELETE | 1 |
| **TOTAL** | **56** |

---

## Token Lifecycle & Auth Flow

1. **Obtain:** `POST /auth/login` returns token (`token`, `access_token`, or `auth_token` — client accepts any)
2. **Store:** Persisted in secure storage under key `auth_token`
3. **Inject:** Automatically appended as `Authorization: Bearer <token>` via Dio interceptor
4. **Validate:** On app start, `GET /auth/me` verifies token validity
5. **Cleanup:** On logout, `POST /notifications/devices/unregister` (best-effort)
6. **Session recovery:** If 401 received, `NetworkService` interceptor triggers `AuthService.logout()`

---

## Multipart Upload Implementation

### Endpoint: `POST /requestor/submit`

**Platform detection:** Conditional export pattern
- **Web:** [lib/core/services/web_form_upload_web.dart](lib/core/services/web_form_upload_web.dart) — native XHR + FormData
- **Native:** Dio FormData + MultipartFile

**Text fields:**
- Required: `request_type`, `amount`, `purpose`, `description`, `category`
- Optional: `payment_note`

**Files (multipart):**
- `payment_qr_file` (optional) — single QR image
- `receipt_file` (optional) — multiple allowed for bills

**MIME type detection:** Extension-based mapping (jpg→jpeg, png→png, pdf→pdf, etc.)

**Authorization:** Bearer token via custom header (XHR) or Dio options (native).

---

## Notable items for backend comparison

- **Token field name is ambiguous** at login — client accepts `token`, `access_token`, or `auth_token` from `/auth/login`. The backend should standardize on one.
- **Duplicate `/approver/expenses/{id}/decision` POSTs** exist as separate helpers (approve / reject / generic) — same endpoint, different shapes.
- **`/users/update/{userId}` PATCH** is used with different payload shapes (full profile vs. just `is_active: false` for soft-delete vs. arbitrary map from `user_repository`) — confirm backend accepts partial updates.
- **`/accountant/expenses/pending-payments`** is called from two places with slightly different response parsing (`items[]` vs `payments[]`) — confirm canonical response shape.
- **Multipart upload** at `/requestor/submit` has a web-specific path using raw XHR vs Dio FormData on native — both must produce the same wire format.
- **Base URL is production-hardcoded.** No build-flavor switching; dev URLs are commented out.

---

## Development Environment Configuration

**Active:** Production (`https://cashora.nxsys.in`)

**Commented alternatives (for local testing):**
- Android Emulator: `http://10.0.2.2:8000`
- iOS Simulator: `http://127.0.0.1:8000`
- Local Network: `http://192.168.0.149:8000`

**To switch:** Edit [lib/core/config/app_config.dart:16](lib/core/config/app_config.dart#L16).

---

## Files Scanned

### Configuration
- `lib/core/config/app_config.dart`

### Services
- `lib/core/services/network_service.dart`
- `lib/core/services/auth_service.dart`
- `lib/core/services/fcm_service.dart`
- `lib/core/services/qr_service.dart`
- `lib/core/services/payment_status_service.dart`
- `lib/core/services/web_form_upload_web.dart`
- `lib/core/services/web_form_upload.dart`

### Repositories
- `lib/data/repositories/auth_repository.dart`
- `lib/data/repositories/user_repository.dart`
- `lib/data/repositories/admin_repository.dart`
- `lib/data/repositories/organization_repository.dart`
- `lib/data/repositories/department_repository.dart`
- `lib/data/repositories/request_repository.dart`
- `lib/data/repositories/payment_repository.dart`
- `lib/data/repositories/accountant_repository.dart`
- `lib/data/repositories/notification_repository.dart`

### Models
- `lib/data/models/user_model.dart`
- `lib/data/models/payment_response_model.dart`
- `lib/data/models/accountant_dashboard_model.dart`
