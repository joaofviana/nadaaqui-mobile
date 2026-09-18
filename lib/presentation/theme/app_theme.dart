import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

ThemeData buildNadaAquiDarkTheme() {
  const tokens = NadaTokens.dark;
  final scheme = ColorScheme.dark(
    primary: tokens.accent,
    onPrimary: Colors.black,
    secondary: tokens.surface2,
    onSecondary: tokens.text,
    surface: tokens.surface,
    onSurface: tokens.text,
    outline: tokens.border,
    error: tokens.error,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.bg,
    dividerColor: tokens.hairline,
    extensions: const [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bg,
      foregroundColor: tokens.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: tokens.text,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    ),
    textTheme: _textTheme(tokens),
    chipTheme: _chipTheme(tokens, lightBorder: false),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.navBg,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: tokens.navInactive),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.ctaStrongBg,
        foregroundColor: tokens.ctaStrongFg,
        minimumSize: const Size.fromHeight(48),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: tokens.fabBg,
      foregroundColor: tokens.fabFg,
      elevation: 4,
      shape: const CircleBorder(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return tokens.accent;
        return tokens.border;
      }),
    ),
    dividerTheme: DividerThemeData(
      color: tokens.hairline,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface,
      hintStyle: TextStyle(color: tokens.inputPlaceholder),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: tokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: tokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: tokens.accent, width: 1.5),
      ),
    ),
  );
}

ThemeData buildNadaAquiLightTheme() {
  const tokens = NadaTokens.light;
  final scheme = ColorScheme.light(
    primary: tokens.accent,
    onPrimary: Colors.white,
    secondary: tokens.surface2,
    onSecondary: tokens.text,
    surface: tokens.surface,
    onSurface: tokens.text,
    outline: tokens.border,
    error: tokens.error,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.bg,
    dividerColor: tokens.hairline,
    extensions: const [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bg,
      foregroundColor: tokens.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: tokens.text,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    ),
    textTheme: _textTheme(tokens),
    chipTheme: _chipTheme(tokens, lightBorder: true),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.navBg,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: tokens.navInactive),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.ctaBg,
        foregroundColor: tokens.ctaFg,
        minimumSize: const Size.fromHeight(48),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: tokens.fabBg,
      foregroundColor: tokens.fabFg,
      elevation: 4,
      shape: const CircleBorder(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return tokens.accent;
        return tokens.border;
      }),
    ),
    dividerTheme: DividerThemeData(
      color: tokens.hairline,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface,
      hintStyle: TextStyle(color: tokens.inputPlaceholder),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: tokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: tokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: tokens.accent, width: 1.5),
      ),
    ),
  );
}

/// Default app theme = dark OLED.
ThemeData buildNadaAquiTheme() => buildNadaAquiDarkTheme();

TextTheme _textTheme(NadaTokens t) {
  return TextTheme(
    headlineLarge: TextStyle(
      color: t.text,
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
    ),
    headlineSmall: TextStyle(
      color: t.text,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      color: t.text,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: t.text,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: t.text,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      color: t.text,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: t.textMuted,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: t.text,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
}

ChipThemeData _chipTheme(NadaTokens t, {required bool lightBorder}) {
  return ChipThemeData(
    backgroundColor: t.chipInactiveBg,
    selectedColor: t.chipActiveBg,
    disabledColor: t.surface2,
    side: BorderSide(color: lightBorder ? t.border : Colors.transparent),
    labelStyle: TextStyle(
      color: t.chipInactiveFg,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),
    secondaryLabelStyle: TextStyle(
      color: t.chipActiveFg,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: const StadiumBorder(),
    showCheckmark: false,
  );
}
