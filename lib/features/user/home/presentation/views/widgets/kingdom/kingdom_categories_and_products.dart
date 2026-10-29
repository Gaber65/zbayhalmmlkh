import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../catalog/domain/entities/category.dart';
import '../../../../../catalog/domain/entities/product.dart';
import '../../../../../favorites/presentation/manager/favorites_cubit.dart';
import '../../../../../favorites/presentation/manager/favorites_state.dart';
import 'kingdom_design.dart';
import 'kingdom_header_and_banner.dart';

/// Client-approved two-column photographic category grid (`#categoriesSection`).
///
/// Renders all available categories immediately on the home screen without
/// collapsing or hiding items behind an expand toggle.
class KingdomCategoriesSection extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category> onCategoryTap;
  final VoidCallback? onViewAllCategories;

  const KingdomCategoriesSection({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.onViewAllCategories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final pad = kPagePadding(context);

    return Padding(
      padding: const EdgeInsets.only(top: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KingdomSectionHeader(
            title: kTr(context, 'التصنيفات', 'Categories'),
            actionLabel: onViewAllCategories != null
                ? kTr(context, 'عرض الكل', 'View All')
                : null,
            showActionChevron: onViewAllCategories != null,
            onActionTap: onViewAllCategories,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: KingdomCategoryBrowseGrid(
              categories: categories,
              onCategoryTap: onCategoryTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable 2-column photographic category grid used in both Home (`#homeCategories`)
/// and Categories/Browse (`#categoryBrowseGrid`).
class KingdomCategoryBrowseGrid extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category> onCategoryTap;

  const KingdomCategoryBrowseGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  String _categoryAsset(Category c, int index) {
    final byName = KAssets.forName(c.name);
    if (byName != KAssets.meat) return byName;
    const cycle = [
      KAssets.sheep,
      KAssets.lamb,
      KAssets.meat,
      KAssets.camel,
      KAssets.chicken,
      KAssets.cow,
    ];
    return cycle[index % cycle.length];
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final compact = kIsCompact(context);
    final gap = compact ? 8.0 : 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - gap) / 2;
        final aspect = compact ? 2.1 : 2.25;
        final cardHeight = cardWidth / aspect;

        final rows = <Widget>[];
        for (int i = 0; i < categories.length; i += 2) {
          final first = categories[i];
          final second = i + 1 < categories.length ? categories[i + 1] : null;
          if (i > 0) {
            rows.add(SizedBox(height: gap));
          }
          rows.add(
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: cardHeight,
                    child: KingdomPhotoCategoryCard(
                      category: first,
                      fallbackAsset: _categoryAsset(first, i),
                      onTap: () => onCategoryTap(first),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: second != null
                      ? SizedBox(
                          height: cardHeight,
                          child: KingdomPhotoCategoryCard(
                            category: second,
                            fallbackAsset: _categoryAsset(second, i + 1),
                            onTap: () => onCategoryTap(second),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: rows,
        );
      },
    );
  }
}

/// Single wide photographic category card (`.cat.photo-category`).
class KingdomPhotoCategoryCard extends StatelessWidget {
  final Category category;
  final String? fallbackAsset;
  final VoidCallback onTap;

  const KingdomPhotoCategoryCard({
    super.key,
    required this.category,
    this.fallbackAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = kIsCompact(context);
    final radius = BorderRadius.circular(12);

    return KTap(
      onTap: onTap,
      radius: radius,
      semanticLabel: '${kTr(context, 'تصفح', 'Browse')} ${category.name}',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3B342D),
          borderRadius: radius,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            KImage(
              url: category.imageUrl,
              fallbackAsset: fallbackAsset ?? KAssets.forName(category.name),
              fit: BoxFit.cover,
              fallbackFit: BoxFit.cover,
              background: const Color(0xFF3B342D),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x1121170C),
                    Color(0x8821170C),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0x0A21170C),
              padding: EdgeInsets.all(compact ? 7 : 8),
              alignment: Alignment.center,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: kText(
                  compact ? 12 : 14,
                  weight: FontWeight.w600,
                  color: const Color(0xFFFFF9E9),
                  height: 1.6,
                  shadows: const [
                    Shadow(
                      color: Color(0x66000000),
                      blurRadius: 9,
                      offset: Offset(0, 1),
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

/// Helpers on [Product] matching the HTML's `adapt(p)` and `productMarkup(p)`.
extension KingdomProductX on Product {
  bool get hasConfigurableOptions =>
      isCarcass ||
      hasSizes ||
      sizes.isNotEmpty ||
      portions.isNotEmpty ||
      cuttingOptions.isNotEmpty ||
      packagingOptions.isNotEmpty ||
      excludedParts.isNotEmpty;

  bool get isEffectivelyAvailable => active && isAvailable;

  bool get hasActiveDiscount =>
      (isOnOffer &&
          offerPrice != null &&
          offerPrice! > 0 &&
          price > offerPrice!) ||
      (originalPrice != null && originalPrice! > displayPrice);

  double get effectiveOriginalPrice =>
      (originalPrice != null && originalPrice! > displayPrice)
          ? originalPrice!
          : price;

  double get cardDisplayPrice {
    if (hasConfigurableOptions) {
      final candidates = <double>[
        ...sizes.map((s) => s.price),
        ...portions.map((p) => p.startingPrice),
      ].where((n) => n.isFinite && n > 0).toList();
      if (candidates.isNotEmpty) {
        candidates.sort();
        return candidates.first;
      }
    }
    return displayPrice;
  }

  String localizedTitle(BuildContext context) {
    if (kIsAr(context)) {
      if (titleAr != null && titleAr!.trim().isNotEmpty) {
        return titleAr!.trim();
      }
      return title;
    } else {
      if (titleEn != null && titleEn!.trim().isNotEmpty) {
        return titleEn!.trim();
      }
      return title;
    }
  }

  String get cardCategoryTag {
    if (categoryName != null && categoryName!.trim().isNotEmpty) {
      return categoryName!.trim();
    }
    if (isCarcass) return 'ذبائح غنم وماعز';
    return 'لحوم طازجة';
  }

  String localizedCategoryTag(BuildContext context) {
    if (categoryName != null && categoryName!.trim().isNotEmpty) {
      return categoryName!.trim();
    }
    if (isCarcass) {
      return kTr(context, 'ذبائح غنم وماعز', 'Whole Carcasses');
    }
    return kTr(context, 'لحوم طازجة', 'Fresh Meat');
  }

  String? get cardDiscountBadge {
    if (discountTag != null && discountTag!.trim().isNotEmpty) {
      return discountTag!.trim();
    }
    if (hasActiveDiscount) {
      final diff = (effectiveOriginalPrice - displayPrice).round();
      if (diff > 0) return 'وفر $diff ر.س';
      return 'عرض خاص';
    }
    return null;
  }

  String? localizedDiscountBadge(BuildContext context) {
    if (discountTag != null && discountTag!.trim().isNotEmpty) {
      return discountTag!.trim();
    }
    if (hasActiveDiscount) {
      final diff = (effectiveOriginalPrice - displayPrice).round();
      if (diff > 0) {
        return kTr(context, 'وفر $diff ر.س', 'Save $diff SAR');
      }
      return kTr(context, 'عرض خاص', 'Special Offer');
    }
    return null;
  }
}

/// Product card matching `.product` in `design_reference/index.html`.
class KingdomProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onCtaTap;
  final bool? isFavoriteOverride;
  final VoidCallback? onFavoriteTap;

  const KingdomProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onCtaTap,
    this.isFavoriteOverride,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final compact = kIsCompact(context);
    final options = product.hasConfigurableOptions;
    final available = product.isEffectivelyAvailable;
    final onOffer = product.hasActiveDiscount;
    final discountBadge = product.localizedDiscountBadge(context);
    final cardPrice = product.cardDisplayPrice;
    final weightKg = product.weightKg;
    final titleText = product.localizedTitle(context);
    final cur = kCurrency(context);

    bool isFav = isFavoriteOverride ?? false;
    if (isFavoriteOverride == null) {
      try {
        final favState = context.watch<FavoritesCubit>().state;
        if (favState is FavoritesLoaded) {
          isFav = favState.favoriteIds.contains(product.id);
        }
      } catch (_) {}
    }

    final descStyle = kText(
      compact ? 10 : 11,
      color: p.subtleText,
      height: 1.65,
    );
    final descMinHeight = kLineHeight(context, descStyle, lines: 2);

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0330351E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // .product-image { margin:7px 7px 0; border-radius:11px; aspect-ratio:1.2 }
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
                child: KTap(
                  onTap: onTap,
                  radius: BorderRadius.circular(11),
                  semanticLabel:
                      '${kTr(context, 'تفاصيل', 'Details')} $titleText',
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          KImage(
                            url: product.imageUrl,
                            fallbackAsset: KAssets.forName(
                              '$titleText ${product.categoryName ?? ''}',
                            ),
                            fit: BoxFit.cover,
                            fallbackFit: BoxFit.cover,
                            background: p.cream,
                          ),
                          if (onOffer && discountBadge != null)
                            PositionedDirectional(
                              start: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: p.discountBadgeBg,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  discountBadge,
                                  style: kText(
                                    10,
                                    weight: FontWeight.w600,
                                    color: p.discountBadgeFg,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // .product-body { padding:10px }
              Padding(
                padding: EdgeInsets.all(compact ? 9 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // .tag { font-size:9px; font-weight:500; color:var(--green) }
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: p.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            product.localizedCategoryTag(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kText(
                              9,
                              weight: FontWeight.w500,
                              color: p.green,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // .product h3 { font-size:13px; font-weight:600; line-height:1.55 }
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kText(
                          compact ? 12 : 13,
                          weight: FontWeight.w600,
                          color: p.ink,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // .product-desc { font-size:11px; line-height:1.65; min-height:35px; color:#6e7468 }
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: descMinHeight),
                      child: Text(
                        product.subtitle.isNotEmpty
                            ? product.subtitle
                            : (product.description ?? ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: descStyle,
                      ),
                    ),
                    const SizedBox(height: 7),
                    // .starting { font-size:10px; color:var(--muted); line-height:1.3 }
                    Text(
                      options
                          ? kTr(context, 'يبدأ من', 'Starts from')
                          : '\u00A0',
                      maxLines: 1,
                      style: kText(
                        10,
                        color: p.muted,
                        height: 1.3,
                      ),
                    ),
                    // .product .price { margin:1px 0 10px; gap:4px; font-size:21px }
                    Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 10),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              kFormatNumber(cardPrice),
                              style: kText(
                                compact ? 19 : 21,
                                weight: FontWeight.w600,
                                color: p.ink,
                                height: 1.3,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              weightKg != null && weightKg > 0
                                  ? '$cur / ${kFormatNumber(weightKg)} ${kTr(context, 'كجم', 'kg')}'
                                  : cur,
                              style: kText(
                                10,
                                weight: FontWeight.w400,
                                color: p.muted,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (onOffer)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  kFormatNumber(product.effectiveOriginalPrice),
                                  style: kText(
                                    10,
                                    weight: FontWeight.w400,
                                    color: p.isDark
                                        ? p.muted
                                        : const Color(0xFF999D92),
                                    height: 1.3,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // .product-cta { width:100%; min-height:44px; border-radius:8px; font-size:11px }
                    _buildCtaButton(context, compact, available, options),
                  ],
                ),
              ),
            ],
          ),
          // .product .heart { position:absolute; top:9px; end:9px; width:36px; height:36px }
          PositionedDirectional(
            top: 9,
            end: 9,
            child: KTap(
              onTap: () {
                if (onFavoriteTap != null) {
                  onFavoriteTap!();
                  return;
                }
                try {
                  context.read<FavoritesCubit>().toggleFavorite(
                        product: product,
                        title: product.title,
                        price: product.displayPrice,
                        imageUrl: product.imageUrl,
                        subtitle: product.subtitle,
                      );
                } catch (_) {}
              },
              radius: BorderRadius.circular(18),
              selected: isFav,
              semanticLabel: kIsAr(context)
                  ? '${isFav ? 'إزالة' : 'إضافة'} $titleText ${isFav ? 'من' : 'إلى'} المفضلة'
                  : '${isFav ? 'Remove' : 'Add'} $titleText ${isFav ? 'from' : 'to'} favorites',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.heartBg,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: KSvgIcon(
                  KIcon.heart,
                  size: 18,
                  color: isFav ? p.red : p.heartInactive,
                  fill: isFav ? p.red : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(
    BuildContext context,
    bool compact,
    bool available,
    bool options,
  ) {
    final p = KPalette.of(context);
    final isAr = kIsAr(context);
    final Color bg;
    final Color borderColor;
    final Color fg;

    if (!available) {
      bg = p.disabledBg;
      borderColor = p.disabledBorder;
      fg = p.disabledFg;
    } else if (options) {
      bg = p.card;
      borderColor = p.redSoftBorder;
      fg = p.red;
    } else {
      bg = p.red;
      borderColor = p.red;
      fg = Colors.white;
    }

    final String label = !available
        ? kTr(context, 'غير متاح حاليًا', 'Out of stock')
        : (options
            ? kTr(context, 'اختيار الخيارات', 'Select Options')
            : kTr(context, 'أضف للسلة', 'Add to Cart'));

    return KTap(
      onTap: available ? onCtaTap : null,
      radius: BorderRadius.circular(8),
      semanticLabel: label,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kText(
                  compact ? 10 : 11,
                  weight: FontWeight.w600,
                  color: fg,
                  height: 1.5,
                ),
              ),
            ),
            if (available) ...[
              const SizedBox(width: 5),
              KSvgIcon(
                options ? KIcon.chevron : KIcon.plus,
                size: 13,
                color: fg,
                flipX: options && !isAr,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling product strip matching `.horizontal` (`grid-auto-columns: 47%`).
class KingdomHorizontalProductList extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onProductCtaTap;

  const KingdomHorizontalProductList({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onProductCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final compact = kIsCompact(context);
    final pad = kPagePadding(context);
    final widthFactor = compact ? 0.49 : 0.47;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth - (pad * 2);
        final cardWidth = (contentWidth * widthFactor).clamp(140.0, 230.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < products.length; i++) ...[
                if (i > 0) const SizedBox(width: 11),
                SizedBox(
                  width: cardWidth,
                  child: KingdomProductCard(
                    product: products[i],
                    onTap: () => onProductTap(products[i]),
                    onCtaTap: () => onProductCtaTap(products[i]),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// 2-column vertical product grid matching `.product-grid` (`repeat(2, minmax(0, 1fr)); gap: 12px`).
class KingdomProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onProductCtaTap;
  final EdgeInsetsGeometry? padding;

  const KingdomProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onProductCtaTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final pad =
        padding ?? EdgeInsets.symmetric(horizontal: kPagePadding(context));
    final rows = <Widget>[];

    for (int i = 0; i < products.length; i += 2) {
      final first = products[i];
      final second = i + 1 < products.length ? products[i + 1] : null;
      if (i > 0) {
        rows.add(const SizedBox(height: 12));
      }
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KingdomProductCard(
                product: first,
                onTap: () => onProductTap(first),
                onCtaTap: () => onProductCtaTap(first),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: second != null
                  ? KingdomProductCard(
                      product: second,
                      onTap: () => onProductTap(second),
                      onCtaTap: () => onProductCtaTap(second),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: pad,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}
