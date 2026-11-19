import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../domain/entities/home_data.dart';
import 'kingdom_design.dart';

/// Sticky mobile header matching `design_reference/index.html` (`.header`).
///
/// Supports both Light & Dark mode ([KPalette]) and Arabic & English ([kTr]).
/// Also supports an optional inline [searchController] / [onSearchChanged] for
/// the Categories / Browse page (`#browseView`).
class KingdomHeaderWidget extends StatelessWidget {
  final String? deliveryLocation;
  final int favoritesCount;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback? onSearchTap;
  final VoidCallback onFilterTap;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onBackTap;

  const KingdomHeaderWidget({
    super.key,
    required this.deliveryLocation,
    required this.favoritesCount,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
    this.onSearchTap,
    required this.onFilterTap,
    this.searchController,
    this.onSearchChanged,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final isAr = kIsAr(context);
    final compact = kIsCompact(context);
    final pad = kPagePadding(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final topPad = topInset > 8 ? topInset : 8.0;

    final String locText;
    if (deliveryLocation != null && deliveryLocation!.trim().isNotEmpty) {
      final raw = deliveryLocation!.trim();
      if (isAr) {
        locText = raw.startsWith('التوصيل') ? raw : 'التوصيل إلى $raw';
      } else {
        locText = raw.toLowerCase().startsWith('deliver')
            ? raw
            : 'Deliver to $raw';
      }
    } else {
      locText = kTr(context, 'اختَر عنوان التوصيل', 'Select delivery address');
    }

    final maxLocWidth = compact ? 150.0 : 185.0;
    final locSubColor = p.isDark ? p.muted : const Color(0xFF6B7066);
    final searchHintColor = p.isDark ? p.muted : const Color(0xFF8B8D82);

    return Container(
      decoration: BoxDecoration(
        color: p.paper,
        border: Border(bottom: BorderSide(color: p.line, width: 1)),
      ),
      padding: EdgeInsets.only(left: pad, right: pad, top: topPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // .top { display:flex; align-items:center; justify-content:space-between; gap:8px; padding-bottom:9px }
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                if (onBackTap != null) ...[
                  KTap(
                    onTap: onBackTap,
                    radius: BorderRadius.circular(18),
                    semanticLabel: kTr(context, 'رجوع', 'Back'),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: KSvgIcon(
                          KIcon.chevron,
                          size: 20,
                          color: p.ink,
                          flipX: isAr,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: KTap(
                    onTap: onLocationTap,
                    radius: BorderRadius.circular(10),
                    semanticLabel: kTr(
                      context,
                      'عرض عنوان التوصيل',
                      'Delivery address',
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: compact ? 30 : 34,
                          height: compact ? 32 : 34,
                          decoration: BoxDecoration(
                            color: p.logoCircleBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: KSvgIcon(
                            KIcon.logo,
                            size: compact ? 22 : 25,
                            height: compact ? 25 : 28,
                            color: p.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                kTr(
                                  context,
                                  'ذبائح المملكة',
                                  'Dhabayih Al-Mamlaka',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: kText(
                                  compact ? 13 : 14,
                                  weight: FontWeight.w600,
                                  color: p.ink,
                                  height: 1.5,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: maxLocWidth,
                                      ),
                                      child: Text(
                                        locText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: kText(
                                          10,
                                          weight: FontWeight.w400,
                                          color: locSubColor,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  KSvgIcon(
                                    KIcon.down,
                                    size: 13,
                                    color: locSubColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeaderIconButton(
                      icon: KIcon.heart,
                      semanticLabel: kTr(context, 'المفضلة', 'Favorites'),
                      badgeCount: favoritesCount,
                      onTap: onFavoritesTap,
                    ),
                    const SizedBox(width: 3),
                    _HeaderIconButton(
                      icon: KIcon.bell,
                      semanticLabel: kTr(context, 'الإشعارات', 'Notifications'),
                      onTap: onNotificationsTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // .search-wrap { display:flex; gap:9px; padding-bottom:10px }
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: onSearchChanged != null
                      ? Container(
                          constraints: const BoxConstraints(minHeight: 43),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: p.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: p.inputBorder),
                          ),
                          child: Row(
                            children: [
                              KSvgIcon(
                                KIcon.search,
                                size: 19,
                                color: searchHintColor,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: onSearchChanged,
                                  style: kText(12, color: p.ink, height: 1.4),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    hintText: kTr(
                                      context,
                                      'ابحث عن ذبيحة أو قطعة لحم',
                                      'Search for carcass or meat cut',
                                    ),
                                    hintStyle: kText(
                                      12,
                                      color: searchHintColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                              if (searchController != null &&
                                  searchController!.text.isNotEmpty)
                                KTap(
                                  onTap: () {
                                    searchController!.clear();
                                    onSearchChanged!('');
                                  },
                                  radius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: KSvgIcon(
                                      KIcon.close,
                                      size: 15,
                                      color: searchHintColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : KTap(
                          onTap: onSearchTap,
                          radius: BorderRadius.circular(12),
                          semanticLabel: kTr(
                            context,
                            'البحث في المنتجات',
                            'Search products',
                          ),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 43),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: p.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: p.inputBorder),
                            ),
                            child: Row(
                              children: [
                                KSvgIcon(
                                  KIcon.search,
                                  size: 19,
                                  color: searchHintColor,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    kTr(
                                      context,
                                      'ابحث عن ذبيحة أو قطعة لحم',
                                      'Search for carcass or meat cut',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: kText(
                                      12,
                                      color: searchHintColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 9),
                KTap(
                  onTap: onFilterTap,
                  radius: BorderRadius.circular(12),
                  semanticLabel: kTr(
                    context,
                    'تصفية وترتيب المنتجات',
                    'Filter and sort products',
                  ),
                  child: Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: p.cream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: KSvgIcon(
                      KIcon.filter,
                      size: 22,
                      color: p.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final KIcon icon;
  final String semanticLabel;
  final int badgeCount;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    return KTap(
      onTap: onTap,
      radius: BorderRadius.circular(21),
      semanticLabel: semanticLabel,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            KSvgIcon(icon, size: 22, color: p.ink),
            if (badgeCount > 0)
              PositionedDirectional(
                top: 1,
                end: 1,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: p.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: kText(
                      10,
                      weight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact greeting + wallet/rewards strip below the sticky header (`.welcome-line`).
class KingdomWelcomeLineWidget extends StatelessWidget {
  final UserHighlight? userHighlight;
  final int? loyaltyPointsOverride;
  final double? balanceOverride;
  final VoidCallback onWalletTap;
  final VoidCallback onLoyaltyTap;

  const KingdomWelcomeLineWidget({
    super.key,
    required this.userHighlight,
    this.loyaltyPointsOverride,
    this.balanceOverride,
    required this.onWalletTap,
    required this.onLoyaltyTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = userHighlight;
    if (user == null) return const SizedBox.shrink();

    final p = KPalette.of(context);
    final pad = kPagePadding(context);
    final name = user.name.trim().isNotEmpty
        ? user.name.trim()
        : kTr(context, 'ضيفنا', 'Guest');

    final explicitPoints = loyaltyPointsOverride ?? user.loyaltyPoints;
    final displayBalance = (balanceOverride != null && balanceOverride! > 0)
        ? balanceOverride!
        : (user.balance > 0 ? user.balance : explicitPoints.toDouble());
    final greetingColor = p.isDark ? p.muted : const Color(0xFF6A7065);

    return Container(
      constraints: const BoxConstraints(minHeight: 35),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                style: kText(11, color: greetingColor, height: 1.5),
                children: [
                  TextSpan(text: kTr(context, 'حيّاك، ', 'Welcome, ')),
                  TextSpan(
                    text: name,
                    style: kText(
                      11,
                      weight: FontWeight.w500,
                      color: p.ink,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KTap(
                    onTap: onWalletTap,
                    radius: BorderRadius.circular(6),
                    semanticLabel: kTr(context, 'رصيد الحساب', 'Account Balance'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            kTr(context, 'رصيد الحساب ', 'Balance '),
                            style: kText(10, color: p.gold, height: 1.4),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              kFormatNumber(displayBalance),
                              style: kText(
                                10,
                                weight: FontWeight.w600,
                                color: p.goldStrong,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  KTap(
                    onTap: onLoyaltyTap,
                    radius: BorderRadius.circular(6),
                    semanticLabel: kTr(
                      context,
                      'نقاط المنتجات والمكافآت',
                      'Product points & rewards',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KSvgIcon(
                            KIcon.star,
                            size: 12,
                            color: p.gold,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            explicitPoints > 0
                                ? kTr(
                                    context,
                                    'المكافآت (${kFormatNumber(explicitPoints)} نقطة)',
                                    'Rewards (${kFormatNumber(explicitPoints)} pts)',
                                  )
                                : kTr(context, 'المكافآت', 'Rewards'),
                            style: kText(
                              10,
                              weight: explicitPoints > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: explicitPoints > 0 ? p.goldStrong : p.gold,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero banner stage + caption + prev/dots/next controls (`.banner-section`).
class KingdomBannerSectionWidget extends StatefulWidget {
  final List<BannerEntity> banners;
  final ValueChanged<BannerEntity> onBannerTap;

  const KingdomBannerSectionWidget({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  @override
  State<KingdomBannerSectionWidget> createState() =>
      _KingdomBannerSectionWidgetState();
}

class _KingdomBannerSectionWidgetState extends State<KingdomBannerSectionWidget> {
  int _index = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant KingdomBannerSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.banners.length && widget.banners.isNotEmpty) {
      _index = 0;
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || widget.banners.length < 2) return;
      setState(() {
        _index = (_index + 1) % widget.banners.length;
      });
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _step(int delta) {
    if (widget.banners.isEmpty) return;
    _startAutoPlay();
    setState(() {
      final len = widget.banners.length;
      _index = ((_index + delta) % len + len) % len;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final p = KPalette.of(context);
    final isAr = kIsAr(context);
    final compact = kIsCompact(context);
    final pad = kPagePadding(context);
    final safeIndex = _index.clamp(0, widget.banners.length - 1);
    final banner = widget.banners[safeIndex];
    final hasAction = banner.offerId != null ||
        (banner.deepLink != null && banner.deepLink!.trim().isNotEmpty) ||
        banner.bannerType == 'offer';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onHorizontalDragEnd: widget.banners.length < 2
                ? null
                : (details) {
                    final v = details.primaryVelocity ?? 0;
                    if (v.abs() < 80) return;
                    _step(v > 0 ? 1 : -1);
                  },
            onTap: () => widget.onBannerTap(banner),
            child: Container(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: p.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: compact ? 2.25 : 2.35,
                    child: KImage(
                      url: banner.imageUrl,
                      fallbackAsset:
                          safeIndex.isEven ? KAssets.meat : KAssets.sheep,
                      fit: BoxFit.cover,
                      fallbackFit: BoxFit.cover,
                      background: const Color(0xFF26241E),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 49),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            banner.name.isNotEmpty
                                ? banner.name
                                : kTr(
                                    context,
                                    'اختيارات تليق بسفرتك',
                                    'Selections worthy of your table',
                                  ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: kText(
                              compact ? 13 : 15,
                              weight: FontWeight.w600,
                              color: p.ink,
                              height: 1.6,
                            ),
                          ),
                        ),
                        if (hasAction) ...[
                          const SizedBox(width: 8),
                          KTap(
                            onTap: () => widget.onBannerTap(banner),
                            radius: BorderRadius.circular(8),
                            semanticLabel: '${kTr(context, 'فتح', 'Open')} ${banner.name}',
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 35),
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 8 : 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: p.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    kTr(context, 'تسوق الآن', 'Shop Now'),
                                    style: kText(
                                      compact ? 9 : 10,
                                      weight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  KSvgIcon(
                                    KIcon.arrow,
                                    size: 13,
                                    color: Colors.white,
                                    flipX: !isAr,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.banners.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SizedBox(
                height: 25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KTap(
                      onTap: () => _step(-1),
                      radius: BorderRadius.circular(14),
                      semanticLabel: kTr(
                        context,
                        'البانر السابق',
                        'Previous banner',
                      ),
                      child: SizedBox(
                        width: 29,
                        height: 23,
                        child: Center(
                          child: KSvgIcon(
                            KIcon.chevron,
                            size: 14,
                            color: p.isDark ? p.muted : const Color(0xFF72776C),
                            flipX: !isAr,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.banners.length, (i) {
                        final selected = i == safeIndex;
                        return Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: i == widget.banners.length - 1 ? 0 : 5,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _startAutoPlay();
                              setState(() => _index = i);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: selected ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: selected
                                    ? p.red
                                    : (p.isDark
                                        ? p.line
                                        : const Color(0xFFDADAD0)),
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 11),
                    KTap(
                      onTap: () => _step(1),
                      radius: BorderRadius.circular(14),
                      semanticLabel: kTr(context, 'البانر التالي', 'Next banner'),
                      child: SizedBox(
                        width: 29,
                        height: 23,
                        child: Center(
                          child: KSvgIcon(
                            KIcon.chevron,
                            size: 14,
                            color: p.isDark ? p.muted : const Color(0xFF72776C),
                            flipX: isAr,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section title + "عرض الكل" / "View All" button matching `.section-head`.
class KingdomSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool showActionChevron;
  final String? trailingSubtitle;
  final EdgeInsetsGeometry? padding;

  const KingdomSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.showActionChevron = true,
    this.trailingSubtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final isAr = kIsAr(context);
    final compact = kIsCompact(context);
    final pad =
        padding ?? EdgeInsets.symmetric(horizontal: kPagePadding(context));
    final effectiveActionLabel =
        actionLabel ?? kTr(context, 'عرض الكل', 'View All');

    return Padding(
      padding: pad,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kText(
                  17,
                  weight: FontWeight.w600,
                  color: p.ink,
                  height: 1.5,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (trailingSubtitle != null) ...[
              const SizedBox(width: 10),
              Text(
                trailingSubtitle!,
                style: kText(10, color: p.muted, height: 1.4),
              ),
            ] else if (onActionTap != null) ...[
              const SizedBox(width: 10),
              KTap(
                onTap: onActionTap,
                radius: BorderRadius.circular(6),
                semanticLabel: '$effectiveActionLabel - $title',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        effectiveActionLabel,
                        style: kText(
                          compact ? 10 : 11,
                          weight: FontWeight.w400,
                          color: p.red,
                          height: 1.4,
                        ),
                      ),
                      if (showActionChevron) ...[
                        const SizedBox(width: 3),
                        KSvgIcon(
                          KIcon.chevron,
                          size: 14,
                          color: p.red,
                          flipX: !isAr,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
