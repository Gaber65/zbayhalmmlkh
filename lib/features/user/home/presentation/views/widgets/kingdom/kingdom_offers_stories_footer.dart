import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../offers/domain/entities/offer_entity.dart';
import '../../../../domain/entities/home_data.dart';
import 'kingdom_design.dart';
import 'kingdom_header_and_banner.dart';

/// Active cart continuation banner matching `.active-cart` (`#activeCartSlot`).
class KingdomActiveCartBanner extends StatelessWidget {
  final int lineCount;
  final VoidCallback onTap;

  const KingdomActiveCartBanner({
    super.key,
    required this.lineCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lineCount <= 0) return const SizedBox.shrink();

    final p = KPalette.of(context);
    final isAr = kIsAr(context);
    final pad = kPagePadding(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 22, pad, 0),
      child: KTap(
        onTap: onTap,
        radius: BorderRadius.circular(10),
        semanticLabel: kTr(
          context,
          'كمّل طلبك، عدد أصناف سلتك الحالية $lineCount',
          'Complete your order, $lineCount items in your cart',
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 49),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: p.activeCartBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.activeCartBorder),
          ),
          child: Row(
            children: [
              KSvgIcon(
                KIcon.bag,
                size: 19,
                color: p.activeCartFg,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kTr(context, 'كمّل طلبك', 'Complete your order'),
                      style: kText(
                        11,
                        weight: FontWeight.w600,
                        color: p.activeCartFg,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      kTr(
                        context,
                        'عدد أصناف سلتك الحالية: ${kFormatNumber(lineCount)}',
                        'Items in your cart: ${kFormatNumber(lineCount)}',
                      ),
                      style: kText(
                        10,
                        color: p.activeCartSub,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              KSvgIcon(
                KIcon.chevron,
                size: 19,
                color: p.activeCartFg,
                flipX: !isAr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Promotional offers horizontal row matching `#offersSection` / `.offer-row` / `.offer-card`.
class KingdomOffersSection extends StatelessWidget {
  final List<OfferEntity> offers;
  final ValueChanged<OfferEntity> onOfferTap;
  final VoidCallback onViewAllTap;

  const KingdomOffersSection({
    super.key,
    required this.offers,
    required this.onOfferTap,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeOffers = offers.where((o) => o.isActive).toList();
    if (activeOffers.isEmpty) return const SizedBox.shrink();

    final compact = kIsCompact(context);
    final pad = kPagePadding(context);
    final widthFactor = compact ? 0.88 : 0.87;

    return Padding(
      padding: const EdgeInsets.only(top: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KingdomSectionHeader(
            title: kTr(context, 'العروض الترويجية', 'Promotional Offers'),
            actionLabel: kTr(context, 'عرض الكل', 'View All'),
            onActionTap: onViewAllTap,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth - (pad * 2);
              final cardWidth = (contentWidth * widthFactor).clamp(240.0, 340.0);
              final titleStyle = kText(
                compact ? 12 : 13,
                weight: FontWeight.w600,
                height: 1.5,
              );
              final subStyle = kText(compact ? 10 : 11, height: 1.5);
              final metaStyle = kText(10, height: 1.4);
              final estimatedHeight = (kLineHeight(context, titleStyle, lines: 1) +
                      kLineHeight(context, subStyle, lines: 1) +
                      kLineHeight(context, metaStyle, lines: 1) +
                      36)
                  .clamp(110.0, 170.0);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < activeOffers.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      SizedBox(
                        width: cardWidth,
                        height: estimatedHeight,
                        child: KingdomOfferCard(
                          offer: activeOffers[i],
                          fallbackAsset: i.isEven ? KAssets.lamb : KAssets.meat,
                          onTap: () => onOfferTap(activeOffers[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Single offer card matching `.offer-card` (`grid-template-columns: 34% 66%; min-height: 110px`).
class KingdomOfferCard extends StatelessWidget {
  final OfferEntity offer;
  final String fallbackAsset;
  final VoidCallback onTap;

  const KingdomOfferCard({
    super.key,
    required this.offer,
    this.fallbackAsset = KAssets.lamb,
    required this.onTap,
  });

  int get _includedCount {
    if (offer.productIds.isNotEmpty) {
      return offer.productIds.toSet().length;
    }
    if (offer.products.isNotEmpty) {
      return offer.products.map((p) => p.id).toSet().length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final isAr = kIsAr(context);
    final compact = kIsCompact(context);
    final count = _includedCount;
    final countLabel = count <= 1
        ? kTr(context, 'منتج واحد مشمول', '1 product included')
        : kTr(
            context,
            '${kFormatNumber(count)} منتجات مشمولة',
            '${kFormatNumber(count)} products included',
          );
    final badge = offer.badgeText.trim();

    return KTap(
      onTap: onTap,
      radius: BorderRadius.circular(13),
      semanticLabel: offer.name,
      child: Container(
        constraints: const BoxConstraints(minHeight: 110),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: p.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 34% image column on the start (right in RTL, left in LTR)
            Expanded(
              flex: 34,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  KImage(
                    url: offer.bannerImageUrl,
                    fallbackAsset: fallbackAsset,
                    fit: BoxFit.contain,
                    fallbackFit: BoxFit.contain,
                    background: p.isDark
                        ? const Color(0xFF28241D)
                        : const Color(0xFFE4DDD1),
                  ),
                  if (badge.isNotEmpty)
                    Positioned(
                      left: 5,
                      right: 5,
                      bottom: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: p.isDark
                              ? const Color(0xFF33281A)
                              : const Color(0xFFFFF5DF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: kText(
                            10,
                            weight: FontWeight.w500,
                            color: p.isDark
                                ? const Color(0xFFEFC48A)
                                : const Color(0xFF7F4F22),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 66% body column on the end (left in RTL, right in LTR)
            Expanded(
              flex: 66,
              child: Padding(
                padding: EdgeInsets.all(compact ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        offer.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: kText(
                          compact ? 12 : 13,
                          weight: FontWeight.w600,
                          color: p.ink,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (offer.subtitle != null &&
                        offer.subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        offer.subtitle!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kText(
                          compact ? 10 : 11,
                          color: p.muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            countLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kText(
                              10,
                              color: p.red,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        KSvgIcon(
                          KIcon.chevron,
                          size: 13,
                          color: p.red,
                          flipX: !isAr,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grouped stories ("من داخل المملكة — قصص وتجهيزات") matching `#storiesSection`.
class KingdomStoriesSection extends StatelessWidget {
  final List<JabinHighlightEntity> groups;
  final Set<int> viewedUserIds;
  final ValueChanged<int> onGroupTap;

  const KingdomStoriesSection({
    super.key,
    required this.groups,
    this.viewedUserIds = const {},
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final validGroups = groups.where((g) => g.highlights.isNotEmpty).toList();
    if (validGroups.isEmpty) return const SizedBox.shrink();

    final p = KPalette.of(context);
    final pad = kPagePadding(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 25, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    kTr(context, 'تجارب العملاء', 'Customer Reviews'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kText(
                      17,
                      weight: FontWeight.w600,
                      color: p.ink,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  kTr(context, 'قصص وتجهيزات من داخل المملكة', 'Stories & Prep'),
                  style: kText(
                    10,
                    color: p.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < validGroups.length; i++) ...[
                  if (i > 0) const SizedBox(width: 17),
                  _buildStoryItem(context, validGroups[i], i),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(
    BuildContext context,
    JabinHighlightEntity group,
    int index,
  ) {
    final p = KPalette.of(context);
    // Match reference: first two rings are red (#b23b32), third+ or viewed rings are muted (#cfcec2).
    final isMutedRing = index >= 2 || viewedUserIds.contains(group.user.id);
    final ringColor = isMutedRing
        ? p.storyRingMuted
        : (p.isDark ? p.red : const Color(0xFFB23B32));
    final hasAvatar = group.user.avatarUrl.trim().isNotEmpty;

    return KTap(
      onTap: () => onGroupTap(index),
      radius: BorderRadius.circular(12),
      semanticLabel: group.user.name,
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 53,
              height: 53,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 1.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: p.storyInnerBg,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: hasAvatar
                    ? KImage(
                        url: group.user.avatarUrl,
                        fallbackAsset: KAssets.sheep,
                        fit: BoxFit.cover,
                        background: p.storyInnerBg,
                      )
                    : KSvgIcon(
                        index == 1 ? KIcon.box : KIcon.logo,
                        size: 25,
                        color: p.storyIconFg,
                      ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              group.user.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: kText(
                10,
                color: p.ink,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Services strip + WhatsApp support row + footer matching `.services`, `.support`, `.footer`.
class KingdomSupportAndFooterSection extends StatelessWidget {
  final VoidCallback onSupportTap;

  const KingdomSupportAndFooterSection({
    super.key,
    required this.onSupportTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final pad = kPagePadding(context);
    final footerTextColor = p.isDark ? p.muted : const Color(0xFF7E8177);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Column(
            children: [
              // .services { margin-top:27px; border-block:1px solid var(--line); padding-block:18px }
              Container(
                margin: const EdgeInsets.only(top: 27),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: p.line, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ServicePillar(
                        icon: KIcon.cut,
                        label: kTr(context, 'اختيار التقطيع', 'Custom Cutting'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _ServicePillar(
                        icon: KIcon.box,
                        label: kTr(
                          context,
                          'خيارات التغليف',
                          'Packaging Options',
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _ServicePillar(
                        icon: KIcon.chat,
                        label: kTr(
                          context,
                          'مساعدة في الاختيار',
                          'Selection Help',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // .support { margin:23px 0 15px; display:flex; justify-content:space-between; gap:10px }
              Padding(
                padding: const EdgeInsets.only(top: 23, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            kTr(
                              context,
                              'محتار وش تختار؟',
                              'Not sure what to pick?',
                            ),
                            style: kText(
                              14,
                              weight: FontWeight.w600,
                              color: p.ink,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            kTr(
                              context,
                              'خلّنا نساعدك في اختيار طلبك',
                              'Let us help you choose your order',
                            ),
                            style: kText(
                              10,
                              color: p.muted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    KTap(
                      onTap: onSupportTap,
                      radius: BorderRadius.circular(9),
                      semanticLabel: kTr(
                        context,
                        'التواصل عبر واتساب',
                        'Contact via WhatsApp',
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: p.greenSoftBg,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: p.greenSoftBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KSvgIcon(
                              KIcon.chat,
                              size: 17,
                              color: p.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              kTr(context, 'واتساب', 'WhatsApp'),
                              style: kText(
                                11,
                                weight: FontWeight.w500,
                                color: p.green,
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
            ],
          ),
        ),
        // .footer { font-size:10px; color:#7e8177; text-align:center; padding:4px 20px 18px; line-height:1.8 }
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 4, pad, 18),
          child: Column(
            children: [
              Text(
                kTr(
                  context,
                  'نموذج تفاعلي · بيانات الحساب والمنتجات والصور أمثلة توضيحية',
                  'Interactive storefront · Account & product details',
                ),
                textAlign: TextAlign.center,
                style: kText(
                  10,
                  color: footerTextColor,
                  height: 1.8,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    kTr(
                      context,
                      'لا تُرسل طلبات حقيقية من هذه النسخة · الصور: ',
                      'Photos: ',
                    ),
                    style: kText(
                      10,
                      color: footerTextColor,
                      height: 1.8,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      launchUrl(
                        Uri.parse('https://unsplash.com'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Text(
                      'Unsplash',
                      style: kText(
                        10,
                        color: footerTextColor,
                        height: 1.8,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServicePillar extends StatelessWidget {
  final KIcon icon;
  final String label;

  const _ServicePillar({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final fg = p.isDark ? p.muted : const Color(0xFF686D5E);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KSvgIcon(
          icon,
          size: 21,
          color: fg,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: kText(
            11,
            weight: FontWeight.w500,
            color: fg,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
