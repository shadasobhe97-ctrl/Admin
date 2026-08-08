import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../theme/cubit/theme_cubit.dart';
import '../../features/Auth/data/datasources/password_reset_remote_data_source.dart';
import '../../features/Auth/data/repositories/admin_auth_repository.dart';
import '../../features/Auth/data/repositories/admin_password_reset_repository.dart';
import '../../features/Auth/logic/admin_auth_cubit.dart';
import '../../features/Auth/logic/admin_password_reset_cubit.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/dashboard/logic/dashboard_cubit.dart';

import '../../features/admin_management/data/datasources/admin_management_remote_data_source.dart';
import '../../features/admin_management/data/repositories/admin_management_repository.dart';
import '../../features/admin_management/logic/admin_management_cubit.dart';

import '../../features/drivers_management/data/datasources/drivers_management_remote_data_source.dart';
import '../../features/drivers_management/data/repositories/drivers_management_repository.dart';
import '../../features/drivers_management/logic/drivers_management_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register ThemeCubit as a LazySingleton
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // Register ApiClient as a Singleton
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Register AdminAuthRepository as a LazySingleton
  sl.registerLazySingleton<AdminAuthRepository>(
    () => AdminAuthRepository(sl<ApiClient>()),
  );

  // Register AdminAuthCubit as a Factory
  sl.registerFactory<AdminAuthCubit>(
    () => AdminAuthCubit(sl<AdminAuthRepository>()),
  );

  // Register PasswordResetRemoteDataSource as a LazySingleton
  sl.registerLazySingleton<PasswordResetRemoteDataSource>(
    () => PasswordResetRemoteDataSource(sl<ApiClient>()),
  );

  // Register AdminPasswordResetRepository as a LazySingleton
  sl.registerLazySingleton<AdminPasswordResetRepository>(
    () => AdminPasswordResetRepository(sl<PasswordResetRemoteDataSource>()),
  );

  // Register AdminPasswordResetCubit as a Factory
  sl.registerFactory<AdminPasswordResetCubit>(
    () => AdminPasswordResetCubit(sl<AdminPasswordResetRepository>()),
  );

  // Register DashboardRepository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(sl<ApiClient>()),
  );

  // Register DashboardCubit
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(sl<DashboardRepository>()),
  );

  // ── Admin Management Feature ──────────────────────────────────────────────
  sl.registerLazySingleton<AdminManagementRemoteDataSource>(
    () => AdminManagementRemoteDataSource(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AdminManagementRepository>(
    () => AdminManagementRepository(sl<AdminManagementRemoteDataSource>()),
  );

  sl.registerFactory<AdminManagementCubit>(
    () => AdminManagementCubit(sl<AdminManagementRepository>()),
  );

  // ── Drivers Management Feature ──────────────────────────────────────────────
  sl.registerLazySingleton<DriversManagementRemoteDataSource>(
    () => DriversManagementRemoteDataSource(sl<ApiClient>()),
  );

  sl.registerLazySingleton<DriversManagementRepository>(
    () => DriversManagementRepository(sl<DriversManagementRemoteDataSource>()),
  );

  sl.registerFactory<DriversManagementCubit>(
    () => DriversManagementCubit(sl<DriversManagementRepository>()),
  );
}
