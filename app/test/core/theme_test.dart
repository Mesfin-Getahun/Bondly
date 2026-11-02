import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

void main() {
  group('Design System & Palette Verification (AGENTS.md)', () {
    test('AppColors matches AGENTS.md dark modern design tokens', () {
      expect(AppColors.background, const Color(0xFF0A0D14),
          reason: 'Canvas background must be #0A0D14');
      expect(AppColors.surface, const Color(0xFF121824),
          reason: 'Elevated surface / card fill must be #121824');
      expect(AppColors.border, const Color(0xFF1E293B),
          reason: 'Borders must be #1E293B');
      expect(AppColors.cardBorder, const Color(0xFF1E293B),
          reason: 'Card borders must be #1E293B');
      expect(AppColors.primary, const Color(0xFFFF6B50),
          reason: 'Primary brand accent must be #FF6B50 coral');
      expect(AppColors.privacyAccent, const Color(0xFF8B5CF6),
          reason: 'Privacy accent must be #8B5CF6 violet');
      expect(AppColors.textPrimary, const Color(0xFFF8FAFC),
          reason: 'Heading / active text must be #F8FAFC');
      expect(AppColors.textSecondary, const Color(0xFF94A3B8),
          reason: 'Body / subtext must be #94A3B8');
    });

    test('AppTheme defaults to dark mode with 20px card border radius', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.cardTheme.color, AppColors.surface);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());

      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(20));
      expect(shape.side.color, AppColors.cardBorder);
      expect(shape.side.width, 1.0);
    });
  });
}
