import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets('BondlyApp builds and renders root widget', (WidgetTester tester) async {
    await tester.pumpWidget(const BondlyApp());
    expect(find.byType(BondlyApp), findsOneWidget);
  });
}
