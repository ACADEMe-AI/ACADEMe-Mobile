import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  static const background = Color(0xFF0B0C0F);
  static const surface = Color(0xFF14161C);
  static const surfaceRaised = Color(0xFF1C1F28);
  static const border = Color(0xFF2A2E38);
  static const text = Color(0xFFF2F3F5);
  static const textMuted = Color(0xFF8B93A7);
  static const textFaint = Color(0xFF5C6578);

  static const primary = Color(0xFF564CF1);
  static const primaryPressed = Color(0xFF4A59E6);
  static const onPrimary = Color(0xFFFFFFFF);
  static const accent = Color(0xFF7CFFB2);
  static const success = Color(0xFF3DDC97);
  static const warning = Color(0xFFFFC14D);
  static const error = Color(0xFFFF5C6A);
  static const streak = Color(0xFFFF8A4C);

  static const splash = Color(0xFF171726);

  static const lightBackground = Color(0xFFF6F7FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceRaised = Color(0xFFEEF0F5);
  static const lightBorder = Color(0xFFD8DCE6);
  static const lightText = Color(0xFF12141A);
  static const lightTextMuted = Color(0xFF5C6578);
  static const lightShadow = Color(0x1712141A);
  static const lightSuccess = Color(0xFF0D9F6E);

  static const pebby = Color(0xFF8B8CF5);

  static const selected = Color(0xFFF5A800);

  static const keycapEdge = Color(0xFF12141A);

  static const pebbyLight = Color(0xFFA2A4FB);
  static const pebbyMid = Color(0xFF8B8CF5);
  static const pebbyDeep = Color(0xFF6E71D6);
  static const pebbySheen = Color(0x33FFFFFF);

  static const tintLavender = Color(0xFFE7E6FF);
  static const tintAmber = Color(0xFFFFE7A3);
  static const tintMint = Color(0xFFD9F4EA);
  static const tintPink = Color(0xFFFFE0EC);
  static const tintSky = Color(0xFFDCEBFF);
  static const tintCream = Color(0xFFFFF9E8);
  static const tintRose = Color(0xFFFFE3E0);
  static const errorInk = Color(0xFFB42332);
  static const selectedInk = Color(0xFF8A6100);
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const full = 999.0;
}

abstract final class AppKeycap {
  static const borderWidth = 2.0;
  static const radius = AppRadius.lg;

  static const buttonDepth = 6.0;
  static const optionDepth = 4.5;

  static const pressDuration = Duration(milliseconds: 90);

  static const disabledAlpha = .45;
}

abstract final class AppTextStyles {
  static const _indicFallback = [
    'NotoSansDevanagari',
    'NotoSansTelugu',
    'NotoSansTamil',
    'NotoSansBengali',
  ];

  static const display = TextStyle(
    fontFamily: 'Baloo2',
    fontFamilyFallback: [
      'BalooTammudu2',
      'BalooThambi2',
      'BalooDa2',
      'NotoSans',
      ..._indicFallback,
    ],
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const subhead = TextStyle(
    fontFamily: 'Archivo',
    fontFamilyFallback: ['NotoSans', ..._indicFallback],
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static final sheetTitle = display.copyWith(fontSize: 24);

  static const caption = TextStyle(fontSize: 12);
  static const label = TextStyle(fontSize: 14);
  static const labelStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const input = TextStyle(fontSize: 16);
}

abstract final class AppSystemBars {
  static const onLight = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
  );

  static const onDark = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
  );
}

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.shadow,
    required this.success,
    required this.tintLavender,
    required this.tintAmber,
    required this.tintMint,
    required this.tintPink,
    required this.tintSky,
    required this.tintCream,
    required this.tintRose,
    required this.errorInk,
    required this.edge,
  });

  static const light = AppPalette(
    isDark: false,
    surface: AppColors.lightSurface,
    surfaceRaised: AppColors.lightSurfaceRaised,
    border: AppColors.lightBorder,
    text: AppColors.lightText,
    textMuted: AppColors.lightTextMuted,
    shadow: AppColors.lightShadow,
    success: AppColors.lightSuccess,
    tintLavender: AppColors.tintLavender,
    tintAmber: AppColors.tintAmber,
    tintMint: AppColors.tintMint,
    tintPink: AppColors.tintPink,
    tintSky: AppColors.tintSky,
    tintCream: AppColors.tintCream,
    tintRose: AppColors.tintRose,
    errorInk: AppColors.errorInk,
    edge: AppColors.keycapEdge,
  );

  static const dark = AppPalette(
    isDark: true,
    surface: AppColors.splash,
    surfaceRaised: Color(0xFF24243C),
    border: Color(0xFF3A3B5E),
    text: Color(0xFFF2F3F8),
    textMuted: Color(0xFFA3A6C4),
    shadow: Color(0x66000000),
    success: AppColors.success,
    tintLavender: Color(0xFF2F2D63),
    tintAmber: Color(0xFF4A3B12),
    tintMint: Color(0xFF14402F),
    tintPink: Color(0xFF4C1F36),
    tintSky: Color(0xFF1B3354),
    tintCream: Color(0xFF34301F),
    tintRose: Color(0xFF4C2127),
    errorInk: Color(0xFFFF9AA3),
    edge: Color(0xFF45476F),
  );

  final bool isDark;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color shadow;
  final Color success;
  final Color tintLavender;
  final Color tintAmber;
  final Color tintMint;
  final Color tintPink;
  final Color tintSky;
  final Color tintCream;
  final Color tintRose;
  final Color errorInk;
  final Color edge;

  List<Color> get tints => [
    tintLavender,
    tintAmber,
    tintMint,
    tintPink,
    tintSky,
  ];

  SystemUiOverlayStyle get systemBars =>
      isDark ? AppSystemBars.onDark : AppSystemBars.onLight;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      isDark: t < .5 ? isDark : other.isDark,
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      border: mix(border, other.border),
      text: mix(text, other.text),
      textMuted: mix(textMuted, other.textMuted),
      shadow: mix(shadow, other.shadow),
      success: mix(success, other.success),
      tintLavender: mix(tintLavender, other.tintLavender),
      tintAmber: mix(tintAmber, other.tintAmber),
      tintMint: mix(tintMint, other.tintMint),
      tintPink: mix(tintPink, other.tintPink),
      tintSky: mix(tintSky, other.tintSky),
      tintCream: mix(tintCream, other.tintCream),
      tintRose: mix(tintRose, other.tintRose),
      errorInk: mix(errorInk, other.errorInk),
      edge: mix(edge, other.edge),
    );
  }
}

extension AppPaletteOf on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

abstract final class AppTheme {
  static ThemeData dark({AppPalette palette = AppPalette.light}) {
    final base = ThemeData(
      extensions: [palette],
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'NotoSans',
      fontFamilyFallback: AppTextStyles._indicFallback,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSurface: AppColors.text,
      ),
    );
    final text = base.textTheme;
    TextStyle? asDisplay(TextStyle? style) =>
        style?.merge(AppTextStyles.display);
    TextStyle? asSubhead(TextStyle? style) =>
        style?.merge(AppTextStyles.subhead);
    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: asDisplay(text.displayLarge),
        displayMedium: asDisplay(text.displayMedium),
        displaySmall: asDisplay(text.displaySmall),
        headlineLarge: asDisplay(text.headlineLarge),
        headlineMedium: asDisplay(text.headlineMedium),
        headlineSmall: asDisplay(text.headlineSmall),
        titleLarge: asSubhead(text.titleLarge),
        titleMedium: asSubhead(text.titleMedium),
      ),
    );
  }
}
