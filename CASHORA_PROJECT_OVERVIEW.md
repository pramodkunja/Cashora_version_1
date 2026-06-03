# Cashora — Project Overview

**Prepared for:** Manager review
**Prepared by:** Sai Kumar Bonakurthi
**Date:** 26 May 2026
**Status:** In active development (v1.0.0 build 8)

---

## 1. Executive Summary

**Cashora** is an internal mobile application that digitises and automates the end-to-end **petty cash management** workflow for organizations. It replaces the traditional paper-slip / WhatsApp / Excel-based process with a single auditable system that handles **request submission, approval, payment, and reconciliation** with role-based access for **Requestors, Admins, and Accountants**.

The application is built in **Flutter** (cross-platform iOS + Android from a single codebase) and integrates with our own backend APIs and **PhonePe** for UPI-based payouts.

---

## 2. What is Cashora?

Cashora is a three-sided workflow application:

| Role | Who | What they do in the app |
|---|---|---|
| **Requestor** | Employees | Raise petty-cash requests with bills, track status, respond to clarifications, view monthly spend. |
| **Admin** | Managers / Approvers | Review requests, approve / reject / ask for clarification, manage users, set spend limits, view history. |
| **Accountant** | Finance team | Process approved requests, initiate UPI / bank payouts via PhonePe, reconcile and report. |

A request flows through a single, audited lifecycle:

```
Requestor submits → Admin reviews → (Clarification loop if needed) → Approved → Accountant pays → Closed
```

Every transition is logged, timestamped, and visible to the relevant role with push-notification alerts.

---

## 3. Why We Need Cashora — The Business Case

The existing petty-cash process is **manual, slow, and audit-unfriendly**. Cashora addresses the following pain points:

### 3.1 Operational problems it solves

- **No single source of truth** — requests today are spread across paper slips, WhatsApp messages, and Excel sheets, making month-end reconciliation painful.
- **Slow approvals** — managers have no inbox of pending requests; employees chase approvals over chat.
- **No spend controls** — there is no enforced per-request / monthly / departmental limit.
- **Weak audit trail** — there is no provable record of who approved what, when, or why.
- **Manual payouts** — finance keys UPI IDs into PhonePe by hand, with no link back to the originating request.
- **No visibility into spend patterns** — leadership cannot see category-wise or department-wise spend trends.

### 3.2 Business value delivered

- **Faster cycle time** from request to payout (target: under 24 hours for routine items).
- **Enforced spending policy** through configurable per-request, monthly, category, and department limits.
- **Complete audit trail** — every state change is timestamped with the actor, suitable for internal and statutory audit.
- **Digital proof of payment** — each payout stores the PhonePe transaction ID and is linked to the originating request and bill.
- **Real-time analytics** for finance and leadership.
- **Role-based security** — sensitive actions (payments, user management) are restricted by role and protected with biometric re-auth.

---

## 4. What Has Been Built So Far

The application is **functionally complete end-to-end** for all three roles. Major modules already shipped:

### 4.1 Authentication & Security
- Email/password login with token-based sessions
- Forgot-password → OTP → reset flow
- **Biometric lock** (fingerprint / Face ID) on app resume and cold start
- Route-level **RBAC middleware** — every protected screen verifies role + session before render
- Secure token storage (`flutter_secure_storage`)
- Auto-logout on token expiry

### 4.2 Requestor Module
- Multi-step **Create Request wizard** (type → details → review → submit) with bill/receipt upload
- **My Requests** list with status filters (Pending / Approved / Rejected / Clarification / Paid)
- Read-only request details with full timeline
- **Provide Clarification** flow when an admin asks for more information
- **Monthly Spending** view with category breakdown and limit tracking

### 4.3 Admin Module
- Admin dashboard with pending-approvals counter and quick stats
- **Approvals queue** with three outcomes: Approve / Reject (with reason) / Request Clarification
- Full clarification thread view between admin and requestor
- **User management** — add, edit, deactivate users; assign roles, departments, spending limits
- **Set Limits** — per-request, monthly per-user, category-wise, department-wise
- **History** view with date / requestor / amount / status filters

### 4.4 Accountant Module
- Accountant dashboard with pending-payment counters
- **Payments view** with Pending / In Progress / Completed tabs
- End-to-end **Payment Processing flow**: request details → bill details → verify → confirm → success/failure
- **PhonePe UPI integration** for payouts (validate UPI, initiate, track transaction ID)
- **QR scanning** for UPI IDs (using `mobile_scanner`)
- **Cash Flow History** with completed-payment drill-down
- **Spend Analytics** — category, department, monthly trends, top spenders
- **Financial Reports** with date-range filters

### 4.5 Cross-Cutting Features
- **Push notifications** via Firebase Cloud Messaging — separate notification types per role (new request, approval, clarification, payment success/failure, etc.)
- **In-app notification center** per role
- Profile management — edit name, phone, photo
- Settings — notification preferences, theme (Light / Dark / System), change password, biometric toggle
- **Dark mode** across the entire app
- **Responsive layouts** via `flutter_screenutil` for all phone sizes
- Shimmer loading states, pull-to-refresh, paginated lists

### 4.6 Technical Foundation
- **Flutter 3.x** + **GetX 4.7** (state management, DI, navigation)
- **Dio** HTTP client with interceptors for auth + error handling
- **Firebase Core + FCM** for push
- Clean architecture: Views → Controllers → Repositories → Services → API
- Centralized error handling and route guards
- ~10,000+ lines of production Dart code, organised into 14 feature modules

---

## 5. What I Am Currently Working On

Active work in the current branch (148 files modified, +10.8k / -7.2k lines uncommitted):

### 5.1 Payment Flow Hardening
- Polishing the multi-step accountant payment flow (bill details → verify → confirm → mark-as-paid → completed details).
- Fixing edge cases in PhonePe integration (UPI validation, retry on failure, transaction reconciliation).
- Last commit on `main` was *"made changes in payment flow"* — this work is ongoing.

### 5.2 UI / UX Polish Pass
- Consistency pass across all three role dashboards (last commit: *"UI changes"*).
- Standardising the search bar, date pickers, and bottom-bar components used across modules.
- Tightening the analytics and financial-report screens.

### 5.3 Defensive Dependency Injection (just shipped)
- Fixed a crash where the read-only request-details screen could be opened from a context where its repository wasn't yet registered with GetX, causing a `RequestRepository not found` error.
- Added a self-contained binding to the route so the screen is reachable from any entry point — including deep links from push notifications.

### 5.4 Platform Configuration
- Android `build.gradle.kts` and `AndroidManifest.xml` updates (Firebase config, permissions).
- iOS `Info.plist`, `AppDelegate.swift`, `Runner.xcodeproj` updates (push entitlements, Firebase setup).
- Updating `app_config.dart` for environment-aware base URLs (dev / staging / prod).

### 5.5 Department & Organization Setup
- Wiring up the `organization_setup` module so a new tenant can be bootstrapped on first launch.
- Expanding the admin `department_controller` to support department-scoped limits and reporting.

### 5.6 Backend Contract Alignment
- Multiple `BACKEND_REQUIREMENTS_*.md` documents in the repo are being kept in sync with the backend team to lock down API contracts for admin, accountant, and requestor flows.
- Auditing endpoints used by each repository (`api-audit.md`) to remove dead routes and align payload shapes.

---

## 6. Future Targets

### 6.1 Near-term (next 4–6 weeks)
- **Stabilise the payment flow** and complete the PhonePe edge-case handling.
- **End-to-end QA pass** with the backend team on a shared staging environment.
- **First internal pilot release** with one department to validate the workflow with real users.
- Replace the placeholder QR-scan-from-file implementation with a production package (`qr_code_tools` or equivalent).
- Improve **error / offline UX** — better empty states, retry banners, offline cache for recently-viewed requests.

### 6.2 Medium-term (next quarter)
- **PDF / Excel export** for financial reports (already scaffolded in the UI).
- **Receipt OCR** — auto-extract amount and vendor from uploaded bills to reduce manual entry.
- **Bulk approval / bulk payout** for accountants handling many small requests.
- **Web platform support** — the codebase already contains `web_form_upload_web.dart`, indicating a path to launching a web admin console from the same codebase.
- **Multi-organization (tenant) support** so multiple business units can run on the same backend with isolated data.
- **Production hardening** — crash reporting (Firebase Crashlytics), analytics, performance monitoring.

### 6.3 Long-term opportunities
- **Approval policies / workflow engine** — configurable multi-level approvals (e.g., amounts above ₹X need second-level sign-off).
- **Vendor master & repeat-payee shortcuts** for accountants.
- **Budget vs actuals dashboard** for leadership.
- **Integration with accounting systems** (Tally / Zoho Books / QuickBooks) for automatic ledger entries.
- **Multi-currency** support if the organization expands across geographies.
- **GST-compliant invoice handling** and statutory report generation.

---

## 7. Technology Stack at a Glance

| Layer | Technology |
|---|---|
| Mobile framework | Flutter 3.x (Dart 3.9) |
| State management & DI | GetX 4.7 |
| Networking | Dio 5.9 |
| Secure storage | flutter_secure_storage |
| Push notifications | Firebase Cloud Messaging + flutter_local_notifications |
| Biometric auth | local_auth |
| Charts | fl_chart |
| QR / camera | mobile_scanner |
| File handling | file_picker, image_picker, open_file, path_provider |
| UI scaling | flutter_screenutil |
| Payments | PhonePe UPI (server-side integration) |

---

## 8. Summary for Management

- **What:** A role-based, end-to-end petty-cash management app for Requestors, Admins, and Accountants.
- **Why:** Replace a manual, slow, audit-unfriendly process with a controlled, auditable, real-time digital workflow.
- **Status:** Functionally complete across all three roles; currently in the polish + integration phase.
- **Next milestone:** Internal pilot with one department, followed by company-wide rollout.
- **Strategic upside:** Same codebase can extend to a web admin console, multi-tenant SaaS, and richer finance-system integrations.

---

*Prepared from the current state of the `main` branch of the Cashora repository (v1.0.0 build 8).*
