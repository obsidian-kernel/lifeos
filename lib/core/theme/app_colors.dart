import 'package:flutter/material.dart';

/// Single source of truth for all colors in LifeOS.
/// Dark-first. One accent color. No decorative palette.
/// All colors are final — no runtime theming complexity.
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color surfaceHighlight = Color(0xFF2E2E2E);

  // ── Content ───────────────────────────────────────────────
  static const Color onBackground = Color(0xFFE8E8E8);
  static const Color onSurface = Color(0xFFCCCCCC);
  static const Color onSurfaceMuted = Color(0xFF888888);
  static const Color onSurfaceDisabled = Color(0xFF555555);

  // ── Accent ────────────────────────────────────────────────
  // Single accent. Not a palette.
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentMuted = Color(0x336C63FF);
  static const Color accentForeground = Color(0xFFFFFFFF);

  // ── Semantic ──────────────────────────────────────────────
  static const Color error = Color(0xFFCF6679);
  static const Color errorMuted = Color(0x33CF6679);
  static const Color success = Color(0xFF4CAF7D);
  static const Color successMuted = Color(0x334CAF7D);
  static const Color warning = Color(0xFFE0A84B);
  static const Color warningMuted = Color(0x33E0A84B);

  // ── Borders & Dividers ────────────────────────────────────
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF222222);

  // ── Priority Colors (Tasks) ───────────────────────────────
  static const Color priorityHigh = Color(0xFFCF6679);
  static const Color priorityMedium = Color(0xFFE0A84B);
  static const Color priorityLow = Color(0xFF4CAF7D);
  static const Color priorityNone = Color(0xFF555555);
}
