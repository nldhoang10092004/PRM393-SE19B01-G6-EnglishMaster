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

/// Semantic colours from the approved “Khối màu tươi” component sheet.
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
    background: Color(0xFFFFFBF6),
    surface: Color(0xFFFFFFFF),
    muted: Color(0xFFF3ECE3),
    outline: Color(0xFFEADFD2),
    ink: Color(0xFF1C1B2E),
    inkMuted: Color(0xFF5B5870),
    primary: Color(0xFF3D5AFE),
    primaryEdge: Color(0xFF2638C9),
    primarySoft: Color(0xFFE3E8FF),
    onPrimarySoft: Color(0xFF1C2A8F),
    onPrimary: Color(0xFFFFFFFF),
    reward: Color(0xFFFF9B26),
    onReward: Color(0xFF3D1E00),
    error: Color(0xFFB3261E),
    speaking: SkillColors(
      Color(0xFFFFE3C2),
      Color(0xFF6B3300),
      Color(0xFFF2C48F),
    ),
    listening: SkillColors(
      Color(0xFFCFF3DA),
      Color(0xFF0E5A2B),
      Color(0xFF9ED9B1),
    ),
    writing: SkillColors(
      Color(0xFFE6DCFF),
      Color(0xFF4B2A9E),
      Color(0xFFC4B2F2),
    ),
    reading: SkillColors(
      Color(0xFFD6E6FF),
      Color(0xFF123F8C),
      Color(0xFFA9C6F5),
    ),
  );
  static const dark = AppPalette(
    background: Color(0xFF17151F),
    surface: Color(0xFF24212D),
    muted: Color(0xFF332E3B),
    outline: Color(0xFF51495B),
    ink: Color(0xFFF7F0FF),
    inkMuted: Color(0xFFCDC4DA),
    primary: Color(0xFFB7C2FF),
    primaryEdge: Color(0xFF7385E0),
    primarySoft: Color(0xFF303B70),
    onPrimarySoft: Color(0xFFE2E6FF),
    onPrimary: Color(0xFF14236B),
    reward: Color(0xFFFFB65E),
    onReward: Color(0xFF3D1E00),
    error: Color(0xFFFFB4AB),
    speaking: SkillColors(
      Color(0xFF4A2D15),
      Color(0xFFFFD7AB),
      Color(0xFF82562E),
    ),
    listening: SkillColors(
      Color(0xFF173D28),
      Color(0xFFB8F2CB),
      Color(0xFF3B7450),
    ),
    writing: SkillColors(
      Color(0xFF352450),
      Color(0xFFE0CEFF),
      Color(0xFF71559E),
    ),
    reading: SkillColors(
      Color(0xFF1D3456),
      Color(0xFFCDE1FF),
      Color(0xFF496F9F),
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
