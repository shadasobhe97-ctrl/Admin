class ApiEndpoints {
  static const String baseUrl = 'https://witty-otter-10.loca.lt/api';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  // Password Reset Flow (3-step)
  static const String passwordSendOtp = '/auth/password/send-otp';
  static const String passwordVerifyOtp = '/auth/password/verify-otp';
  static const String passwordReset = '/auth/password/reset';

  // ── Profile ─────────────────────────────────────────────────────────────────
  static const String profile = '/admin/profile';
  static const String profileEmailChangeStatus =
      '/admin/profile/email-change/status';
  static const String profileEmailChangeCancel =
      '/admin/profile/email-change/cancel';
  static const String profileEmailChangeResend =
      '/admin/profile/email-change/resend';

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

  /// PUT — تعديل بيانات السائق مباشرة (يُسجَّل في سجل إجراءات المشرفين).
  static String driverUpdate(dynamic id) => '/admin/drivers/$id';

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

  // ── 3.1 سجل إجراءات المشرفين (الأدمن فقط) ───────────────────────────────────
  static const String adminAuditLogs = '/admin/admin-audit-logs';
  static String adminAuditLogDetails(dynamic id) =>
      '/admin/admin-audit-logs/$id';

  // ── 4. Schools ──────────────────────────────────────────────────────────────
  static const String schools = '/admin/schools';
  static String schoolDetails(dynamic id) => '/admin/schools/$id';

  // ── 5. Zones & Geography (3 مستويات) ────────────────────────────────────────
  // المستوى الأول: البلديات الكبرى
  static const String municipalities = '/admin/municipalities';
  static String municipalityDetails(dynamic id) => '/admin/municipalities/$id';

  // المستوى الثاني: البلديات الفرعية / المحلات
  static const String subMunicipalities = '/admin/sub-municipalities';
  static String subMunicipalityDetails(dynamic id) =>
      '/admin/sub-municipalities/$id';
  static String adminSubMunicipalities(dynamic municipalityId) =>
      '/admin/municipalities/$municipalityId/sub-municipalities';

  // المستوى الثالث: المناطق الدقيقة
  static const String zones = '/admin/zones';
  static const String zonesTree = '/admin/zones-tree';
  static String zoneDetails(dynamic id) => '/admin/zones/$id';
  static String adminZones(dynamic subMunicipalityId) =>
      '/admin/sub-municipalities/$subMunicipalityId/zones';

  // البحث في البيانات الجغرافية
  static const String geographySearch = '/admin/geography/search';

  // ── 5.1 Reports & Analytics ─────────────────────────────────────────────────
  static const String reportsKpiSummary = '/admin/reports/kpi-summary';
  static const String reportsFinancial = '/admin/reports/financial';
  static const String reportsTrips = '/admin/reports/trips';
  static const String reportsSubscriptions = '/admin/reports/subscriptions';
  static const String reportsDriversPerformance =
      '/admin/reports/drivers-performance';
  static const String reportsExport = '/admin/reports/export';

  // ── 6. Complaints ───────────────────────────────────────────────────────────
  static const String complaints = '/admin/complaints';
  static String complaintDetails(dynamic id) => '/admin/complaints/$id';
  static String driverComplaints(dynamic driverId) =>
      '/admin/complaints/driver/$driverId';
  static String complaintReview(dynamic id) => '/admin/complaints/$id/review';

  // ── 7. Driver Reviews ───────────────────────────────────────────────────────
  static String driverReviewDetails(dynamic id) => '/admin/driver-reviews/$id';

  // ── 8. Financial ────────────────────────────────────────────────────────────
  static const String financialSummary = '/admin/financial/summary';
  static const String financialAuditLogs = '/admin/financial/audit-logs';

  static const String invoices = '/admin/financial/invoices';
  static String invoiceDetails(dynamic id) => '/admin/financial/invoices/$id';

  static const String withdrawals = '/admin/financial/withdrawals';
  static String withdrawalDetails(dynamic id) =>
      '/admin/financial/withdrawals/$id';
  static String withdrawalProcess(dynamic id) =>
      '/admin/financial/withdrawals/$id/process';

  static const String recharges = '/admin/financial/recharges';
  static String rechargeDetails(dynamic id) => '/admin/financial/recharges/$id';
  static String rechargeProcess(dynamic id) =>
      '/admin/financial/recharges/$id/process';

  // ── 9. Treasury, Ledger & Advanced Financial Engine ─────────────────────────
  static const String solvencyCheck = '/admin/financial/solvency-check';
  static const String ledger = '/admin/financial/ledger';
  static const String escrows = '/admin/financial/escrows';
  static const String releaseEscrows = '/admin/financial/release-escrows';

  static const String disputes = '/admin/financial/disputes';
  static String disputeDetails(dynamic disputeId) =>
      '/admin/financial/disputes/$disputeId';
  static String disputeResolve(dynamic disputeId) =>
      '/admin/financial/disputes/$disputeId/resolve';

  static const String pendingSettlements =
      '/admin/financial/contracts/pending-settlements';
  static String contractSettleMonthly(dynamic contractId) =>
      '/admin/financial/contracts/$contractId/settle-monthly';
  static String contractTerminationPreview(dynamic contractId) =>
      '/admin/financial/contracts/$contractId/termination-preview';
  static String contractTerminateMidMonth(dynamic contractId) =>
      '/admin/financial/contracts/$contractId/terminate-mid-month';

  static String tripCancelPreview(dynamic tripId) =>
      '/admin/financial/trips/$tripId/cancel-preview';
  static String tripCancelWithMatrix(dynamic tripId) =>
      '/admin/financial/trips/$tripId/cancel-with-matrix';

  static const String pricingSettings = '/admin/financial/pricing-settings';

  // ── طرق الدفع (Payment Methods) ──────────────────────────────────────────
  static const String paymentMethods = '/admin/payment-methods';
  static String paymentMethodDetails(dynamic id) =>
      '/admin/payment-methods/$id';
  static String paymentMethodToggleStatus(dynamic id) =>
      '/admin/payment-methods/$id/toggle-status';

  // مسارات الفواتير العادية للأدمن (قراءة فقط) — مستقلة عن /financial/invoices
  static const String adminInvoices = '/admin/invoices';
  static String adminInvoiceDetails(dynamic id) => '/admin/invoices/$id';

  // ── Admin Notifications (إشعارات الأدمن) ───────────────────────────────────
  static const String adminNotifications = '/admin/notifications';
  static const String adminNotificationsUnreadCount =
      '/admin/notifications/unread-count';
  static String adminNotificationMarkAsRead(dynamic id) =>
      '/admin/notifications/$id/read';
  static const String adminNotificationsReadAll =
      '/admin/notifications/read-all';
}
