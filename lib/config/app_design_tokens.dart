import 'package:flutter/material.dart';

/// Brand palette extracted from the fintech reference (forest, lime, mint).
abstract final class AppColors {
  static const Color forest = Color(0xFF14361B);
  static const Color lime = Color(0xFFB6F07A);
  static const Color mint = Color(0xFFF2F9EB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color chartOrange = Color(0xFFFF8A4C);
  static const Color chartGrass = Color(0xFF6BAF4A);
  static const Color chartNeutral = Color(0xFF9E9E9E);
  static const Color error = Color(0xFFC62828);
  static const Color darkSurface = Color(0xFF0D1A12);
  static const Color darkSurfaceHigh = Color(0xFF162820);
  static const Color outlineMuted = Color(0xFFD4DFCC);
  static const Color outlineVariantLight = Color(0xFFE8EDE3);
}

/// Corner radii — cards ~22–24px; controls pill-shaped (~28px).
abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double pill = 28;
}

/// Extra colors for charts / legacy widgets (ThemeExtension).
@immutable
class GiveTrackTokens extends ThemeExtension<GiveTrackTokens> {
  const GiveTrackTokens({
    required this.chartOrange,
    required this.chartGrass,
    required this.chartNeutral,
  });

  final Color chartOrange;
  final Color chartGrass;
  final Color chartNeutral;

  /// Default when no extension is registered (should not happen in app).
  static const GiveTrackTokens light = GiveTrackTokens(
    chartOrange: AppColors.chartOrange,
    chartGrass: AppColors.chartGrass,
    chartNeutral: AppColors.chartNeutral,
  );

  static const GiveTrackTokens dark = GiveTrackTokens(
    chartOrange: Color(0xFFFFAB70),
    chartGrass: Color(0xFF8FD96E),
    chartNeutral: Color(0xFF8A8A8A),
  );

  @override
  GiveTrackTokens copyWith({
    Color? chartOrange,
    Color? chartGrass,
    Color? chartNeutral,
  }) {
    return GiveTrackTokens(
      chartOrange: chartOrange ?? this.chartOrange,
      chartGrass: chartGrass ?? this.chartGrass,
      chartNeutral: chartNeutral ?? this.chartNeutral,
    );
  }

  @override
  GiveTrackTokens lerp(ThemeExtension<GiveTrackTokens>? other, double t) {
    if (other is! GiveTrackTokens) return this;
    return GiveTrackTokens(
      chartOrange: Color.lerp(chartOrange, other.chartOrange, t)!,
      chartGrass: Color.lerp(chartGrass, other.chartGrass, t)!,
      chartNeutral: Color.lerp(chartNeutral, other.chartNeutral, t)!,
    );
  }
}
