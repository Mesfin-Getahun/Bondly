import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_widget.dart';

void main() {
  group('Dashboard Widgets & AGENTS.md Privacy Banner Tests', () {
    testWidgets('PrivacyStatusBanner renders without overflow and matches privacy palette',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 380,
                child: PrivacyStatusBanner(
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify widget elements
      expect(find.byType(PrivacyStatusBanner), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(
        find.text(
          'Owner-Only Privacy: Your contact notes, logs, and follow-ups are visible only to you.',
        ),
        findsOneWidget,
      );

      // Verify interaction
      await tester.tap(find.byType(PrivacyStatusBanner));
      expect(tapped, isTrue);

      // Verify styling
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrivacyStatusBanner),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.privacySurface);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });
  });
}
