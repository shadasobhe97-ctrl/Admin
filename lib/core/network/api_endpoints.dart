class ApiEndpoints {
  static const String baseUrl = 'https://darby-app-api.loca.lt/api';

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/user/profile';

  // Admin Password Reset Flow
  static const String adminSendOtp = '/admin/auth/password/send-otp';
  static const String adminVerifyOtp = '/admin/auth/password/verify-otp';
  static const String adminResetPassword = '/admin/auth/password/reset';

  // 1. Dashboard
  static const String dashboardStats = '/dashboard/stats';
  static const String activeTrips = '/dashboard/active-trips';

  // 2. Drivers
  static const String drivers = '/drivers';
  static String driverDetails(dynamic id) => '/drivers/$id';
  static String driverReview(dynamic id) => '/drivers/$id/review';
  static const String pendingChanges = '/drivers/pending-changes';
  static String pendingChangeDetails(dynamic id) => '/drivers/pending-changes/$id';
  static String pendingChangeReview(dynamic id) => '/drivers/pending-changes/$id/review';

  // 3. Admins
  static const String admins = '/admins';
  static String adminDetails(dynamic id) => '/admins/$id';

  // 4. Schools
  static const String schools = '/schools';
  static String schoolDetails(dynamic id) => '/schools/$id';

  // 5. Zones & Geography
  static const String zones = '/zones';
  static const String zonesTree = '/zones-tree';
  static String zoneDetails(dynamic id) => '/zones/$id';

  // 6. Complaints
  static const String complaints = '/complaints';
  static String complaintDetails(dynamic id) => '/complaints/$id';
  static String driverComplaints(dynamic driverId) => '/complaints/driver/$driverId';
  static String complaintReview(dynamic id) => '/complaints/$id/review';

  // 7. Driver Reviews
  static const String driverReviewsAll = '/driver-reviews/all';
  static String driverReviewsForDriver(dynamic driverId) => '/driver-reviews/driver/$driverId';
  static String driverReviewDetails(dynamic id) => '/driver-reviews/$id';

  // 8. Financial
  static const String invoices = '/financial/invoices';
  static String invoiceDetails(dynamic id) => '/financial/invoices/$id';
  static const String withdrawals = '/financial/withdrawals';
  static String withdrawalProcess(dynamic id) => '/financial/withdrawals/$id/process';
  static const String recharges = '/financial/recharges';
  static String rechargeProcess(dynamic id) => '/financial/recharges/$id/process';
}
