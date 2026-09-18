import 'package:flutter/material.dart';

/// Pool-theme tokens (TOKENS.md). Prefer [NadaTokens.of] in widgets.
/// Static getters below mirror **dark OLED** (app default) for rare
/// context-free call sites; themed screens must use ThemeExtension.
abstract final class AppColors {
  // —— Dark OLED (default) ——
  static const Color bg = Color(0xFF000000);
  static const Color bgElevated = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surface2 = Color(0xFF2C2C2E);
  static const Color text = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF8E8E93);
  static const Color accent = Color(0xFF2DD4BF);
  static const Color teal = accent; // alias legado
  static const Color tealSoft = Color(0xFF134E4A);
  static const Color hairline = Color(0xFF1C1C1E);
  static const Color border = Color(0xFF2C2C2E);
  static const Color star = Color(0xFFFBBF24);
  static const Color fabBg = Color(0xFFFFFFFF);
  static const Color fabFg = Color(0xFF000000);
  static const Color navBg = Color(0xFF000000);
  static const Color navActive = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF636366);
  static const Color chipActiveBg = Color(0xFFFFFFFF);
  static const Color chipActiveFg = Color(0xFF000000);
  static const Color chipInactiveBg = Color(0xFF2C2C2E);
  static const Color chipInactiveFg = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF453A);
  static const Color errorBg = Color(0xFF3B1210);

  // Distance (dark)
  static const Color distGreen = Color(0xFF4ADE80);
  static const Color distGreenBg = Color(0xFF052E16);
  static const Color distGreenBorder = Color(0xFF166534);
  static const Color distAmber = Color(0xFFFBBF24);
  static const Color distAmberBg = Color(0xFF422006);
  static const Color distAmberBorder = Color(0xFFB45309);
  static const Color distGray = Color(0xFFA1A1AA);
  static const Color distGrayBg = Color(0xFF27272A);
  static const Color distGrayBorder = Color(0xFF52525B);

  // GPS banner (amber alert — shared)
  static const Color gpsBannerBg = Color(0xFF422006);
  static const Color gpsBannerBorder = Color(0xFFB45309);
  static const Color gpsBannerTitle = Color(0xFFFBBF24);
  static const Color gpsBannerBody = Color(0xFFFDE68A);
  static const Color gpsBannerBtn = Color(0xFFFBBF24);
}

/// Theme-aware pool tokens (dark OLED + light pool-blue).
@immutable
class NadaTokens extends ThemeExtension<NadaTokens> {
  const NadaTokens({
    required this.bg,
    required this.bgElevated,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.chipActiveBg,
    required this.chipActiveFg,
    required this.chipInactiveBg,
    required this.chipInactiveFg,
    required this.fabBg,
    required this.fabFg,
    required this.navBg,
    required this.navActive,
    required this.navInactive,
    required this.border,
    required this.hairline,
    required this.ctaBg,
    required this.ctaFg,
    required this.ctaStrongBg,
    required this.ctaStrongFg,
    required this.mapBg,
    required this.mapGrid,
    required this.mapRoad,
    required this.mapLabel,
    required this.pin,
    required this.error,
    required this.errorBg,
    required this.distGreenFg,
    required this.distGreenBg,
    required this.distGreenBd,
    required this.distAmberFg,
    required this.distAmberBg,
    required this.distAmberBd,
    required this.distGrayFg,
    required this.distGrayBg,
    required this.distGrayBd,
    required this.badgeBd,
    required this.badgeFg,
    required this.star,
    required this.inputPlaceholder,
    required this.sheetHandle,
    required this.presenceEmpty,
    required this.presenceLow,
    required this.presenceFull,
  });

  final Color bg;
  final Color bgElevated;
  final Color surface;
  final Color surface2;
  final Color text;
  final Color textMuted;
  final Color accent;
  final Color chipActiveBg;
  final Color chipActiveFg;
  final Color chipInactiveBg;
  final Color chipInactiveFg;
  final Color fabBg;
  final Color fabFg;
  final Color navBg;
  final Color navActive;
  final Color navInactive;
  final Color border;
  final Color hairline;
  final Color ctaBg;
  final Color ctaFg;
  final Color ctaStrongBg;
  final Color ctaStrongFg;
  final Color mapBg;
  final Color mapGrid;
  final Color mapRoad;
  final Color mapLabel;
  final Color pin;
  final Color error;
  final Color errorBg;
  final Color distGreenFg;
  final Color distGreenBg;
  final Color distGreenBd;
  final Color distAmberFg;
  final Color distAmberBg;
  final Color distAmberBd;
  final Color distGrayFg;
  final Color distGrayBg;
  final Color distGrayBd;
  final Color badgeBd;
  final Color badgeFg;
  final Color star;
  final Color inputPlaceholder;
  final Color sheetHandle;
  final Color presenceEmpty;
  final Color presenceLow;
  final Color presenceFull;

  static const dark = NadaTokens(
    bg: Color(0xFF000000),
    bgElevated: Color(0xFF0A0A0A),
    surface: Color(0xFF1C1C1E),
    surface2: Color(0xFF2C2C2E),
    text: Color(0xFFFFFFFF),
    textMuted: Color(0xFF8E8E93),
    accent: Color(0xFF2DD4BF),
    chipActiveBg: Color(0xFFFFFFFF),
    chipActiveFg: Color(0xFF000000),
    chipInactiveBg: Color(0xFF2C2C2E),
    chipInactiveFg: Color(0xFFFFFFFF),
    fabBg: Color(0xFFFFFFFF),
    fabFg: Color(0xFF000000),
    navBg: Color(0xFF000000),
    navActive: Color(0xFFFFFFFF),
    navInactive: Color(0xFF636366),
    border: Color(0xFF2C2C2E),
    hairline: Color(0xFF1C1C1E),
    ctaBg: Color(0xFF8E8E93),
    ctaFg: Color(0xFF000000),
    ctaStrongBg: Color(0xFFFFFFFF),
    ctaStrongFg: Color(0xFF000000),
    mapBg: Color(0xFF0A0A0A),
    mapGrid: Color(0xFF1C1C1E),
    mapRoad: Color(0xFF2C2C2E),
    mapLabel: Color(0xFF636366),
    pin: Color(0xFF2DD4BF),
    error: Color(0xFFFF453A),
    errorBg: Color(0xFF3B1210),
    distGreenFg: Color(0xFF4ADE80),
    distGreenBg: Color(0xFF052E16),
    distGreenBd: Color(0xFF166534),
    distAmberFg: Color(0xFFFBBF24),
    distAmberBg: Color(0xFF422006),
    distAmberBd: Color(0xFFB45309),
    distGrayFg: Color(0xFFA1A1AA),
    distGrayBg: Color(0xFF27272A),
    distGrayBd: Color(0xFF52525B),
    badgeBd: Color(0xFF3A3A3C),
    badgeFg: Color(0xFF8E8E93),
    star: Color(0xFFFBBF24),
    inputPlaceholder: Color(0xFF636366),
    sheetHandle: Color(0xFF3A3A3C),
    presenceEmpty: Color(0xFF4ADE80),
    presenceLow: Color(0xFFFBBF24),
    presenceFull: Color(0xFFFF453A),
  );

  static const light = NadaTokens(
    bg: Color(0xFFE0F7FA),
    bgElevated: Color(0xFFB2EBF2),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE0F2FE),
    text: Color(0xFF0C4A6E),
    textMuted: Color(0xFF0369A1),
    accent: Color(0xFF0284C7),
    chipActiveBg: Color(0xFF0284C7),
    chipActiveFg: Color(0xFFFFFFFF),
    chipInactiveBg: Color(0xFFFFFFFF),
    chipInactiveFg: Color(0xFF0C4A6E),
    fabBg: Color(0xFF0284C7),
    fabFg: Color(0xFFFFFFFF),
    navBg: Color(0xFFFFFFFF),
    navActive: Color(0xFF0284C7),
    navInactive: Color(0xFF64748B),
    border: Color(0xFF7DD3FC),
    hairline: Color(0xFFBAE6FD),
    ctaBg: Color(0xFF0284C7),
    ctaFg: Color(0xFFFFFFFF),
    ctaStrongBg: Color(0xFF0284C7),
    ctaStrongFg: Color(0xFFFFFFFF),
    mapBg: Color(0xFFE0F7FA),
    mapGrid: Color(0xFFB2EBF2),
    mapRoad: Color(0xFF81D4FA),
    mapLabel: Color(0xFF0284C7),
    pin: Color(0xFF0284C7),
    error: Color(0xFFDC2626),
    errorBg: Color(0xFFFEE2E2),
    distGreenFg: Color(0xFF15803D),
    distGreenBg: Color(0xFFDCFCE7),
    distGreenBd: Color(0xFF86EFAC),
    distAmberFg: Color(0xFFB45309),
    distAmberBg: Color(0xFFFEF3C7),
    distAmberBd: Color(0xFFFCD34D),
    distGrayFg: Color(0xFF52525B),
    distGrayBg: Color(0xFFF4F4F5),
    distGrayBd: Color(0xFFD4D4D8),
    badgeBd: Color(0xFF7DD3FC),
    badgeFg: Color(0xFF0369A1),
    star: Color(0xFFF59E0B),
    inputPlaceholder: Color(0xFF64748B),
    sheetHandle: Color(0xFF7DD3FC),
    presenceEmpty: Color(0xFF15803D),
    presenceLow: Color(0xFFB45309),
    presenceFull: Color(0xFFDC2626),
  );

  static NadaTokens of(BuildContext context) {
    return Theme.of(context).extension<NadaTokens>() ?? NadaTokens.dark;
  }

  @override
  NadaTokens copyWith({
    Color? bg,
    Color? bgElevated,
    Color? surface,
    Color? surface2,
    Color? text,
    Color? textMuted,
    Color? accent,
    Color? chipActiveBg,
    Color? chipActiveFg,
    Color? chipInactiveBg,
    Color? chipInactiveFg,
    Color? fabBg,
    Color? fabFg,
    Color? navBg,
    Color? navActive,
    Color? navInactive,
    Color? border,
    Color? hairline,
    Color? ctaBg,
    Color? ctaFg,
    Color? ctaStrongBg,
    Color? ctaStrongFg,
    Color? mapBg,
    Color? mapGrid,
    Color? mapRoad,
    Color? mapLabel,
    Color? pin,
    Color? error,
    Color? errorBg,
    Color? distGreenFg,
    Color? distGreenBg,
    Color? distGreenBd,
    Color? distAmberFg,
    Color? distAmberBg,
    Color? distAmberBd,
    Color? distGrayFg,
    Color? distGrayBg,
    Color? distGrayBd,
    Color? badgeBd,
    Color? badgeFg,
    Color? star,
    Color? inputPlaceholder,
    Color? sheetHandle,
    Color? presenceEmpty,
    Color? presenceLow,
    Color? presenceFull,
  }) {
    return NadaTokens(
      bg: bg ?? this.bg,
      bgElevated: bgElevated ?? this.bgElevated,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      chipActiveBg: chipActiveBg ?? this.chipActiveBg,
      chipActiveFg: chipActiveFg ?? this.chipActiveFg,
      chipInactiveBg: chipInactiveBg ?? this.chipInactiveBg,
      chipInactiveFg: chipInactiveFg ?? this.chipInactiveFg,
      fabBg: fabBg ?? this.fabBg,
      fabFg: fabFg ?? this.fabFg,
      navBg: navBg ?? this.navBg,
      navActive: navActive ?? this.navActive,
      navInactive: navInactive ?? this.navInactive,
      border: border ?? this.border,
      hairline: hairline ?? this.hairline,
      ctaBg: ctaBg ?? this.ctaBg,
      ctaFg: ctaFg ?? this.ctaFg,
      ctaStrongBg: ctaStrongBg ?? this.ctaStrongBg,
      ctaStrongFg: ctaStrongFg ?? this.ctaStrongFg,
      mapBg: mapBg ?? this.mapBg,
      mapGrid: mapGrid ?? this.mapGrid,
      mapRoad: mapRoad ?? this.mapRoad,
      mapLabel: mapLabel ?? this.mapLabel,
      pin: pin ?? this.pin,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      distGreenFg: distGreenFg ?? this.distGreenFg,
      distGreenBg: distGreenBg ?? this.distGreenBg,
      distGreenBd: distGreenBd ?? this.distGreenBd,
      distAmberFg: distAmberFg ?? this.distAmberFg,
      distAmberBg: distAmberBg ?? this.distAmberBg,
      distAmberBd: distAmberBd ?? this.distAmberBd,
      distGrayFg: distGrayFg ?? this.distGrayFg,
      distGrayBg: distGrayBg ?? this.distGrayBg,
      distGrayBd: distGrayBd ?? this.distGrayBd,
      badgeBd: badgeBd ?? this.badgeBd,
      badgeFg: badgeFg ?? this.badgeFg,
      star: star ?? this.star,
      inputPlaceholder: inputPlaceholder ?? this.inputPlaceholder,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      presenceEmpty: presenceEmpty ?? this.presenceEmpty,
      presenceLow: presenceLow ?? this.presenceLow,
      presenceFull: presenceFull ?? this.presenceFull,
    );
  }

  @override
  NadaTokens lerp(ThemeExtension<NadaTokens>? other, double t) {
    if (other is! NadaTokens) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return NadaTokens(
      bg: l(bg, other.bg),
      bgElevated: l(bgElevated, other.bgElevated),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      accent: l(accent, other.accent),
      chipActiveBg: l(chipActiveBg, other.chipActiveBg),
      chipActiveFg: l(chipActiveFg, other.chipActiveFg),
      chipInactiveBg: l(chipInactiveBg, other.chipInactiveBg),
      chipInactiveFg: l(chipInactiveFg, other.chipInactiveFg),
      fabBg: l(fabBg, other.fabBg),
      fabFg: l(fabFg, other.fabFg),
      navBg: l(navBg, other.navBg),
      navActive: l(navActive, other.navActive),
      navInactive: l(navInactive, other.navInactive),
      border: l(border, other.border),
      hairline: l(hairline, other.hairline),
      ctaBg: l(ctaBg, other.ctaBg),
      ctaFg: l(ctaFg, other.ctaFg),
      ctaStrongBg: l(ctaStrongBg, other.ctaStrongBg),
      ctaStrongFg: l(ctaStrongFg, other.ctaStrongFg),
      mapBg: l(mapBg, other.mapBg),
      mapGrid: l(mapGrid, other.mapGrid),
      mapRoad: l(mapRoad, other.mapRoad),
      mapLabel: l(mapLabel, other.mapLabel),
      pin: l(pin, other.pin),
      error: l(error, other.error),
      errorBg: l(errorBg, other.errorBg),
      distGreenFg: l(distGreenFg, other.distGreenFg),
      distGreenBg: l(distGreenBg, other.distGreenBg),
      distGreenBd: l(distGreenBd, other.distGreenBd),
      distAmberFg: l(distAmberFg, other.distAmberFg),
      distAmberBg: l(distAmberBg, other.distAmberBg),
      distAmberBd: l(distAmberBd, other.distAmberBd),
      distGrayFg: l(distGrayFg, other.distGrayFg),
      distGrayBg: l(distGrayBg, other.distGrayBg),
      distGrayBd: l(distGrayBd, other.distGrayBd),
      badgeBd: l(badgeBd, other.badgeBd),
      badgeFg: l(badgeFg, other.badgeFg),
      star: l(star, other.star),
      inputPlaceholder: l(inputPlaceholder, other.inputPlaceholder),
      sheetHandle: l(sheetHandle, other.sheetHandle),
      presenceEmpty: l(presenceEmpty, other.presenceEmpty),
      presenceLow: l(presenceLow, other.presenceLow),
      presenceFull: l(presenceFull, other.presenceFull),
    );
  }
}
