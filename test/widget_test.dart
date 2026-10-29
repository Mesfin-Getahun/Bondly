import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('BondlyApp builds and renders Firebase dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BondlyApp());

    // Verify title and Firebase service labels
    expect(find.text('Bondly'), findsOneWidget);
    expect(find.text('Firebase Architecture & Services'), findsOneWidget);
    expect(find.text('Upload to Firebase Storage'), findsOneWidget);
    expect(find.text('Cloud Firestore Stream'), findsOneWidget);
  });
}
