class ApiEndpoints {
  static const String baseUrl = 'https://your-domain.com/api'; // ضع الرابط الأساسي للسيرفر هنا

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/user/profile';

  // Dashboard
  static const String dashboardStats = '/admin/dashboard/stats';
  static const String activeTrips = '/admin/dashboard/active-trips';

  // Admins
  static const String admins = '/admin/admins';

  // Drivers
  static const String drivers = '/admin/drivers';
  static const String pendingChanges = '/admin/drivers/pending-changes';

  // Schools & Zones
  static const String schools = '/admin/schools';
  static const String zones = '/admin/zones';

  // Complaints
  static const String complaints = '/admin/complaints';

  // Financial
  static const String invoices = '/admin/financial/invoices';
  static const String withdrawals = '/admin/financial/withdrawals';
  static const String recharges = '/admin/financial/recharges';
}