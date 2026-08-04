import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_panel/core/di/service_locator.dart';
import 'package:admin_panel/core/services/storage_service.dart';
import 'package:admin_panel/features/Auth/logic/admin_auth_cubit.dart';
import 'package:admin_panel/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    if (!sl.isRegistered<AdminAuthCubit>()) {
      await setupServiceLocator();
    }
  });

  testWidgets('DerbiApp builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DerbiApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('دَربِي'), findsWidgets);
  });
}
