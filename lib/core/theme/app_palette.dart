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
    background: Color(0xFFF6F7F4),
    surface: Color(0xFFFFFFFF),
    muted: Color(0xFFEAF0EC),
    outline: Color(0xFFD2DDD6),
    ink: Color(0xFF15201C),
    inkMuted: Color(0xFF475750),
    primary: Color(0xFF1B6E66),
    primaryEdge: Color(0xFF104943),
    primarySoft: Color(0xFFD8F0EC),
    onPrimarySoft: Color(0xFF0C3B36),
    onPrimary: Color(0xFFFFFFFF),
    reward: Color(0xFFF2911B),
    onReward: Color(0xFF2B1400),
    error: Color(0xFFB42318),
    speaking: SkillColors(
      Color(0xFFFCE6CF),
      Color(0xFF5C2800),
      Color(0xFFE5BA8F),
    ),
    listening: SkillColors(
      Color(0xFFD5F2E0),
      Color(0xFF0B4D26),
      Color(0xFF9AD4B2),
    ),
    writing: SkillColors(
      Color(0xFFE8E2F8),
      Color(0xFF3A207E),
      Color(0xFFC1B3E8),
    ),
    reading: SkillColors(
      Color(0xFFD9EAFD),
      Color(0xFF0F3B7A),
      Color(0xFFA6C8F0),
    ),
  );
  static const dark = AppPalette(
    background: Color(0xFF111715),
    surface: Color(0xFF1A221F),
    muted: Color(0xFF25302C),
    outline: Color(0xFF3E4E48),
    ink: Color(0xFFEEF5F1),
    inkMuted: Color(0xFFB8C9C1),
    primary: Color(0xFF7CE0D3),
    primaryEdge: Color(0xFF3E9E92),
    primarySoft: Color(0xFF1D423E),
    onPrimarySoft: Color(0xFFD8F6F2),
    onPrimary: Color(0xFF082925),
    reward: Color(0xFFFFB55E),
    onReward: Color(0xFF2E1500),
    error: Color(0xFFFFB4AB),
    speaking: SkillColors(
      Color(0xFF422712),
      Color(0xFFFFD8B0),
      Color(0xFF7D5029),
    ),
    listening: SkillColors(
      Color(0xFF143825),
      Color(0xFFB8F4CE),
      Color(0xFF35704E),
    ),
    writing: SkillColors(
      Color(0xFF2E2147),
      Color(0xFFE2D4FF),
      Color(0xFF685096),
    ),
    reading: SkillColors(
      Color(0xFF18304C),
      Color(0xFFCDE3FF),
      Color(0xFF426A99),
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
