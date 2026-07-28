import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../features/Auth/data/repositories/admin_auth_repository.dart';
import '../../features/Auth/logic/admin_auth_cubit.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/dashboard/logic/dashboard_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
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

  // Register DashboardRepository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(sl<ApiClient>()),
  );

  // Register DashboardCubit
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(sl<DashboardRepository>()),
  );
}