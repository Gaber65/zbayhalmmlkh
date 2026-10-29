import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../../../../core/config/app_config.dart';

/// Design tokens for the "ذبائح المملكة" mobile home & catalog pages.
///
/// Light mode values are taken from `design_reference/index.html` (390 px composition).
/// Dark mode values provide a warm-dark butcher palette via [KPalette.of].
class KColors {
  KColors._();

  static const red = Color(0xFFB22E28);
  static const redDark = Color(0xFF8E211E);
  static const ink = Color(0xFF272B26);
  static const muted = Color(0xFF74786F);
  static const line = Color(0xFFEAE9E2);
  static const cream = Color(0xFFF5F3ED);
  static const paper = Color(0xFFFBFAF7);
  static const green = Color(0xFF4E6754);
  static const gold = Color(0xFF9B7436);
}

/// Adaptive Light / Dark palette for all Kingdom mobile widgets.
class KPalette {
  final bool isDark;
  final Color paper;
  final Color card;
  final Color cream;
  final Color ink;
  final Color muted;
  final Color subtleText;
  final Color line;
  final Color inputBorder;
  final Color red;
  final Color redDark;
  final Color redSoftBg;
  final Color redSoftBorder;
  final Color green;
  final Color greenSoftBg;
  final Color greenSoftBorder;
  final Color gold;
  final Color goldStrong;
  final Color goldSoftBg;
  final Color goldSoftBorder;
  final Color navBg;
  final Color navInactive;
  final Color heartBg;
  final Color heartInactive;
  final Color logoCircleBg;
  final Color discountBadgeBg;
  final Color discountBadgeFg;
  final Color disabledBg;
  final Color disabledBorder;
  final Color disabledFg;
  final Color storyRingMuted;
  final Color storyInnerBg;
  final Color storyIconFg;
  final Color activeCartBg;
  final Color activeCartBorder;
  final Color activeCartFg;
  final Color activeCartSub;

  const KPalette({
    required this.isDark,
    required this.paper,
    required this.card,
    required this.cream,
    required this.ink,
    required this.muted,
    required this.subtleText,
    required this.line,
    required this.inputBorder,
    required this.red,
    required this.redDark,
    required this.redSoftBg,
    required this.redSoftBorder,
    required this.green,
    required this.greenSoftBg,
    required this.greenSoftBorder,
    required this.gold,
    required this.goldStrong,
    required this.goldSoftBg,
    required this.goldSoftBorder,
    required this.navBg,
    required this.navInactive,
    required this.heartBg,
    required this.heartInactive,
    required this.logoCircleBg,
    required this.discountBadgeBg,
    required this.discountBadgeFg,
    required this.disabledBg,
    required this.disabledBorder,
    required this.disabledFg,
    required this.storyRingMuted,
    required this.storyInnerBg,
    required this.storyIconFg,
    required this.activeCartBg,
    required this.activeCartBorder,
    required this.activeCartFg,
    required this.activeCartSub,
  });

  static const light = KPalette(
    isDark: false,
    paper: KColors.paper,
    card: Colors.white,
    cream: KColors.cream,
    ink: KColors.ink,
    muted: KColors.muted,
    subtleText: Color(0xFF6E7468),
    line: KColors.line,
    inputBorder: Color(0xFFDFDFD6),
    red: KColors.red,
    redDark: KColors.redDark,
    redSoftBg: Color(0xFFF8EEE8),
    redSoftBorder: Color(0xFFDFC1BA),
    green: KColors.green,
    greenSoftBg: Color(0xFFF5F8F1),
    greenSoftBorder: Color(0xFFD9E3D8),
    gold: Color(0xFF8A7450),
    goldStrong: Color(0xFF715A32),
    goldSoftBg: Color(0xFFF6F1E8),
    goldSoftBorder: Color(0xFFE7DED0),
    navBg: Color(0xFAFFFFFF),
    navInactive: Color(0xFF85897F),
    heartBg: Color(0xEEFFFFFF),
    heartInactive: Color(0xFF4C5148),
    logoCircleBg: Color(0xFFF1E9E0),
    discountBadgeBg: Color(0xFFFBF7E9),
    discountBadgeFg: Color(0xFF8C352B),
    disabledBg: Color(0xFFE9E9E3),
    disabledBorder: Color(0xFFE2E3DA),
    disabledFg: Color(0xFF7B8074),
    storyRingMuted: Color(0xFFCFCEC2),
    storyInnerBg: Color(0xFFECEBE1),
    storyIconFg: Color(0xFF7C694D),
    activeCartBg: Color(0xFFF6F1E8),
    activeCartBorder: Color(0xFFE7DED0),
    activeCartFg: Color(0xFF6F5B3A),
    activeCartSub: Color(0xFF8B7E68),
  );

  static const dark = KPalette(
    isDark: true,
    paper: Color(0xFF141613),
    card: Color(0xFF1E211D),
    cream: Color(0xFF272B25),
    ink: Color(0xFFF4F2EC),
    muted: Color(0xFFA3A79E),
    subtleText: Color(0xFFA9ADA3),
    line: Color(0xFF2E332C),
    inputBorder: Color(0xFF383E35),
    red: Color(0xFFD1433C),
    redDark: Color(0xFFB22E28),
    redSoftBg: Color(0xFF341E1C),
    redSoftBorder: Color(0xFF6E3530),
    green: Color(0xFF7DA386),
    greenSoftBg: Color(0xFF1E2920),
    greenSoftBorder: Color(0xFF2F4233),
    gold: Color(0xFFD5AB61),
    goldStrong: Color(0xFFE8C480),
    goldSoftBg: Color(0xFF282218),
    goldSoftBorder: Color(0xFF453926),
    navBg: Color(0xFA1A1D18),
    navInactive: Color(0xFF94988E),
    heartBg: Color(0xE6252923),
    heartInactive: Color(0xFFD4D6CE),
    logoCircleBg: Color(0xFF2B241E),
    discountBadgeBg: Color(0xFF33261A),
    discountBadgeFg: Color(0xFFF5B882),
    disabledBg: Color(0xFF282B26),
    disabledBorder: Color(0xFF343831),
    disabledFg: Color(0xFF757A70),
    storyRingMuted: Color(0xFF44483F),
    storyInnerBg: Color(0xFF2A2D26),
    storyIconFg: Color(0xFFC5AC87),
    activeCartBg: Color(0xFF272219),
    activeCartBorder: Color(0xFF423828),
    activeCartFg: Color(0xFFE6C896),
    activeCartSub: Color(0xFFBBA37A),
  );

  Color get surface => card;
  Color get inkMuted => muted;
  Color get inkSoft => subtleText;
  Color get navActivePill => redSoftBg;

  static KPalette of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Whether the current theme is Dark Mode.
bool kIsDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Whether the current locale is Arabic (RTL).
bool kIsAr(BuildContext context) {
  try {
    final code = Localizations.maybeLocaleOf(context)?.languageCode.toLowerCase();
    if (code != null) return code != 'en';
  } catch (_) {}
  return Directionality.maybeOf(context) != TextDirection.ltr;
}

/// Returns [ar] when locale is Arabic, or [en] when locale is English.
String kTr(BuildContext context, String ar, String en) =>
    kIsAr(context) ? ar : en;

/// Currency label (`ر.س` in Arabic, `SAR` in English).
String kCurrency(BuildContext context) => kTr(context, 'ر.س', 'SAR');

/// Font family registered and unified with Web (Cairo Arabic Font).
String get kFontFamily => GoogleFonts.cairo().fontFamily ?? 'IBMPlexSansArabic';

/// Builds a text style using the design font.
TextStyle kText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = KColors.ink,
  double height = 1.65,
  double? letterSpacing,
  TextDecoration? decoration,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontFamily: kFontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
    decorationColor: color,
    shadows: shadows,
  );
}

/// Height of [lines] lines of [style] under the ambient text scaler.
double kLineHeight(BuildContext context, TextStyle style, {int lines = 1}) {
  final scaler = MediaQuery.textScalerOf(context);
  final size = scaler.scale(style.fontSize ?? 14);
  return size * (style.height ?? 1.2) * lines;
}

/// Whether the layout should use the compact (< 360 px) variant.
bool kIsCompact(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

/// Horizontal page padding (20 px, 15 px on narrow phones).
double kPagePadding(BuildContext context) => kIsCompact(context) ? 15 : 20;

final NumberFormat _numberFormat = NumberFormat('#,##0.##', 'en_US');

/// Formats numbers like the reference (`1,750`, `59`, `12.5`).
String kFormatNumber(num? value) => _numberFormat.format(value ?? 0);

// ─────────────────────────────────────────────────────────────────────────────
// Icons (stroke SVG symbols copied from the reference markup)
// ─────────────────────────────────────────────────────────────────────────────

enum KIcon {
  pin,
  chevron,
  down,
  arrow,
  search,
  filter,
  heart,
  bell,
  star,
  home,
  grid,
  bag,
  orders,
  user,
  plus,
  close,
  cut,
  box,
  chat,
  logo,
}

const Map<KIcon, String> _iconViewBox = {
  KIcon.cut: '0 0 48 40',
  KIcon.box: '0 0 48 40',
  KIcon.logo: '0 0 40 44',
};

const Map<KIcon, String> _iconBody = {
  KIcon.pin:
      '<path d="M20 10c0 6-8 11-8 11S4 16 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="2.5"/>',
  KIcon.chevron: '<path d="m14 7-5 5 5 5"/>',
  KIcon.down: '<path d="m7 10 5 5 5-5"/>',
  KIcon.arrow: '<path d="M20 12H4m6-6-6 6 6 6"/>',
  KIcon.search:
      '<circle cx="10.5" cy="10.5" r="6.8"/><path d="m16 16 4.5 4.5"/>',
  KIcon.filter:
      '<path d="M4 7h8m5 0h3M4 17h3m5 0h8"/><circle cx="14.5" cy="7" r="2.5"/><circle cx="9.5" cy="17" r="2.5"/>',
  KIcon.heart:
      '<path d="M20.7 5.8c-2.2-2.3-5.8-1.8-8.7 1.4C9.1 4 5.5 3.5 3.3 5.8 0 9.3 4 15 12 20c8-5 12-10.7 8.7-14.2Z"/>',
  KIcon.bell: '<path d="M5 9a7 7 0 0 1 14 0c0 5 2 6 2 7H3c0-1 2-2 2-7m4 11h6"/>',
  KIcon.star:
      '<path d="m12 3 3 6 6.5 1-4.8 4.7 1.1 6.6-5.8-3.2-5.8 3.2 1.1-6.6L2.5 10 9 9Z"/>',
  KIcon.home:
      '<path d="m3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1Z"/>',
  KIcon.grid:
      '<rect x="3" y="3" width="7" height="7" rx="2"/><rect x="14" y="3" width="7" height="7" rx="2"/><rect x="3" y="14" width="7" height="7" rx="2"/><rect x="14" y="14" width="7" height="7" rx="2"/>',
  KIcon.bag: '<path d="M4 7h16l-1 14H5ZM8 8V6a4 4 0 0 1 8 0v2"/>',
  KIcon.orders:
      '<rect x="5" y="3" width="14" height="18" rx="2"/><path d="M9 8h6m-6 4h6m-6 4h4"/>',
  KIcon.user: '<circle cx="12" cy="7" r="4"/><path d="M20 21H4v-2a8 8 0 0 1 16 0Z"/>',
  KIcon.plus: '<path d="M12 5v14M5 12h14"/>',
  KIcon.close: '<path d="m6 6 12 12M6 18 18 6"/>',
  KIcon.cut:
      '<path d="m6 32 28-26c8 6 3 14-4 16l-10-2m-8 7 6 6m-12-1 4 5 9-8M33 28l-6 8m10-6 5 6"/>',
  KIcon.box:
      '<path d="m5 13 19-8 19 8-19 9Zm0 0v18l19 7 19-7V13M24 22v16M15 9l19 8v8"/>',
  KIcon.chat:
      '<path d="M21 11a9 9 0 0 1-13 8l-5 2 1-6A9 9 0 1 1 21 11Z"/><path d="M8 10h8m-8 4h5"/>',
  KIcon.logo:
      '<path d="m8 8-3-4 1 13 6 5m20-14 3-4-1 13-6 5M12 13l8 4 8-4v17l-8 8-8-8Zm4 13 4 3 4-3M20 29v9M16 6l4-3 4 3m-9 0h10"/>',
};

String _hex(Color c) {
  final argb = c.toARGB32();
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Renders one of the reference stroke icons.
class KSvgIcon extends StatelessWidget {
  final KIcon icon;
  final double size;
  final double? height;
  final Color color;
  final double strokeWidth;
  final Color? fill;
  final bool flipX;

  const KSvgIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.height,
    this.color = KColors.ink,
    this.strokeWidth = 1.7,
    this.fill,
    this.flipX = false,
  });

  @override
  Widget build(BuildContext context) {
    final viewBox = _iconViewBox[icon] ?? '0 0 24 24';
    final opacity = color.a;
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox" '
        'fill="${fill == null ? 'none' : _hex(fill!)}" stroke="${_hex(color)}" '
        'stroke-opacity="$opacity" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">${_iconBody[icon]}</svg>';
    Widget child = SvgPicture.string(
      svg,
      width: size,
      height: height ?? size,
      excludeFromSemantics: true,
    );
    if (flipX) {
      child = Transform.flip(flipX: true, child: child);
    }
    return child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Images
// ─────────────────────────────────────────────────────────────────────────────

/// Bundled photography extracted from the reference for the initial visuals.
class KAssets {
  KAssets._();

  static const meat = 'assets/images/home/meat.jpg';
  static const camel = 'assets/images/home/camel.jpg';
  static const sheep = 'assets/images/home/sheep.jpg';
  static const cow = 'assets/images/home/cow.jpg';
  static const lamb = 'assets/images/home/lamb.jpg';
  static const chicken = 'assets/images/home/chicken.jpg';

  /// Picks a fitting bundled photo for a category/product name.
  static String forName(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.contains('حاشي') || n.contains('إبل') || n.contains('ابل') || n.contains('camel')) {
      return camel;
    }
    if (n.contains('دجاج') || n.contains('دواجن') || n.contains('chicken')) {
      return chicken;
    }
    if (n.contains('عجل') || n.contains('عجول') || n.contains('أبقار') || n.contains('cow')) {
      return cow;
    }
    if (n.contains('بقر') || n.contains('ستيك') || n.contains('beef')) {
      return lamb;
    }
    if (n.contains('غنم') || n.contains('خروف') || n.contains('ذبيح') || n.contains('ذبائح') ||
        n.contains('نعيمي') || n.contains('حري') || n.contains('نجدي') || n.contains('ماعز') ||
        n.contains('تيس') || n.contains('sheep')) {
      return sheep;
    }
    return meat;
  }
}

/// Resolves a backend media path (absolute URL, bundled asset or relative path).
String kResolveMediaUrl(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('assets/')) {
    return value;
  }
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return value.startsWith('/') ? '$base$value' : '$base/$value';
}

/// Image that supports network URLs, bundled assets and a bundled fallback.
class KImage extends StatelessWidget {
  final String? url;
  final String fallbackAsset;
  final BoxFit fit;
  final Alignment alignment;
  final Color background;

  /// Fit used when the fallback asset is shown (photos look best covered).
  final BoxFit fallbackFit;

  const KImage({
    super.key,
    required this.url,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
    this.fallbackFit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.background = KColors.cream,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = kResolveMediaUrl(url);
    final fallback = Image.asset(
      fallbackAsset,
      fit: fallbackFit,
      alignment: alignment,
    );
    Widget child;
    if (resolved.isEmpty) {
      child = fallback;
    } else if (resolved.startsWith('assets/')) {
      child = Image.asset(
        resolved,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, _, _) => fallback,
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: resolved,
        fit: fit,
        alignment: alignment,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => ColoredBox(color: background),
        errorWidget: (_, _, _) => fallback,
      );
    }
    return SizedBox.expand(
      child: ColoredBox(color: background, child: child),
    );
  }
}

/// Small pressable wrapper with an ink ripple clipped to [radius].
class KTap extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius radius;
  final String? semanticLabel;
  final bool selected;

  const KTap({
    super.key,
    required this.child,
    this.onTap,
    this.radius = BorderRadius.zero,
    this.semanticLabel,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: KColors.red.withValues(alpha: 0.06),
        highlightColor: KColors.red.withValues(alpha: 0.03),
        child: child,
      ),
    );
    if (semanticLabel != null) {
      result = Semantics(
        button: true,
        selected: selected,
        label: semanticLabel,
        excludeSemantics: true,
        child: result,
      );
    }
    return result;
  }
}

