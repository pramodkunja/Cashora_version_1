class AppText {
  // Common
  static const String appName = 'Cash App';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String loading = 'Loading...';
  // Common placeholders
  static const String comingSoon = 'Coming Soon';
  static const String profileUnderConstruction =
      'Profile screen is under construction';

  // Auth
  static const String welcomeBack = 'Welcome Back';
  static const String signInSubtitle = 'Sign in to manage your expenses';
  static const String emailAddress = 'Email Address';
  static const String enterEmail = 'Enter your email';
  static const String password = 'Password';
  static const String enterPassword = 'Enter your password';
  static const String forgotPassword = 'Forgot Password?'; // As link
  static const String forgotPasswordTitle = 'Forgot Password?'; // As title
  static const String forgotPasswordSubtitle =
      'No worries! Enter your email or phone number linked with your account.';
  static const String emailOrPhone = 'Email or Phone';
  static const String enterEmailOrPhone = 'Enter email or phone';
  static const String sendCode = 'Send Code';
  static const String signIn = 'Sign In';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signUp = 'Sign Up';

  // Requestor Dashboard
  static const String helloUser = 'Hello,';
  static const String newRequest = 'New Request';
  static const String monthlyExpense = 'Monthly Expense';
  static const String thisMonthsSpending = 'This Month\'s Spending';
  static const String viewDetails = 'View Details';
  static const String spent = 'Spent';
  static const String limit = 'Limit';
  static const String pendingApprovals = 'Pending Approvals';
  static const String requestsWaiting = 'Requests waiting'; // Dynamic number?
  static const String recentRequests = 'Recent Requests';

  // My Requests
  static const String myRequests = 'My Requests';
  static const String searchRequests = 'Search requests...';
  static const String all = 'All';
  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';

  // Create Request
  static const String selectRequestType = 'Select Request Type';
  static const String requestDetails = 'Request Details';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String selectCategory = 'Select Category';
  static const String purpose = 'Purpose';
  static const String purposeHint = 'e.g., Office Supplies';
  static const String attachments = 'Attachments';
  static const String takePhoto = 'Take Photo';
  static const String uploadBill = 'Upload Bill';
  static const String reviewRequest = 'Review Request';
  static const String reviewYourRequest = 'Review your request details';
  static const String submitRequest = 'Submit Request';
  static const String requestSubmitted = 'Request Submitted';
  static const String requestApproved = 'Request Automatically Approved';
  static const String fundsAdded = 'Funds have been added to your wallet';
  static const String requestSubmittedDesc =
      'Your request has been submitted successfully.';
  static const String goToDashboard = 'Go to Dashboard';

  // Monthly Spent
  static const String monthlySpentTransactions = 'Monthly Spent Transactions';
  static const String totalSpent = 'Total Spent';
  static const String searchTransactions = 'Search transactions...';
  static const String applyFilter = 'Apply Filter';
  // Reset Password
  static const String resetPassword = "Reset Password";
  static const String createNewPassword = "Create New Password";
  static const String newPasswordMustBeDifferent =
      "Your new password must be different from previously used passwords.";
  static const String newPassword = "New Password";
  static const String confirmPassword = "Confirm Password";
  static const String enterNewPassword = "Enter new password";
  static const String confirmNewPassword = "Confirm new password";
  static const String updatePassword = "Update Password";
  static const String passwordUpdatedSuccess =
      "Your password has been updated successfully.";

  static const String backToLogin = "Back to Login";

  // Organization Setup
  static const String setupOrganization = "Setup Organization";
  static const String organizationDetails = "ORGANIZATION DETAILS";
  static const String organizationName = "Organization Name";
  static const String organizationCode = "Organization Code";
  static const String adminDetails = "ADMIN DETAILS";
  static const String fullName = "Full Name";
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String workEmail = "Work Email";
  static const String adminCredentialsInfo =
      "Admin credentials will be sent to the registered email address securely.";
  static const String secureSSL = "256-bit SSL Secure";
  static const String createOrganizationAction = "Create Organization & Admin";
  static const String organizationCreatedSuccess =
      "Organization created successfully";
  static const String secureWorkspaceReady =
      "Your secure workspace is ready. Admin credentials have been sent to your email.";
  static const String checkInbox = "Check your inbox";
  static const String checkInboxDesc =
      "Please check your inbox and spam folder to retrieve your temporary password.";
  static const String contactSupport = "Contact Support";
  static const String didntReceiveEmail = "Didn't receive an email?";

  // Placeholders & Inputs
  static const String emailPlaceholder = 'name@company.com';
  static const String passwordPlaceholder = '••••••••';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String requests = 'Requests';
  static const String profile = 'Profile';

  // Enterprise Setup
  static const String enterpriseSetup = 'ENTERPRISE SETUP';
  static const String setUpOrganization = 'Set up organization';

  // Request Details & Status
  static const String date = 'Date';
  static const String description = 'Description';
  static const String noDescription = 'No description provided.';
  static const String noAttachments = 'No attachments';

  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';
  static const String statusPaid = 'Paid';

  static const String filterAll = 'All';
  static const String filterPaid = 'Paid';
  static const String filterPending = 'Pending';
  static const String filterApproved = 'Approved';
  static const String filterRejected = 'Rejected';
  static const String filterClarification = 'Clarification';

  static const String totalAmount = 'TOTAL AMOUNT';
  static const String requestId = 'Request ID';
  static const String status = 'Status';
  static const String paymentStatus = 'Payment Status';

  static const String approvedSC = 'APPROVED'; // Small Caps Style or Uppercase
  static const String pendingSC = 'PENDING';
  // Select Request Type
  static const String approvalTime = 'Approval Time';
  static const String preApproved = 'Pre-approved';
  static const String preApprovedDesc =
      'For expenses approved before purchase.';
  static const String postApproved = 'Post-approved';
  static const String postApprovedDesc =
      'For expenses needing approval after purchase.';

  // Request Details (Form)
  static const String requestType = 'Request Type';
  static const String approvalRequired = 'Approval Required';
  static const String approvalRequiredDesc =
      'Amount exceeds auto-approval limit';
  static const String descriptionOptional = 'Description (Optional)';
  static const String descriptionPlaceholder =
      'e.g., A4 paper and pens from Staples';

  // Review Request
  static const String totalRequestedAmount = 'Total Requested Amount';
  static const String notSelected = 'Not Selected';

  // Forgot Password & OTP
  static const String rememberPassword = 'Remember your password? ';
  static const String logIn = 'Log In';
  static const String otpVerification = 'OTP Verification';
  static const String enterConfirmationCode = 'Enter confirmation code';
  static String otpSentTo(String target) =>
      "We've sent a 6-digit verification code to $target.";
  static const String resend = 'Resend';
  static const String resendCodeIn = 'Resend code in';
  static const String verify = 'Verify';
  static const String didntReceiveCode = "Didn't receive the code? ";

  // Organization Setup Hints & Labels
  static const String stepperOrganization = 'Organization';
  static const String stepperPreferences = 'Preferences';
  static const String hintOrgName = 'e.g. Acme Corp';
  static const String hintAdminName = 'First Last';
  static const String hintAdminEmail = 'admin@company.com';
  static const String goToLogin = 'Go to Login';

  // Admin Module
  static const String welcomeApprover = 'Welcome back,\nApprover!';
  static const String overview = 'Overview';
  static const String actions = 'Actions';
  static const String reviewPending = 'Review Pending';
  static const String viewAllRequests = 'View all requests';
  static const String viewallRequests = 'View all requests';
  static const String viewHistory = 'View History';
  static const String pastApprovals = 'Past approvals';
  static const String addNewUser = 'Add New User';
  static const String createNewAccount = 'Create new account';

  static const String approvalsTitle = 'Approvals';
  static const String from = 'From:';

  static const String clientLunchMeeting = 'Client Lunch Meeting';
  static const String businessMeal = 'Business Meal';
  static const String pendingApproval = 'Pending Approval';
  static const String attachedBill = 'Attached Bill';
  static const String tapToView = 'Tap to view';
  static const String askClarification = 'Ask Clarification';
  static const String approve = 'Approve';
  static const String reject = 'Reject';

  static const String approvedSuccessTitle = 'Approved!';
  static const String approvedSuccessDesc =
      'The petty cash request has been successfully approved. The requester will be notified.';
  static const String backToApprovals = 'Back to Approvals List';

  // Admin Set Limits
  static const String adminSetLimits = 'Set Approval Limits';
  static const String deemedLimitLabel = 'Deemed Amount Limit';
  static const String deemedLimitDesc =
      'Expenses up to this amount are automatically approved.';
  static const String approvalLimitLabel = 'Approval Required Amount Limit';
  static const String approvalLimitDesc =
      'Expenses exceeding this amount require manual approval.';
  static const String limitConfigDesc =
      'Configure the monetary thresholds for automatic and manual expense approvals.';
  static const String saveLimits = 'Save Limits';
  static const String saving = 'Saving...';
  static const String inrSuffix = 'INR';

  // Admin Tabs
  static const String tabPending = 'Pending';
  static const String tabApproved = 'Approved';
  static const String tabRejected = 'Rejected';

  // Bottom Bar (if specialized)
  static const String navHome = 'Home';
  static const String navApprovals = 'Approvals';
  static const String navHistory = 'History';
  static const String navProfile = 'Profile';

  // Admin Rejection & Clarification
  static const String reasonForRejection = 'Reason for Rejection';
  static const String rejectionReasonHint =
      'Please provide a reason for rejecting this request.';
  static const String reasonLabel = 'Reason';
  static const String reasonPlaceholder =
      'e.g., Missing receipt, incorrect amount...';
  static const String confirmReject = 'Confirm Reject';
  static const String requestRejected = 'Request Rejected';
  static const String requestRejectedDesc =
      'You have successfully rejected this petty cash request.';
  static const String sentBackSuccessfully = 'Sent Back Successfully';
  static const String sentBackDesc =
      'The petty cash request has been returned for more information.';
  static const String backToApprovalsList = 'Back to Approvals List';
  static const String askClarificationTitle = 'Ask for Clarification';
  static const String yourQuestions = 'Your Questions or Comments';
  static const String clarificationHint =
      'Please provide more details or attach the missing invoice.';
  static const String sendBackForClarification = 'Send Back for Clarification';
  static const String pastApprovalsTitle = 'Past Approvals';
  static const String clarified = 'Clarified';
  static const String clarification = 'Clarification';
  static const String confirmation = 'Confirmation';

  // History Details
  static const String approvalTimeline = 'Approval Timeline';
  static const String billAndAttachments = 'Bill & Attachments';
  static const String submittedOn = 'SUBMITTED ON';
  static const String actionDate = 'ACTION DATE';
  static const String approvedByYou = 'Approved by You';
  static const String pendingApprovalStatus =
      'Pending Approval'; // statusPending duplicates
  static const String requestSubmittedStatus = 'Request Submitted';

  // Clarification Status
  static const String clarificationStatusTitle = 'Clarification Status';
  static const String currentStatus = 'Current Status';
  static const String responseReceived = 'Response Received';
  static const String waitingForRequestor = 'Waiting for requestor to reply';
  static const String pendingResponse = 'Pending Response';
  static const String reviewResponseAction =
      'Review the response below to take action';
  static const String yourClarificationRequest = 'Your Clarification Request';
  static const String sentByYou = 'SENT BY YOU';
  static const String requestorsResponse = 'Requestor\'s Response';
  static const String waitingForResponsePlaceholder =
      'Waiting for John Doe to respond...';
  static const String responseNotification =
      'You will be notified when a response is submitted.';
  static const String itemizedReceipt = 'itemized_receipt_001.pdf';
  static const String askClarificationAgain = 'Ask Clarification Again';
  static const String clarificationHistory = 'Clarification History';
  static const String youAsked = 'YOU ASKED';
  static const String responseReceivedTitle =
      'Response Received'; // Reusing or new
  static const String furtherClarificationNeeded =
      'Further Clarification Needed';
  static const String sendClarificationRequest = 'Send Clarification Request';
  static const String makeItClear = 'Make it clear';
  static const String explainWhy =
      'Explain why the response is still insufficient...';

  static const String provideClarification = 'PROVIDE CLARIFICATION';
  static const String approverQuestion = 'Approver Question';
  static const String yourResponse = 'YOUR RESPONSE';
  static const String submitClarification = 'Submit Clarification';
  static const String clarificationRequested = 'CLARIFICATION REQUESTED';
  static const String typeYourExplanation = 'Type your explanation here...';

  // New additions for Clarification Flow
  static const String reviewClarification = 'Review Clarification';
  static const String waitingForResponse = 'Waiting for Response';
  static const String requestorUpdatedDetails =
      'Requestor has updated the details.';
  static const String pendingUserResponse =
      'This request is pending a response from the user.';
  static const String errorDisplayingDetails =
      'Error displaying request details.';
  static const String youApprover = 'You (Approver)';
  static const String recently = 'Recently';
  static const String responseSent = 'Response Sent';
  static const String actionRequired = 'Action Required';
  static const String clarificationSubmittedWait =
      'You have submitted the clarification. Waiting for approval.';
  static const String approverRequestedClarification =
      'The approver has requested clarification on this request.';
  static const String submitResponse = 'Submit Response';
  static const String approver = 'Approver';
  static const String you = 'You';
  static const String expense = 'Expense';
  static const String provideClarificationTitle = 'Provide Clarification';
  static const String yourResponseTitle = 'Your Response';

  // Common/Fallback
  static const String unpaid = 'Unpaid';
  static const String noRequests = 'No requests';
  static const String unnamedRequest = 'Unnamed Request';
  static const String unknownUser = 'Unknown User';
  static const String noDate = 'No Date';

  static const String information = 'Information';
  static const String submitted = 'Submitted';
  static const String managerApproval = 'Manager Approval';
  static const String finalApproval = 'Final Approval';
  static const String noteFromApprover = 'Note from Approver';

  static const String enterExplanation = 'Please enter your explanation';
  static const String invalidRequestId = 'Invalid Request ID';
  static const String clarificationSubmitted =
      'Clarification submitted successfully';
  static String failedToSubmit(String error) => "Failed to submit: $error";

  // Profile & Settings
  static const String myProfile = 'My Profile';
  static const String edit = 'Edit';
  static const String phone = 'Phone';
  static const String role = 'Role';
  static const String changePassword = 'Change Password';
  static const String appSettings = 'App Settings';
  static const String logOut = 'Log Out';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String currency = 'Currency';
  static const String appearance = 'Appearance';
  static const String faceIdTouchId = 'Face ID / Touch ID';
  static const String helpSupport = 'Help & Support';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // User Management
  static const String addNewUserTitle = 'Add New User';
  static const String enterFullName = 'Enter full name';
  static const String selectRole = 'Select Role';
  static const String uploadPhoto = 'Upload Photo';
  static const String editPhoto = 'Edit Photo';
  static const String delete = 'Delete';
  static const String editUser = 'Edit User';
  static const String activeStatus = 'Active Status';
  static const String userCanAccessSystem = 'User can access the system';
  static const String allowCashAdvances = 'Allow Cash Advances';
  static const String enablePettyCashRequests = 'Enable petty cash requests';
  static const String viewGlobalReports = 'View Global Reports';
  static const String readOnlyAccess = 'Read-only access to analytics';
  static const String updateUser = 'Update User';
  static const String createUser = 'Create User';
  static const String permissions = 'Permissions';

  // Deactivation
  static const String deactivateAccount = 'Deactivate Account?';
  static const String deactivateDesc =
      'You are about to deactivate access for the following user. They will no longer be able to submit or approve petty cash requests.';
  static const String understandAction =
      'I understand this action cannot be undone immediately without admin approval.';
  static const String deactivateUser = 'Deactivate User';
  static const String userDeactivatedSuccess = 'User Deactivated';
  static const String userDeactivatedDesc =
      'The user has been successfully deactivated.';
  static const String activateUser = 'Activate User';
  static const String activateAccount = 'Activate Account?';
  static const String activateDesc =
      'You are about to activate access for the following user. They will be able to submit and approve requests again.';
  static const String userActivatedSuccess = 'User Activated';
  static const String inactive = 'Inactive';
  static const String userCreatedSuccess = 'User Created Successfully';
  static const String userCreatedDesc =
      'The new user account has been created.';
  static const String userUpdatedSuccess = 'User Updated Successfully';
  static const String userUpdatedDesc = 'The user details have been updated.';
  static const String backToUserList = 'Back to User List';
  static const String employeeId = 'Employee ID: #8834'; // Mock
  static const String active = 'Active';

  // Enhanced User List
  static const String manageUsers = 'Manage Users';
  static const String searchUsersHint = 'Search name, email...';
  static const String allUsers = 'ALL USERS';
  static const String exportList = 'Export List';
  static const String viewProfile = 'View Profile';

  // Enhanced Success Screen
  static const String goToManageUsers = 'Go to Manage Users';
  static const String addAnotherUser = 'Add Another User';
  static const String userCreatedSuccessTitle = 'User Created Successfully';
  static const String userCreatedSuccessDesc =
      'The new account has been set up and is ready to use.';
  static const String userUpdatedSuccessTitle = 'User Updated Successfully';
  static const String userUpdatedSuccessDesc =
      'The user information has been updated and saved.';
  static const String editAnotherUser = 'Edit Another User';
  static const String updatedOn = 'Updated On';
  static const String createdOn = 'Created On';

  // Settings - Notifications
  static const String approvalStatusUpdates = 'Approval Status Updates';
  static const String approvalStatusDesc =
      'Get notified when a request is approved or rejected';
  static const String newRequestSubmitted = 'New Request Submitted';
  static const String newRequestDesc =
      'Receive alerts when team members submit requests';
  static const String paymentReminders = 'Payment Reminders';
  static const String paymentRemindersDesc =
      'Reminders for pending payouts and upcoming dues';
  static const String clarificationRequests = 'Clarification Requests';
  static const String clarificationRequestsDesc =
      'Notify when additional information is required';

  // Settings - Appearance
  static const String appTheme = 'APP THEME';
  static const String lightTheme = 'Light Theme';
  static const String darkTheme = 'Dark Theme';
  static const String systemDefault = 'System Default';
  static const String textSize = 'TEXT SIZE';
  static const String small = 'Small';
  static const String medium = 'Medium';
  static const String large = 'Large';
  static const String preview = 'PREVIEW';
  static const String officeSupplies = 'Office Supplies';
  static const String todayTime = 'Today, 10:23 AM';
  static const String previewDesc =
      'This is how your transaction items will look with the current settings applied.';
  static const String saveChanges = 'Save Changes';

  // Settings - Change Password
  static const String currentPassword = 'Current Password';
  static const String enterCurrentPassword = 'Enter current password';
  // static const String newPassword = 'New Password'; // Existing
  // static const String enterNewPassword = 'Enter new password'; // Existing
  // static const String confirmNewPassword = 'Confirm New Password'; // Existing
  static const String reEnterNewPassword = 'Re-enter new password';
  static const String mustBeAtLeast8Chars = 'Must be at least 8 characters';
  static const String bothPasswordsMatch = 'Both passwords must match';
  // static const String updatePassword = 'Update Password'; // Existing
  static const String forgotPasswordQuestion = 'Forgot Password?';
  // Accountant Dashboard
  static const String inHandCash = 'In-Hand Cash';
  static const String vsYesterday = 'vs yesterday';
  static const String openBalance = 'OPEN BALANCE';
  static const String closingBalance = 'CLOSING BALANCE';
  static const String amountIn = 'Amount In';
  static const String amountOut = 'Amount Out';
  static const String pendingPayments = 'Pending Payments';
  static const String paymentsNeedProcessing = 'payments need processing';
  static const String processPayments = 'Process Payments';
  static const String todayTransactions = 'Today\'s Transactions';
  static const String viewAll = 'View All';
  static const String view = 'View';

  // Accountant Payments
  static const String totalOutstanding = 'TOTAL OUTSTANDING';
  static const String acrossPendingRequests = 'Across pending requests';
  static const String notPaid = 'Not Paid';
  static const String navPayments = 'Payments';
  static const String navReports = 'Reports';
  static const String totalDisbursed =
      'Total Disbursed (Oct)'; // TODO: Dynamic Month

  // Refinement Accountant Flow
  static const String goodMorning = 'Good Morning';
  static const String mockAccountantName = 'Sarah';
  static const String mockAccountantFullName = 'Sarah Jenkins';
  static const String mockAccountantEmail = 'sarah.jenkins@company.com';
  static const String mockDate = 'Oct 24, 2023';
  static const String searchByIdOrName = 'Search by ID or Name...';
  static const String thisMonth = 'THIS MONTH';
  static const String completedSC = 'COMPLETED';

  // Cash Flow History
  static const String cashFlowHistory = 'Cash Flow History';
  static const String thisMonthFilter = 'This Month';
  static const String last3Months = 'Last 3 Months';
  static const String custom = 'Custom';
  static const String totalIn = 'TOTAL IN';
  static const String totalOut = 'TOTAL OUT';
  static const String detailedTransactions = 'Detailed Transactions';
  static const String cashIn = 'Cash In';
  static const String cashOut = 'Cash Out';
  static const String weeklyReplenishment = 'Weekly Replenishment';
  static const String transportToClient = 'Transport to Client';
  static const String refreshments = 'Refreshments';
  static const String vendorRefund = 'Vendor Refund';
  // Payment Flow
  static const String billAttachments = 'Bill & Attachments';
  static const String qrVerified = 'QR Verified';
  static const String detectedTotal = 'Detected Total';
  static const String viewBillDetails = 'View Bill Details';
  static const String paymentDetailsFound = 'Payment Details Found';
  static const String scannedFromQr = 'Scanned from QR code on bill';
  static const String payeeName = 'Payee Name';
  static const String upiId = 'UPI ID';
  static const String useForPayment = 'Use for Payment';
  static const String dismiss = 'Dismiss';

  // Verify Payment
  static const String verifyPayment = 'Verify Payment';
  static const String paymentDetails = 'PAYMENT DETAILS';
  static const String requestedAmount = 'Requested Amount';
  static const String finalPayableAmount = 'Final Payable Amount';
  static const String adjustmentReason = 'Adjustment Reason';
  static const String requiredIfAmountChanged = '(Required if amount changed)';
  static const String reasonForModification =
      'Enter reason for modification...';
  static const String paymentSource = 'PAYMENT SOURCE';
  static const String pettyCash = 'Petty Cash';
  static const String cashInHand = 'Cash in hand';
  static const String available = 'Available';
  static const String bankTransferUpi = 'Bank Transfer / UPI';
  static const String digitalPayment = 'Digital payment';
  static const String totalPayment = 'TOTAL PAYMENT';
  static const String makePayment = 'Make Payment';

  // Confirm Payment
  static const String confirmPayment = 'Confirm Payment';
  static const String totalPayable = 'TOTAL PAYABLE';
  static const String verifiedVendor = 'Verified Vendor';
  static const String transactionDetails = 'TRANSACTION DETAILS';
  static const String payingTo = 'Paying to';
  static const String payViaInstalledApp = 'Pay via installed app';
  static const String gpay = 'GPay';
  static const String phonePe = 'PhonePe';
  static const String paytm = 'Paytm';
  static const String other = 'Other';
  static const String payViaUpiApp = 'Pay via UPI App';
  static const String securelyRedirects =
      'Securely redirects to your installed UPI application.';

  // Payment Success
  static const String fundsTransferred =
      'Funds have been successfully transferred to the employee\'s account.';
  static const String totalPaid = 'TOTAL PAID';
  static const String transactionId = 'Transaction ID';
  static const String paymentDate = 'Date & Time';
  static const String recipient = 'Recipient';
  static const String viewRequestDetails = 'View Request Details';
  static const String backToDashboard = 'Back to Dashboard';

  // Payment Failed
  static const String paymentFailed = 'Payment Failed';
  static const String paymentFailedDesc =
      'We couldn\'t process the payment of \$450.00 to John Doe due to a network timeout.'; // TODO: Dynamic
  static const String retryPayment = 'Retry Payment';
  static const String goBackToDetails = 'Go Back to Details';
  static const String needHelpContactSupport = 'Need help? Contact Support';

  // Analytics
  static const String spendAnalytics = 'Spend Analytics';
  static const String totalSpend = 'Total Spend';
  static const String avgTransaction = 'Avg Transaction';
  static const String monthlyTrend = 'Monthly Trend';
  static const String spendByCategory = 'Spend by Category';
  static const String departmentSpend = 'Department Spend';
  static const String customReports = 'Custom Reports';
  static const String generateExportInsights =
      'Generate & export detailed insights';

  // Financial Reports
  static const String financialReports = 'Financial Reports';
  static const String reportParameters = 'Report Parameters';
  static const String startDate = 'START DATE';
  static const String endDate = 'END DATE';
  static const String allCategories = 'All Categories';
  static const String generatePreview = 'Generate Preview';
  static const String previewSummary = 'Preview Summary';
  static const String totalExpenses = 'TOTAL EXPENSES';
  static const String reportExportedSuccess = 'Report exported successfully';
  static const String exportCsv = 'Export CSV';
  static const String exportPdf = 'Export PDF';

  // Completed Request Details
  static const String completed = 'COMPLETED';
  static const String totalPaidAmount = 'Total Paid Amount';
  static const String requestDate = 'Request Date';
  static const String paymentDateLabel =
      'Payment Date'; // paymentDate exists but mapped to 'Date & Time'
  static const String requestInformation = 'Request Information';
  static const String department = 'Department';
  static const String billAttachment = 'Bill Details';
  static const String requestor = 'Requestor';
  static const String referenceCode = 'Reference Code';
  static const String auditTrail = 'Audit Trail';
  static const String paidByAccountsTeam = 'Paid by Accounts Team';
  static const String fundsDisbursedFrom = 'Funds disbursed from';
  static const String approvedByManager = 'Approved by Manager';
  static const String requestSubmittedInit =
      'Initial request created by'; // Request Submitted exists
  static const String downloadAuditReport = 'Download Audit Report';

  // Onboarding
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String onboardingTitle1 = 'Effortless Expense\nTracking';
  static const String onboardingDesc1 =
      'Capture receipts, submit reports, and track your budget instantly. Expense management made simple.';
  static const String onboardingTitle2 = 'Quick Approvals\n& Payments';
  static const String onboardingDesc2 =
      'Streamline your workflow. Review expenses and authorize payments instantly with just one tap.';
  static const String onboardingTitle3 = 'Manage Finances\nYour Way';
  static const String onboardingDesc3 =
      'Tailored dashboards for every role. From submitting expenses to auditing reports, experience seamless financial control.';
  static const String onboardingTerms =
      'By continuing, you agree to our Terms & Privacy Policy.';
}
