import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:give_track/config/app_design_tokens.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(_lightScheme, isDark: false);
  static ThemeData get darkTheme => _buildTheme(_darkScheme, isDark: true);

  static ColorScheme get _lightScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
      primary: AppColors.forest,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.mint,
      onPrimaryContainer: AppColors.forest,
      secondary: AppColors.lime,
      onSecondary: AppColors.forest,
      secondaryContainer: const Color(0xFFE8F5D0),
      onSecondaryContainer: AppColors.forest,
      tertiary: AppColors.chartOrange,
      onTertiary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outlineMuted,
      outlineVariant: AppColors.outlineVariantLight,
      surfaceContainerHighest: AppColors.mint,
      surfaceContainerHigh: const Color(0xFFEEF6E5),
      surfaceContainer: const Color(0xFFF5FAF0),
    );
  }

  static ColorScheme get _darkScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.lime,
      brightness: Brightness.dark,
      primary: AppColors.lime,
      onPrimary: AppColors.forest,
      primaryContainer: AppColors.forest,
      onPrimaryContainer: AppColors.lime,
      secondary: AppColors.lime,
      onSecondary: AppColors.forest,
      secondaryContainer: const Color(0xFF1E3D28),
      onSecondaryContainer: AppColors.lime,
      tertiary: const Color(0xFFFFAB70),
      onTertiary: AppColors.forest,
      error: const Color(0xFFEF5350),
      onError: AppColors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.white,
      onSurfaceVariant: const Color(0xFFB0B0B0),
      outline: const Color(0xFF3D5245),
      outlineVariant: const Color(0xFF2A3830),
      surfaceContainerHighest: AppColors.darkSurfaceHigh,
      surfaceContainerHigh: const Color(0xFF1A2820),
      surfaceContainer: const Color(0xFF14221A),
    );
  }

  static ThemeData _buildTheme(ColorScheme scheme, {required bool isDark}) {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [isDark ? GiveTrackTokens.dark : GiveTrackTokens.light],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.primaryContainer,
        shadowColor: Colors.transparent,
        shape: cardShape,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        backgroundColor: scheme.surface,
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
    );
  }
}
