class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  // Password Reset Flow (3-step)
  static const String passwordSendOtp = '/auth/password/send-otp';
  static const String passwordVerifyOtp = '/auth/password/verify-otp';
  static const String passwordReset = '/auth/password/reset';

  // ── Profile ─────────────────────────────────────────────────────────────────
  static const String profile = '/user/profile';
  // update: POST /api/admin/admins/{id}  (handled in service)

  // Admin Password Reset Flow
  static const String adminSendOtp = '/admin/auth/password/send-otp';
  static const String adminVerifyOtp = '/admin/auth/password/verify-otp';
  static const String adminResetPassword = '/admin/auth/password/reset';

  // ── 1. Dashboard & Operations ──────────────────────────────────────────────
  static const String dashboardStats = '/admin/dashboard/stats';
  static const String activeTrips = '/admin/dashboard/active-trips';
  static const String generateDailyTrips = '/admin/trips/generate-daily';

  // ── 2. Drivers ──────────────────────────────────────────────────────────────
  static const String drivers = '/admin/drivers';
  static String driverDetails(dynamic id) => '/admin/drivers/$id';
  static String driverReview(dynamic id) => '/admin/drivers/$id/review';
  static const String pendingChanges = '/admin/drivers/pending-changes';
  static String pendingChangeDetails(dynamic id) =>
      '/admin/drivers/pending-changes/$id';
  static String pendingChangeReview(dynamic id) =>
      '/admin/drivers/pending-changes/$id/review';

  // Driver Reviews
  static const String driverReviewsAll = '/admin/driver-reviews/all';
  static String driverReviewsForDriver(dynamic id) =>
      '/admin/driver-reviews/driver/$id';
  static String deleteDriverReview(dynamic id) => '/admin/driver-reviews/$id';

  // ── 3. Admins ───────────────────────────────────────────────────────────────
  static const String admins = '/admin/admins';
  static String adminDetails(dynamic id) => '/admin/admins/$id';
  static String adminEmailChangeStatus(dynamic id) =>
      '/admin/admins/$id/email-change/status';
  static String adminEmailChangeCancel(dynamic id) =>
      '/admin/admins/$id/email-change/cancel';
  static String adminEmailChangeResend(dynamic id) =>
      '/admin/admins/$id/email-change/resend';
  static String adminEmailApprove(String token) =>
      '/admin/admin/email/approve/$token';
  static String adminEmailReject(String token) =>
      '/admin/admin/email/reject/$token';

  // ── 4. Schools ──────────────────────────────────────────────────────────────
  static const String schools = '/admin/schools';
  static String schoolDetails(dynamic id) => '/admin/schools/$id';

  // ── 5. Zones & Geography ────────────────────────────────────────────────────
  static const String zones = '/admin/zones';
  static const String zonesTree = '/admin/zones-tree';
  static String zoneDetails(dynamic id) => '/admin/zones/$id';

  // ── 6. Complaints ───────────────────────────────────────────────────────────
  static const String complaints = '/admin/complaints';
  static String complaintDetails(dynamic id) => '/admin/complaints/$id';
  static String driverComplaints(dynamic driverId) =>
      '/admin/complaints/driver/$driverId';
  static String complaintReview(dynamic id) => '/admin/complaints/$id/review';

  // ── 7. Driver Reviews ───────────────────────────────────────────────────────
  static String driverReviewDetails(dynamic id) => '/admin/driver-reviews/$id';

  // ── 8. Financial ────────────────────────────────────────────────────────────
  static const String invoices = '/admin/financial/invoices';
  static String invoiceDetails(dynamic id) => '/admin/financial/invoices/$id';
  static const String withdrawals = '/admin/financial/withdrawals';
  static String withdrawalProcess(dynamic id) =>
      '/admin/financial/withdrawals/$id/process';
  static const String recharges = '/admin/financial/recharges';
  static String rechargeProcess(dynamic id) =>
      '/admin/financial/recharges/$id/process';

  // ── 9. Treasury, Ledger & Advanced Financial Engine ─────────────────────────
  static const String solvencyCheck = '/admin/financial/solvency-check';
  static const String ledger = '/admin/financial/ledger';
  static const String releaseEscrows = '/admin/financial/release-escrows';

  static String disputeResolve(dynamic disputeId) =>
      '/admin/financial/disputes/$disputeId/resolve';
  static String contractSettleMonthly(dynamic contractId) =>
      '/admin/financial/contracts/$contractId/settle-monthly';
  static String contractTerminateMidMonth(dynamic contractId) =>
      '/admin/financial/contracts/$contractId/terminate-mid-month';
  static String tripCancelWithMatrix(dynamic tripId) =>
      '/admin/financial/trips/$tripId/cancel-with-matrix';

  // مسارات الفواتير العادية للأدمن (قراءة فقط) — مستقلة عن /financial/invoices
  static const String adminInvoices = '/admin/invoices';
  static String adminInvoiceDetails(dynamic id) => '/admin/invoices/$id';
}
