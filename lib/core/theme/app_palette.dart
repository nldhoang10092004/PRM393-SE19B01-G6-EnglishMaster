import 'package:flutter/material.dart';

/// Matching background, readable ink and solid edge for a learning skill.
@immutable
class SkillColors {
  const SkillColors(this.background, this.ink, this.edge);
  final Color background, ink, edge;

  /// Interpolates a skill block during a theme change.
  SkillColors lerp(SkillColors other, double t) => SkillColors(
    Color.lerp(background, other.background, t)!,
    Color.lerp(ink, other.ink, t)!,
    Color.lerp(edge, other.edge, t)!,
  );
}

/// Semantic colours for the “Botanical Study Ledger” (Editorial Greeting) design system.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.muted,
    required this.outline,
    required this.ink,
    required this.inkMuted,
    required this.primary,
    required this.primaryEdge,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.onPrimary,
    required this.reward,
    required this.onReward,
    required this.error,
    required this.speaking,
    required this.listening,
    required this.writing,
    required this.reading,
  });
  final Color background, surface, muted, outline, ink, inkMuted;
  final Color primary, primaryEdge, primarySoft, onPrimarySoft, onPrimary;
  final Color reward, onReward, error;
  final SkillColors speaking, listening, writing, reading;
  static const light = AppPalette(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    muted: Color(0xFFF1F5F9),
    outline: Color(0xFFE2E8F0),
    ink: Color(0xFF0F172A),
    inkMuted: Color(0xFF475569),
    primary: Color(0xFF4338CA),
    primaryEdge: Color(0xFF312E81),
    primarySoft: Color(0xFFEEF2FF),
    onPrimarySoft: Color(0xFF312E81),
    onPrimary: Color(0xFFFFFFFF),
    reward: Color(0xFFF59E0B),
    onReward: Color(0xFF3D1A00),
    error: Color(0xFFDC2626),
    speaking: SkillColors(
      Color(0xFFFFEDD5),
      Color(0xFF7C2D12),
      Color(0xFFFDBA74),
    ),
    listening: SkillColors(
      Color(0xFFD1FAE5),
      Color(0xFF064E3B),
      Color(0xFF6EE7B7),
    ),
    writing: SkillColors(
      Color(0xFFEDE9FE),
      Color(0xFF4C1D95),
      Color(0xFFC4B5FD),
    ),
    reading: SkillColors(
      Color(0xFFE0F2FE),
      Color(0xFF0C4A6E),
      Color(0xFF7DD3FC),
    ),
  );
  static const dark = AppPalette(
    background: Color(0xFF030712),
    surface: Color(0xFF0F172A),
    muted: Color(0xFF1E293B),
    outline: Color(0xFF334155),
    ink: Color(0xFFF8FAFC),
    inkMuted: Color(0xFF94A3B8),
    primary: Color(0xFF818CF8),
    primaryEdge: Color(0xFF4F46E5),
    primarySoft: Color(0xFF1E1B4B),
    onPrimarySoft: Color(0xFFEEF2FF),
    onPrimary: Color(0xFF0F172A),
    reward: Color(0xFFFBBF24),
    onReward: Color(0xFF2E1500),
    error: Color(0xFFFECACA),
    speaking: SkillColors(
      Color(0xFF431407),
      Color(0xFFFFEDD5),
      Color(0xFF7C2D12),
    ),
    listening: SkillColors(
      Color(0xFF022C22),
      Color(0xFFD1FAE5),
      Color(0xFF064E3B),
    ),
    writing: SkillColors(
      Color(0xFF2E1065),
      Color(0xFFEDE9FE),
      Color(0xFF4C1D95),
    ),
    reading: SkillColors(
      Color(0xFF082F49),
      Color(0xFFE0F2FE),
      Color(0xFF0C4A6E),
    ),
  );

  /// Reads tokens, including a fallback for isolated Material widget tests.
  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);
  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? muted,
    Color? outline,
    Color? ink,
    Color? inkMuted,
    Color? primary,
    Color? primaryEdge,
    Color? primarySoft,
    Color? onPrimarySoft,
    Color? onPrimary,
    Color? reward,
    Color? onReward,
    Color? error,
    SkillColors? speaking,
    SkillColors? listening,
    SkillColors? writing,
    SkillColors? reading,
  }) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    muted: muted ?? this.muted,
    outline: outline ?? this.outline,
    ink: ink ?? this.ink,
    inkMuted: inkMuted ?? this.inkMuted,
    primary: primary ?? this.primary,
    primaryEdge: primaryEdge ?? this.primaryEdge,
    primarySoft: primarySoft ?? this.primarySoft,
    onPrimarySoft: onPrimarySoft ?? this.onPrimarySoft,
    onPrimary: onPrimary ?? this.onPrimary,
    reward: reward ?? this.reward,
    onReward: onReward ?? this.onReward,
    error: error ?? this.error,
    speaking: speaking ?? this.speaking,
    listening: listening ?? this.listening,
    writing: writing ?? this.writing,
    reading: reading ?? this.reading,
  );
  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      muted: c(muted, other.muted),
      outline: c(outline, other.outline),
      ink: c(ink, other.ink),
      inkMuted: c(inkMuted, other.inkMuted),
      primary: c(primary, other.primary),
      primaryEdge: c(primaryEdge, other.primaryEdge),
      primarySoft: c(primarySoft, other.primarySoft),
      onPrimarySoft: c(onPrimarySoft, other.onPrimarySoft),
      onPrimary: c(onPrimary, other.onPrimary),
      reward: c(reward, other.reward),
      onReward: c(onReward, other.onReward),
      error: c(error, other.error),
      speaking: speaking.lerp(other.speaking, t),
      listening: listening.lerp(other.listening, t),
      writing: writing.lerp(other.writing, t),
      reading: reading.lerp(other.reading, t),
    );
  }
}
