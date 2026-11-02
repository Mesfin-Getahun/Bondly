import 'package:flutter/material.dart';

/// Design tokens adhering strictly to AGENTS.md
class AppColors {
  // Canvas / Background: #0A0D14 (Deep obsidian/navy)
  static const Color background = Color(0xFF0A0D14);

  // Elevated Surfaces / Cards: #121824
  static const Color surface = Color(0xFF121824);
  static const Color surfaceElevated = Color(0xFF1A2333);

  // Subtle Borders: #1E293B (1px width on all cards, inputs, and sheet edges)
  static const Color border = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF1E293B);

  // Primary Accent / Brand: #FF6B50 (Warm coral/terracotta for greeting banners and primary actions)
  static const Color primary = Color(0xFFFF6B50);
  static const Color primaryDark = Color(0xFFE05338);
  static const Color secondary = Color(0xFF263238);

  // Privacy Accent: #8B5CF6 (Muted violet for privacy notes and owner-only indicators)
  static const Color privacyAccent = Color(0xFF8B5CF6);
  static const Color privacySurface = Color(0xFF161327);
  static const Color privacyBorder = Color(0xFF2E2856);

  // Typography Colors
  // Headings / Active Text: #FFFFFF or #F8FAFC
  static const Color textPrimary = Color(0xFFF8FAFC);
  // Body / Subtext: #94A3B8 (Muted slate)
  static const Color textSecondary = Color(0xFF94A3B8);
  // Micro-labels: #64748B
  static const Color microLabel = Color(0xFF64748B);

  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);
}
