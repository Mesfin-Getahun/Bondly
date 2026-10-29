import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('BondlyApp builds and displays header and dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BondlyApp());

    // Verify that the title 'Bondly' is rendered
    expect(find.text('Bondly'), findsOneWidget);

    // Verify that system status and upload cards are present
    expect(find.text('Stack Status & Configuration'), findsOneWidget);
    expect(find.text('Upload & Process File'), findsOneWidget);
  });
}
