import 'package:flutter/material.dart';

import 'app_palette.dart';
export 'app_palette.dart';

/// Material 3 mapping of the “Botanical Study Ledger” flat, bordered design system.
class AppTheme {
  AppTheme._();
  static const seed = Color(0xFF1B6E66);
  static const rewardSeed = Color(0xFFF2911B);
  static const qrPaper = Color(0xFFFFFFFF);
  static const qrInk = Color(0xFF171923);

  /// Builds the warm herbarium-vellum light appearance.
  static ThemeData light() => _build(Brightness.light, AppPalette.light);

  /// Builds the contrast-safe nocturnal-herbarium dark appearance.
  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);
  static ThemeData _build(Brightness brightness, AppPalette p) {
    const tabular = [FontFeature.tabularFigures()];
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness)
        .copyWith(
          primary: p.primary,
          onPrimary: p.onPrimary,
          primaryContainer: p.primarySoft,
          onPrimaryContainer: p.onPrimarySoft,
          secondary: p.primary,
          onSecondary: p.onPrimary,
          secondaryContainer: p.primarySoft,
          onSecondaryContainer: p.onPrimarySoft,
          tertiary: p.primary,
          onTertiary: p.onPrimary,
          tertiaryContainer: p.primarySoft,
          onTertiaryContainer: p.onPrimarySoft,
          surface: p.surface,
          onSurface: p.ink,
          onSurfaceVariant: p.inkMuted,
          surfaceContainerLowest: p.surface,
          surfaceContainerLow: p.surface,
          surfaceContainer: p.muted,
          surfaceContainerHigh: p.muted,
          surfaceContainerHighest: p.muted,
          outline: p.inkMuted,
          outlineVariant: p.outline,
          error: p.error,
          surfaceTint: p.surface,
        );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Be Vietnam Pro',
    );
    final text = base.textTheme
        .copyWith(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -.6,
            fontFeatures: tabular,
            color: p.ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
            fontFeatures: tabular,
            color: p.ink,
          ),
          headlineSmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -.4,
            fontFeatures: tabular,
            color: p.ink,
          ),
          titleLarge: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -.3,
            fontFeatures: tabular,
            color: p.ink,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFeatures: tabular,
            color: p.ink,
          ),
          titleSmall: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFeatures: tabular,
            color: p.ink,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: p.ink),
          bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: p.ink),
          bodySmall: TextStyle(
            fontSize: 13,
            height: 1.5,
            fontFeatures: tabular,
            color: p.inkMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFeatures: tabular,
            color: p.ink,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFeatures: tabular,
            color: p.inkMuted,
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            fontFeatures: tabular,
            color: p.inkMuted,
          ),
        )
        .apply(fontFamily: 'Be Vietnam Pro');
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: p.outline, width: 2),
    );
    return base.copyWith(
      extensions: [p],
      scaffoldBackgroundColor: p.background,
      textTheme: text,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primarySoft,
        selectionHandleColor: p.primary,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: p.background,
        titleTextStyle: text.titleLarge?.copyWith(fontSize: 18),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: p.surface,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: p.outline, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        filled: true,
        fillColor: p.surface,
        labelStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          elevation: 0,
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          backgroundColor: p.surface,
          foregroundColor: p.ink,
          side: BorderSide(color: p.outline, width: 2),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: p.surface,
        surfaceTintColor: p.surface,
        indicatorColor: p.primarySoft,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall!.copyWith(
            fontSize: 11,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: s.contains(WidgetState.selected)
                ? p.onPrimarySoft
                : p.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected)
                ? p.onPrimarySoft
                : p.inkMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        indicatorColor: p.primarySoft,
        indicatorShape: const StadiumBorder(),
        selectedIconTheme: IconThemeData(color: p.onPrimarySoft, size: 22),
        unselectedIconTheme: IconThemeData(color: p.inkMuted, size: 22),
        selectedLabelTextStyle: text.labelSmall!.copyWith(
          fontWeight: FontWeight.w800,
          color: p.onPrimarySoft,
        ),
        unselectedLabelTextStyle: text.labelSmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: p.inkMuted,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.muted,
        circularTrackColor: p.muted,
        linearMinHeight: 10,
        borderRadius: BorderRadius.circular(999),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(color: p.outline, width: 1.5),
        backgroundColor: p.muted,
        selectedColor: p.primarySoft,
        labelStyle: text.labelMedium,
      ),
      dividerTheme: DividerThemeData(color: p.outline, thickness: 2),
      listTileTheme: ListTileThemeData(
        iconColor: p.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
    );
  }
}
