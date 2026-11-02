import 'package:flutter_test/flutter_test.dart';
import 'package:mazhi_sheti/main.dart';

void main() {
  testWidgets('Mazhi Sheti app launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MazhiShetiApp());

    // Verify that Mazhi Sheti title/branding or onboarding loads.
    expect(find.textContaining('Mazhi'), findsWidgets);
    expect(find.textContaining('Language'), findsWidgets);
  });
}
