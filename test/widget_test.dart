import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/main.dart';

void main() {
  testWidgets('DerbiApp builds smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DerbiApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that Derbi logo title exists
    expect(find.textContaining('دَربِي'), findsWidgets);
  });
}
