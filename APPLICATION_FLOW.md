# Cashora - Petty Cash Management System
## Complete Application Flow Documentation

---

## 🎯 Application Overview

**Cashora** is a comprehensive petty cash management system built with Flutter and GetX. It manages the complete lifecycle of cash requests from creation to payment, with role-based access control for three user types: **Requestors**, **Admins**, and **Accountants**.

---

## 👥 User Roles

### 1. **Requestor** (Employee)
- Creates and submits cash requests
- Tracks request status
- Provides clarifications when requested
- Views monthly spending analytics

### 2. **Admin** (Manager/Approver)
- Reviews and approves/rejects requests
- Requests clarifications from requestors
- Manages users (add, edit, deactivate)
- Sets spending limits
- Views request history

### 3. **Accountant** (Finance Team)
- Processes approved payments
- Initiates UPI/bank transfers
- Tracks payment status
- Views financial analytics and reports
- Manages completed transactions

---

## 🚀 Application Startup Flow

```
1. App Launch (main.dart)
   ↓
2. Initialize Services
   - StorageService (local data)
   - NetworkService (API calls)
   - AuthService (authentication)
   - BiometricService (fingerprint/face ID)
   - AppLifecycleManager (app state)
   ↓
3. Splash Screen (/splash)
   - Check if user is logged in
   - Check if organization is set up
   ↓
4. Route Decision:
   ├─ Not Logged In → Login Screen
   ├─ Logged In + Session Not Verified → Lock Screen (Biometric)
   └─ Logged In + Verified → Role-Based Dashboard
      ├─ Requestor → Requestor Dashboard
      ├─ Admin/Super Admin → Admin Dashboard
      └─ Accountant → Accountant Dashboard
```

---

## 🔐 Authentication Flow

### Login Process
```
/login (LoginView)
   ↓
Enter Email & Password
   ↓
API Call: POST /auth/login
   ↓
Success:
   ├─ Store auth token
   ├─ Store user data
   ├─ Check biometric preference
   └─ Navigate to Role-Based Dashboard
   
Failure:
   └─ Show error message
```

### Forgot Password Flow
```
/login → "Forgot Password?"
   ↓
/forgot-password (ForgotPasswordView)
   ↓
Enter Email
   ↓
API Call: POST /auth/forgot-password
   ↓
/otp-verification (OtpVerificationView)
   ↓
Enter 6-digit OTP
   ↓
Verify OTP
   ↓
/reset-password (ResetPasswordView)
   ↓
Enter New Password + Confirm
   ↓
/reset-password-success
   ↓
Navigate to Login
```

### Biometric Lock Flow
```
App Resume/Startup (if enabled)
   ↓
/lock (LockView)
   ↓
Biometric Authentication Prompt
   ↓
Success → Navigate to Dashboard
Failure → Retry or Logout
```

---

## 📱 REQUESTOR FLOW

### Dashboard
```
/requestor (RequestorMainView)
   ↓
Bottom Navigation:
   ├─ Home (RequestorDashboardView)
   ├─ My Requests (MyRequestsView)
   └─ Profile (ProfileView)
```

### Home Dashboard Features
- Welcome message with user name
- Quick action buttons:
  - Create New Request
  - View My Requests
  - Monthly Spending
- Recent requests overview
- Spending statistics

### Create Request Flow
```
Dashboard → "Create New Request"
   ↓
/create-request/type (SelectRequestTypeView)
   ↓
Select Request Type:
   ├─ Travel Expense
   ├─ Office Supplies
   ├─ Client Entertainment
   ├─ Miscellaneous
   └─ Other
   ↓
/create-request/details (RequestDetailsView)
   ↓
Fill Request Details:
   ├─ Amount (₹)
   ├─ Description
   ├─ Category
   ├─ Date
   ├─ Upload Bill/Receipt (optional)
   └─ Additional Notes
   ↓
/create-request/review (ReviewRequestView)
   ↓
Review All Details
   ↓
Submit Request
   ↓
API Call: POST /requests/create
   ↓
/create-request/success (RequestSuccessView)
   ↓
Show Request ID & Status
   ↓
Navigate to My Requests
```

### My Requests View
```
/my-requests (MyRequestsView)
   ↓
Display Requests with Filters:
   ├─ All
   ├─ Pending (yellow)
   ├─ Approved (green)
   ├─ Rejected (red)
   ├─ Clarification Required (orange)
   └─ Paid (blue)
   ↓
Tap on Request
   ↓
/request-details-read (RequestDetailsReadView)
   ↓
View Complete Request Details:
   ├─ Request ID
   ├─ Amount
   ├─ Status
   ├─ Description
   ├─ Attachments
   ├─ Timeline
   └─ Admin/Accountant Comments
   
If Status = "Clarification Required":
   ↓
   "Provide Clarification" Button
   ↓
   /requestor/clarification (ProvideClarificationView)
   ↓
   View Admin's Question
   ↓
   Type Response + Upload Documents
   ↓
   Submit Clarification
   ↓
   API Call: POST /requests/{id}/clarification
   ↓
   Status changes to "Pending"
```

### Monthly Spending View
```
/monthly-spent (MonthlySpentView)
   ↓
Display:
   ├─ Total spent this month
   ├─ Spending limit (if set)
   ├─ Category-wise breakdown
   ├─ Month-over-month comparison
   └─ Spending trends chart
```

---

## 👔 ADMIN FLOW

### Dashboard
```
/admin/dashboard (AdminMainView)
   ↓
Bottom Navigation:
   ├─ Dashboard (AdminDashboardView)
   ├─ Approvals (AdminApprovalsView)
   ├─ History (AdminHistoryView)
   └─ Profile (ProfileView)
```

### Admin Dashboard Features
- Welcome message
- Quick stats:
  - Pending approvals count
  - Approved today
  - Total requests this month
  - Total amount approved
- Quick actions:
  - View Pending Approvals
  - Manage Users
  - Set Spending Limits
  - View History

### Approvals Flow
```
/admin/approvals (AdminApprovalsView)
   ↓
Display Pending Requests List
   ├─ Request ID
   ├─ Requestor Name
   ├─ Amount
   ├─ Category
   ├─ Date
   └─ Status Badge
   ↓
Tap on Request
   ↓
/admin/request-details (AdminRequestDetailsView)
   ↓
View Complete Request:
   ├─ Requestor details
   ├─ Request amount
   ├─ Description
   ├─ Category
   ├─ Attachments/Bills
   ├─ Request date
   └─ Current status
   ↓
Admin Actions:
   ├─ Approve
   │   ↓
   │   Add Comments (optional)
   │   ↓
   │   Confirm Approval
   │   ↓
   │   API Call: POST /requests/{id}/approve
   │   ↓
   │   /admin/success (AdminSuccessView)
   │   ↓
   │   Status → "Approved" (sent to Accountant)
   │
   ├─ Reject
   │   ↓
   │   Enter Rejection Reason (required)
   │   ↓
   │   Confirm Rejection
   │   ↓
   │   API Call: POST /requests/{id}/reject
   │   ↓
   │   /admin/rejection-success (AdminRejectionSuccessView)
   │   ↓
   │   Status → "Rejected" (notify requestor)
   │
   └─ Request Clarification
       ↓
       /admin/clarification (AdminClarificationView)
       ↓
       Enter Question/Clarification Needed
       ↓
       Submit
       ↓
       API Call: POST /requests/{id}/clarification-request
       ↓
       /admin/clarification-success
       ↓
       Status → "Clarification Required"
       ↓
       Monitor Clarification Status:
       /admin/clarification-status (AdminClarificationStatusView)
       ↓
       View Conversation:
          ├─ Admin's question
          ├─ Requestor's response
          ├─ Attachments
          └─ Timeline
       ↓
       After Clarification Received:
          └─ Return to Request Details to Approve/Reject
```

### User Management Flow
```
Dashboard → "Manage Users"
   ↓
/admin/users (AdminUserListView)
   ↓
Display All Users:
   ├─ Name
   ├─ Email
   ├─ Role
   ├─ Status (Active/Inactive)
   └─ Actions (Edit/Deactivate)
   ↓
Actions:
   ├─ Add New User
   │   ↓
   │   /admin/users/add (AdminAddUserView)
   │   ↓
   │   Fill Form:
   │   ├─ Name
   │   ├─ Email
   │   ├─ Phone
   │   ├─ Role (Requestor/Admin/Accountant)
   │   ├─ Department
   │   └─ Spending Limit (if Requestor)
   │   ↓
   │   Submit
   │   ↓
   │   API Call: POST /users/create
   │   ↓
   │   /admin/users/success
   │
   ├─ Edit User
   │   ↓
   │   /admin/users/edit (AdminEditUserView)
   │   ↓
   │   Modify user details
   │   ↓
   │   API Call: PUT /users/{id}
   │   ↓
   │   /admin/users/success
   │
   └─ Deactivate User
       ↓
       /admin/users/deactivate (AdminDeactivateUserView)
       ↓
       Confirm deactivation
       ↓
       API Call: POST /users/{id}/deactivate
       ↓
       User status → Inactive
```

### Set Spending Limits
```
Dashboard → "Set Limits"
   ↓
/admin/set-limits (AdminSetLimitsView)
   ↓
Configure Limits:
   ├─ Per Request Limit
   ├─ Monthly Limit per User
   ├─ Category-wise Limits
   └─ Department-wise Limits
   ↓
Save Changes
   ↓
API Call: POST /settings/limits
```

### History View
```
/admin/history (AdminHistoryView)
   ↓
Display All Requests:
   ├─ Filter by Status
   ├─ Filter by Date Range
   ├─ Filter by Requestor
   └─ Filter by Amount Range
   ↓
View Request Details (read-only)
```

---

## 💰 ACCOUNTANT FLOW

### Dashboard
```
/accountant-dashboard (AccountantDashboardView)
   ↓
Bottom Navigation:
   ├─ Home (AccountantHomeView)
   ├─ Payments (AccountantPaymentsView)
   ├─ Analytics (SpendAnalyticsView)
   └─ Profile (AccountantProfileView)
```

### Accountant Home Features
- Welcome message
- Quick stats:
  - Pending payments count
  - Paid today
  - Total paid this month
  - Total amount processed
- Quick actions:
  - Process Payments
  - View Analytics
  - Financial Reports

### Payments View
```
/accountant-payments (AccountantPaymentsView)
   ↓
Tabs:
   ├─ Pending (Approved by Admin)
   ├─ In Progress (Payment initiated)
   └─ Completed (Payment successful)
   ↓
Tap on Pending Request
   ↓
Start Payment Flow
```

### Payment Processing Flow
```
/accountant/payment/request-details (PaymentRequestDetailsView)
   ↓
View Request Details:
   ├─ Requestor info
   ├─ Amount
   ├─ Description
   ├─ Admin approval details
   └─ Attachments
   ↓
"Proceed to Payment" Button
   ↓
/accountant/payment/bill-details (BillDetailsView)
   ↓
Enter Payment Details:
   ├─ Payee Name
   ├─ UPI ID / Bank Account
   ├─ Payment Method:
   │   ├─ UPI (PhonePe Integration)
   │   └─ Bank Transfer
   ├─ Amount Confirmation
   └─ Payment Notes
   ↓
"Verify Payment"
   ↓
/accountant/payment/verify (VerifyPaymentView)
   ↓
Review All Details:
   ├─ Payee details
   ├─ Amount
   ├─ Payment method
   └─ Request details
   ↓
"Confirm Payment"
   ↓
/accountant/payment/confirm (ConfirmPaymentView)
   ↓
Final Confirmation Screen
   ↓
Initiate Payment
   ↓
API Call: POST /payments/initiate
   ↓
PhonePe Integration:
   ├─ Validate UPI ID
   ├─ Initiate payout
   ├─ Get transaction ID
   └─ Check payment status
   ↓
Payment Result:
   ├─ Success
   │   ↓
   │   /accountant/payment/success (PaymentSuccessView)
   │   ↓
   │   Display:
   │   ├─ Transaction ID
   │   ├─ Amount paid
   │   ├─ Payee name
   │   ├─ Date & time
   │   └─ Payment method
   │   ↓
   │   Update request status → "Paid"
   │   ↓
   │   Send notification to requestor
   │
   └─ Failure
       ↓
       /accountant/payment/failed (PaymentFailedView)
       ↓
       Display:
       ├─ Error reason
       ├─ Transaction ID (if any)
       └─ Retry option
       ↓
       Options:
       ├─ Retry Payment
       └─ Cancel & Report Issue
```

### Completed Payments View
```
Tap on Completed Request
   ↓
/accountant/payment/completed-details (CompletedRequestDetailsView)
   ↓
View Complete Payment History:
   ├─ Request details
   ├─ Payment details
   ├─ Transaction ID
   ├─ Payment timestamp
   ├─ Payee information
   └─ Payment proof/receipt
```

### Analytics & Reports
```
/accountant/analytics (SpendAnalyticsView)
   ↓
Display:
   ├─ Total spending trends
   ├─ Category-wise breakdown
   ├─ Department-wise spending
   ├─ Monthly comparisons
   └─ Top spenders
   ↓
"View Financial Reports"
   ↓
/accountant/financial-reports (FinancialReportsView)
   ↓
Generate Reports:
   ├─ Date range selection
   ├─ Filter by category/department
   ├─ Export options (PDF/Excel)
   └─ Detailed transaction logs
```

---

## 🔔 Notifications System

### Requestor Notifications
```
/requestor/notifications (RequestorNotificationView)
   ↓
Notification Types:
   ├─ Request Approved
   ├─ Request Rejected
   ├─ Clarification Required
   ├─ Payment Completed
   └─ Status Updates
```

### Admin Notifications
```
/admin/notifications (AdminNotificationView)
   ↓
Notification Types:
   ├─ New Request Submitted
   ├─ Clarification Provided
   ├─ Urgent Approvals
   └─ System Alerts
```

### Accountant Notifications
```
/accountant/notifications (AccountantNotificationView)
   ↓
Notification Types:
   ├─ New Approved Request (ready for payment)
   ├─ Payment Success/Failure
   ├─ Pending Payments Reminder
   └─ Financial Alerts
```

---

## ⚙️ Settings & Profile

### Profile View
```
/profile (ProfileView)
   ↓
Display:
   ├─ User photo
   ├─ Name
   ├─ Email
   ├─ Phone
   ├─ Role
   ├─ Organization details
   └─ Department
   ↓
Actions:
   ├─ Edit Profile
   │   ↓
   │   /edit-profile (EditProfileView)
   │   ↓
   │   Update: Name, Phone, Photo
   │
   └─ Settings
       ↓
       /settings (SettingsView)
```

### Settings Flow
```
/settings (SettingsView)
   ↓
Options:
   ├─ Notifications
   │   ↓
   │   /settings/notifications (NotificationsView)
   │   ↓
   │   Toggle:
   │   ├─ Push notifications
   │   ├─ Email notifications
   │   ├─ SMS alerts
   │   └─ Notification types
   │
   ├─ Appearance
   │   ↓
   │   /settings/appearance (AppearanceView)
   │   ↓
   │   Select:
   │   ├─ Light theme
   │   ├─ Dark theme
   │   └─ System default
   │
   ├─ Change Password
   │   ↓
   │   /settings/change-password (ChangePasswordView)
   │   ↓
   │   Enter:
   │   ├─ Current password
   │   ├─ New password
   │   └─ Confirm new password
   │   ↓
   │   API Call: POST /auth/change-password
   │
   ├─ Biometric Lock
   │   ↓
   │   Enable/Disable fingerprint/face ID
   │
   └─ Logout
       ↓
       Clear session
       ↓
       Navigate to /login
```

---

## 🔒 Security & Middleware

### Route Guard (RouteGuard Middleware)
```
Every Protected Route
   ↓
Check:
   1. Is user logged in?
      └─ No → Redirect to /login
   
   2. Is session verified (biometric)?
      └─ No → Redirect to /lock
   
   3. Does user have permission for this route?
      ├─ Admin routes → Only Admin/Super Admin
      ├─ Accountant routes → Only Accountant
      └─ Unauthorized → Show error & redirect to dashboard
   
   4. All checks passed
      └─ Allow access
```

### Session Management
- Token stored in secure storage
- Auto-refresh token before expiry
- Biometric re-authentication on app resume
- Auto-logout on token expiration

---

## 📊 Request Lifecycle

```
1. CREATED (Requestor)
   ↓
   Requestor submits new request
   ↓
2. PENDING (Admin Review)
   ↓
   Admin reviews request
   ↓
   Decision:
   ├─ APPROVED → Go to step 4
   ├─ REJECTED → End (notify requestor)
   └─ CLARIFICATION REQUIRED → Go to step 3
   
3. CLARIFICATION REQUIRED
   ↓
   Requestor provides clarification
   ↓
   Return to step 2 (Admin Review)
   
4. APPROVED (Accountant Queue)
   ↓
   Accountant processes payment
   ↓
5. PAYMENT IN PROGRESS
   ↓
   PhonePe/Bank transfer initiated
   ↓
   Result:
   ├─ SUCCESS → Go to step 6
   └─ FAILED → Retry or report issue
   
6. PAID (Completed)
   ↓
   Request lifecycle complete
   ↓
   Notify requestor
```

---

## 🛠️ Technical Architecture

### State Management
- **GetX** for reactive state management
- Controllers for each module
- Dependency injection via Get.put/Get.lazyPut

### Services Layer
- **AuthService**: Authentication & session management
- **NetworkService**: API calls & error handling
- **StorageService**: Local data persistence
- **BiometricService**: Fingerprint/Face ID
- **AppLifecycleManager**: App state monitoring

### Data Layer
- **Repositories**: Data access abstraction
  - AuthRepository
  - PaymentRepository
  - UserRepository
- **Models**: Data structures
- **API Integration**: RESTful backend

### Navigation
- **GetX Navigation**: Declarative routing
- **Middleware**: Route guards & authentication
- **Deep Linking**: Support for notification navigation

---

## 🎨 UI/UX Features

- **Responsive Design**: ScreenUtil for all screen sizes
- **Dark Mode**: Full theme support
- **Animations**: Smooth transitions
- **Loading States**: Shimmer effects
- **Error Handling**: User-friendly error messages
- **Offline Support**: Local caching
- **Pull to Refresh**: Update data
- **Infinite Scroll**: Paginated lists

---

## 📱 Key Screens Summary

| Screen | Route | Role | Purpose |
|--------|-------|------|---------|
| Splash | /splash | All | App initialization |
| Lock | /lock | All | Biometric authentication |
| Login | /login | All | User authentication |
| Forgot Password | /forgot-password | All | Password recovery |
| Requestor Dashboard | /requestor | Requestor | Main home screen |
| Create Request | /create-request/* | Requestor | Submit new request |
| My Requests | /my-requests | Requestor | View request history |
| Admin Dashboard | /admin/dashboard | Admin | Approval management |
| Admin Approvals | /admin/approvals | Admin | Review pending requests |
| User Management | /admin/users/* | Admin | Manage users |
| Accountant Dashboard | /accountant-dashboard | Accountant | Payment processing |
| Payment Flow | /accountant/payment/* | Accountant | Process payments |
| Analytics | /accountant/analytics | Accountant | Financial reports |
| Profile | /profile | All | User profile |
| Settings | /settings | All | App configuration |

---

## 🔄 Data Flow

```
User Action (View)
   ↓
Controller (Business Logic)
   ↓
Repository (Data Access)
   ↓
Network Service (API Call)
   ↓
Backend API
   ↓
Response
   ↓
Repository (Parse & Cache)
   ↓
Controller (Update State)
   ↓
View (UI Update)
```

---

## 📝 Notes

- All monetary amounts are in Indian Rupees (₹)
- PhonePe integration for UPI payments
- Real-time status updates via notifications
- Audit trail for all transactions
- Role-based access control (RBAC)
- Secure token-based authentication
- Biometric lock for enhanced security

---

**Last Updated**: February 2026
**Version**: 1.0
**Framework**: Flutter 3.x + GetX
