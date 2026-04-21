# Backend API Requirements for Accountant Module

This document outlines the required data fields and models the backend team needs to provide for the Accountant Homepage and the Reports/Analytics pages to function correctly based on the current frontend UI structure.

## 1. Accountant Homepage
**Endpoint Suggestion:** `GET /api/accountant/dashboard`

### Required Fields:
*   **`user`** (Object)
    *   `shortName` (String): The name of the accountant (e.g., "Sarah").
*   **`accountOverview`** (Object)
    *   `inHandCash` (Number/Decimal): The current available cash in hand (e.g., 4250.00).
    *   `inHandCashGrowth` (String/Number): The percentage growth vs yesterday (e.g., "+2.4%").
    *   `openBalance` (Number/Decimal): The starting balance (e.g., 5000.00).
    *   `closingBalance` (Number/Decimal): The ending/closing balance (e.g., 4250.00).
*   **`tasksSummary`** (Object)
    *   `pendingPaymentsCount` (Integer): The number of payments waiting to be processed (e.g., 5).
*   **`todayTransactions`** (Array of Objects) - List of recent/today's transactions.
    *   `id` (String): Unique transaction identifier.
    *   `title` (String): Title or Category of the transaction (e.g., "Office Supplies").
    *   `subtitle` (String): Vendor name and formatted time (e.g., "Staples • 10:45 AM"). Alternately, send `vendorName` and `timestamp` and the frontend will format it.
    *   `amount` (Number/Decimal): Transaction amount. Can be negative for expenses (e.g., -45.00).
    *   `iconType` (String): A category string used to map to the correct Flutter icon (e.g., "PRINT", "RESTAURANT", "TRAVEL").

*(Note: The "Amount In" and "Amount Out" fields have been removed from the UI and are no longer required).*

---

## 2. Financial Reports Page
**Endpoint Suggestion:** `GET /api/accountant/reports/summary`

### Required Fields:
*   **`filters`** (Object)
    *   `categories` (Array of Strings): Available categories for the filter dropdown (e.g., ["All Categories", "Office Supplies", "Travel"]).
*   **`previewSummary`** (Object) - Data for the generated report preview table.
    *   `monthYear` (String): Formatted month and year of the report (e.g., "Oct 2023").
    *   `totalExpenses` (Number/Decimal): The total aggregated amount of expenses (e.g., 546.75).
    *   `transactions` (Array of Objects) - List of table rows.
        *   `date` (String): Formatted date (e.g., "Oct 24").
        *   `category` (String): Associated category (e.g., "Office Supplies").
        *   `amount` (Number/Decimal): The row amount (e.g., 120.50).

*(Note: Action hooks for `Export CSV` and `Export PDF` require corresponding backend endpoints to generate and return these files based on the requested date range and category).*

---

## 3. Spend Analytics Page
**Endpoint Suggestion:** `GET /api/accountant/analytics/spend`

### Required Fields:
*   **`filters`** (Object)
    *   `timeRanges` (Array of Strings): e.g., ["This Month", "Last Month"].
    *   `departments` (Array of Strings): e.g., ["Department", "Sales", "IT"].
    *   `categories` (Array of Strings): e.g., ["Category", "Travel", "Food"].
*   **`scoreCards`** (Object)
    *   `totalSpend` (Object)
        *   `amount` (Number/Decimal): Total spend (e.g., 4250.00).
        *   `trendText` (String): e.g., "+12%".
        *   `isPositiveTrend` (Boolean): Determines the color mapping (green vs red).
    *   `avgTransaction` (Object)
        *   `amount` (Number/Decimal): Average transaction size (e.g., 85.00).
        *   `trendText` (String): e.g., "+2.5%".
        *   `isPositiveTrend` (Boolean): Determines the color mapping.
*   **`monthlyTrend`** (Object) - Data for the Line Graph.
    *   `trendSummaryText` (String): e.g., "+15% vs last mo".
    *   `isPositiveTrend` (Boolean): Affects the color of the text.
    *   `graphData` (Array of Objects) - X and Y axis points.
        *   `weekOrDay` (Number/String): The X-axis plot point (e.g., week number 1, 2, 3, 4).
        *   `amount` (Number): The Y-axis value representing the spend amount for that point.
*   **`spendByCategory`** (Array of Objects) - Data for the Pie Chart.
    *   `categoryName` (String): e.g., "Office Supplies", "Travel", "Food & Bev", "Others".
    *   `percentage` (Number): The share out of 100% (e.g., 45 for 45%).
    *   *(Note: The frontend handles the color rendering based on standard app tokens, but the list should be ordered descending by size).*
*   **`departmentSpend`** (Array of Objects) - Data for the Progress/Bar Rows.
    *   `departmentName` (String): e.g., "Sales", "Engineering", "Human Resources".
    *   `amount` (Number/Decimal): The total spent by this department (e.g., 1850).
    *   `progressRatio` (Number): A decimal between 0.0 and 1.0 representing this department's spend relative to the highest spending department (e.g., 0.8 for 80% bar fill).

---

## 4. Update Daily Balance
**Endpoint Suggestion:** `POST /api/accountant/balance`
*Triggered when the accountant fills out the 'Update Balances' popup upon opening the app for the day.*

### Required Payload (Request Body):
*   **`openingBalance`** (Number/Decimal): The new opening balance submitted by the accountant (e.g., 5000.00).
    *   *(Note: The frontend currently gathers a single input for this action. Upon successful HTTP 200 response, the frontend will automatically re-fetch the Accountant Dashboard (`GET /api/accountant/dashboard`) to refresh the UI with the updated `openBalance`).*
