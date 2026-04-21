# Requestor and Admin Flow Backend API Requirements

This document outlines the required data fields and mapping logic that the backend needs to provide for the Requestor and Admin flows to correctly populate the UI components.

## 1. Requestor Flow

### 1A. Requestor Dashboard
**Endpoint Suggestion:** `GET /api/requestor/dashboard`

**Required Fields:**
*   **`user`** (Object)
    *   `shortName` (String): Used for greeting (e.g., "Hello, Sarah!").
*   **`monthlyExpense`** (Object)
    *   `amountSpent` (Number/Decimal): the total amount spent this month (e.g., 350.50).
    *   `monthlyLimit` (Number/Decimal): the maximum authorized limit for the month (e.g., 1000.00).
    *   `progressRatio` (Number/Decimal): a value from `0.0` to `1.0` indicating how much of the limit is used (e.g., 0.35). (Can also be calculated on the frontend if both amounts are provided).
*   **`pendingApprovals`** (Object)
    *   `pendingCount` (Integer): number of requests currently waiting for manager/admin approval.
*   **`recentRequests`** (Array of Objects) - The 3 to 5 most recent requests for the dashboard.
    *   `id` (String): Request identifier.
    *   `title` or `purpose` (String): Short title for the expense (e.g., "Client Lunch").
    *   `date` (String): Action date or creation date. (Frontend uses it directly or formats it if ISO).
    *   `amount` (Number/Decimal): The cost.
    *   `status` (String): E.g., "Approved", "Rejected", "Pending". Determines UI colors on the request card.
    *   `category` (String) [Optional]: Frontend uses keywords in title (e.g. "food", "taxi") to paint icons, but passing a structured category name improves accuracy.

---

### 1B. Requestor History (My Requests)
**Endpoint Suggestion:** `GET /api/requestor/requests`
*(Note: Supports Search queries and Status Filters ("All", "Pending", "Clarification", "Approved", "Rejected", "Unpaid"). Could be filtered entirely on backend or frontend).*

**Required Fields (Array of Request Objects):**
*   `id` (String): Request ID.
*   `purpose` or `title` (String): Request context (e.g., "Flight to NY").
*   `date` (String): Date of the transaction.
*   `category` (String): General category. Defaults to inferring from title if not strictly provided.
*   `amount` (Number/Decimal): Value of the claim.
*   `status` (String): Must specifically map to one of: `"pending"`, `"approved"`, `"auto_approved"`, `"rejected"`, `"clarification"`.
*   `rejection_reason` (String) [Present conditionally]: If status is `"rejected"`, this message specifies why (e.g., "Missing receipt attachment").

---

## 2. Admin Flow

### 2A. Admin Dashboard
**Endpoint Suggestion:** `GET /api/admin/dashboard`

**Required Fields:**
*   **`user`** (Object)
    *   `shortName` (String): Used for greeting.
*   **`overview`** (Object)
    *   `pendingRequestsCount` (Integer): Count of requests currently waiting in the admin's queue (e.g., 12).
    *   `approvedAmount` (Number/Decimal): Total monetary value of requests approved (e.g., 1250.00).

---

### 2B. Admin History
**Endpoint Suggestion:** `GET /api/admin/history`

**Required Fields (Array of History Objects):**
*   `request_id` or `id` (String): Request's unique identifier.
*   `updated_at` or `created_at` (String): ISO Date String indicating when the admin action was taken.
*   `amount` (Number/Decimal): Expense amount.
*   **`requestor`** (Object) - The user who submitted the request.
    *   `first_name` (String): Requestor's first name.
    *   `last_name` (String): Requestor's last name.
    *   `email` (String): Optional fallback if names are blank.
*   `user` (String) [Fallback]: If `requestor` object is missing, frontend tries to read a flat string (e.g., "John Doe").
*   `purpose` or `title` (String): Short description of the expense.
*   `status` (String): Must map to one of: `"approved"`, `"auto_approved"`, `"rejected"`, `"clarification"`.
