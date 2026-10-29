import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../../../core/api/server_strings.dart';
import '../../../../../../../core/di/injection.dart';
import '../../../../../catalog/data/models/product_model.dart';
import '../../../../../catalog/domain/entities/category.dart';
import '../../../../../catalog/domain/entities/product.dart';
import '../../../../../offers/domain/entities/offer_entity.dart';
import '../../../../domain/entities/home_data.dart';
import 'kingdom_categories_and_products.dart';
import 'kingdom_design.dart';

/// Shared bottom sheet frame matching `<dialog id="sheet">` in `design_reference/index.html`.
class KingdomSheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const KingdomSheetScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x6622271E),
      builder: (ctx) => KingdomSheetScaffold(
        title: title,
        child: builder(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomPad = bottomInset > 24 ? bottomInset : 24.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 480,
        maxHeight: maxH,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: p.paper,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x25151710),
              blurRadius: 80,
              offset: Offset(0, -15),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // .sheet-top
            Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              decoration: BoxDecoration(
                color: p.paper,
                border: Border(bottom: BorderSide(color: p.line)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kText(
                        18,
                        weight: FontWeight.w600,
                        color: p.ink,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  KTap(
                    onTap: () => Navigator.of(context).pop(),
                    radius: BorderRadius.circular(21),
                    semanticLabel: kTr(context, 'إغلاق', 'Close'),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: KSvgIcon(
                          KIcon.close,
                          size: 22,
                          color: p.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the wallet balance sheet matching `handleAction('wallet')`.
Future<void> showKingdomWalletSheet(
  BuildContext context, {
  required double balance,
  int? loyaltyPoints,
}) {
  return KingdomSheetScaffold.show(
    context: context,
    title: kTr(context, 'رصيد الحساب', 'Account Balance'),
    builder: (_) => _KingdomWalletAndLoyaltyView(
      initialBalance: balance,
      initialPoints: loyaltyPoints ?? (balance > 0 ? balance.round() : 0),
      isWalletPrimary: true,
    ),
  );
}

/// Shows the loyalty / rewards info sheet matching `handleAction('loyalty')`.
Future<void> showKingdomLoyaltySheet(
  BuildContext context, {
  double? balance,
  int? loyaltyPoints,
}) {
  return KingdomSheetScaffold.show(
    context: context,
    title: kTr(context, 'نقاط المنتجات والمكافآت', 'Loyalty Points & Rewards'),
    builder: (_) => _KingdomWalletAndLoyaltyView(
      initialBalance: balance ?? 0,
      initialPoints:
          loyaltyPoints ?? ((balance ?? 0) > 0 ? balance!.round() : 0),
      isWalletPrimary: false,
    ),
  );
}

class _KingdomWalletAndLoyaltyView extends StatefulWidget {
  final double initialBalance;
  final int initialPoints;
  final bool isWalletPrimary;

  const _KingdomWalletAndLoyaltyView({
    required this.initialBalance,
    required this.initialPoints,
    required this.isWalletPrimary,
  });

  @override
  State<_KingdomWalletAndLoyaltyView> createState() =>
      _KingdomWalletAndLoyaltyViewState();
}

class _KingdomWalletAndLoyaltyViewState
    extends State<_KingdomWalletAndLoyaltyView> {
  late double _balance = widget.initialBalance;
  late int _points = widget.initialPoints;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveBackendPoints();
  }

  Future<void> _fetchLiveBackendPoints() async {
    if (!getIt.isRegistered<Dio>()) return;
    setState(() => _loading = true);
    final dio = getIt<Dio>();
    int fetchedPoints = _points;
    double fetchedBalance = _balance;

    try {
      final meRes = await dio.get(ServerStrings.profile);
      if (meRes.statusCode == 200 && meRes.data != null) {
        final d = meRes.data is Map ? (meRes.data['data'] ?? meRes.data) : null;
        if (d is Map) {
          final pts = _toInt(
            d['loyalty_points'] ??
                d['points'] ??
                d['current_points'] ??
                d['total_points'],
          );
          final bal = _toDouble(d['balance'] ?? d['wallet_balance']);
          if (pts > 0) fetchedPoints = pts;
          if (bal > 0) fetchedBalance = bal;
        }
      }
    } catch (_) {}

    try {
      final loyRes = await dio.get(ServerStrings.loyaltySummary);
      if (loyRes.statusCode == 200 && loyRes.data != null) {
        final d =
            loyRes.data is Map ? (loyRes.data['data'] ?? loyRes.data) : null;
        if (d is Map) {
          final pts = _toInt(
            d['loyalty_points'] ??
                d['points'] ??
                d['current_points'] ??
                d['total_points'] ??
                d['balance'],
          );
          final bal = _toDouble(
            d['monetary_value'] ??
                d['redemption_value'] ??
                d['cash_value'] ??
                d['wallet_balance'],
          );
          if (pts > 0) fetchedPoints = pts;
          if (fetchedBalance <= 0 && bal > 0) fetchedBalance = bal;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _points = fetchedPoints;
        _balance = fetchedBalance > 0
            ? fetchedBalance
            : (fetchedPoints > 0 ? fetchedPoints.toDouble() : _balance);
        _loading = false;
      });
    }
  }

  static int _toInt(dynamic v) {
    if (v == null || v is bool) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ??
        double.tryParse(v.toString())?.round() ??
        0;
  }

  static double _toDouble(dynamic v) {
    if (v == null || v is bool) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final cur = kCurrency(context);
    final displayPts = _points > 0 ? _points : _balance.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.goldSoftBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.goldSoftBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.card,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: KSvgIcon(
                  widget.isWalletPrimary ? KIcon.bag : KIcon.star,
                  size: 22,
                  color: p.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isWalletPrimary
                          ? kTr(context, 'رصيد الحساب المتاح', 'Available Balance')
                          : kTr(context, 'رصيد نقاط الولاء', 'Loyalty Points Balance'),
                      style: kText(11, color: p.muted, height: 1.4),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            widget.isWalletPrimary
                                ? '${kFormatNumber(_balance)} $cur'
                                : '${kFormatNumber(displayPts)} ${kTr(context, 'نقطة', 'pts')}',
                            style: kText(
                              20,
                              weight: FontWeight.w700,
                              color: p.ink,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (_loading) ...[
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: p.gold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KSvgIcon(KIcon.star, size: 18, color: p.gold),
                  const SizedBox(width: 8),
                  Text(
                    kTr(context, 'إجمالي النقاط المكتسبة', 'Total Loyalty Points'),
                    style: kText(12, weight: FontWeight.w500, color: p.ink),
                  ),
                ],
              ),
              Text(
                '${kFormatNumber(displayPts)} ${kTr(context, 'نقطة', 'pts')}',
                style: kText(13, weight: FontWeight.w600, color: p.goldStrong),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.isWalletPrimary
              ? kTr(
                  context,
                  'رصيد محفظتك ونقاطك المتاحة للاستخدام في طلباتك القادمة عند إتمام الطلب.',
                  'Your wallet balance and loyalty points available to redeem at checkout.',
                )
              : kTr(
                  context,
                  'تظهر النقاط المكتسبة لكل منتج أو حجم داخل خياراته، ويمكنك استبدال نقاطك بخصم مباشر عند الدفع.',
                  'Points earned per product or size are shown in its options, and can be redeemed for discounts at checkout.',
                ),
          style: kText(13, color: p.muted, height: 1.65),
        ),
      ],
    );
  }
}

/// Shows the all-offers picker sheet matching `handleAction('allOffers')`.
Future<void> showKingdomAllOffersSheet(
  BuildContext context, {
  required List<OfferEntity> offers,
  required ValueChanged<OfferEntity> onSelectOffer,
}) {
  return KingdomSheetScaffold.show(
    context: context,
    title: kTr(context, 'العروض الترويجية', 'Promotional Offers'),
    builder: (sheetCtx) {
      final p = KPalette.of(sheetCtx);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final offer in offers)
            KTap(
              onTap: () {
                Navigator.of(sheetCtx).pop();
                onSelectOffer(offer);
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: p.line)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        offer.name,
                        style: kText(13, color: p.ink, height: 1.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      offer.badgeText.isNotEmpty
                          ? offer.badgeText
                          : kTr(sheetCtx, 'عرض خاص', 'Special Offer'),
                      style: kText(
                        13,
                        weight: FontWeight.w600,
                        color: p.red,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// Shows the filter/sort sheet matching `handleAction('filter')`.
Future<void> showKingdomFilterSheet(
  BuildContext context, {
  required List<Category> categories,
  Category? initialCategory,
  String initialSort = 'default',
  required ValueChanged<Category?> onApplyCategory,
  ValueChanged<String>? onApplySort,
}) {
  Category? selected = initialCategory;
  String sort = initialSort;
  return KingdomSheetScaffold.show(
    context: context,
    title: kTr(context, 'رتّب اختياراتك', 'Filter & Sort'),
    builder: (sheetCtx) => StatefulBuilder(
      builder: (context, setSheetState) {
        final p = KPalette.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onApplySort != null) ...[
              Text(
                kTr(context, 'ترتيب المنتجات', 'Sort Products'),
                style: kText(12, weight: FontWeight.w500, color: p.ink),
              ),
              const SizedBox(height: 6),
              _DropdownContainer<String>(
                value: sort,
                items: [
                  DropdownMenuItem(
                    value: 'default',
                    child: Text(
                      kTr(context, 'الترتيب الافتراضي', 'Default Order'),
                      style: kText(12, color: p.ink),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'low',
                    child: Text(
                      kTr(
                        context,
                        'السعر: من الأقل للأعلى',
                        'Price: Low to High',
                      ),
                      style: kText(12, color: p.ink),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'high',
                    child: Text(
                      kTr(
                        context,
                        'السعر: من الأعلى للأقل',
                        'Price: High to Low',
                      ),
                      style: kText(12, color: p.ink),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setSheetState(() => sort = v);
                },
              ),
              const SizedBox(height: 14),
            ],
            if (categories.isNotEmpty) ...[
              Text(
                kTr(context, 'التصنيف', 'Category'),
                style: kText(12, weight: FontWeight.w500, color: p.ink),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  KingdomFilterChip(
                    label: kTr(context, 'الكل', 'All'),
                    selected: selected == null,
                    onTap: () => setSheetState(() => selected = null),
                  ),
                  for (final c in categories)
                    KingdomFilterChip(
                      label: c.name,
                      selected: selected?.id == c.id,
                      onTap: () => setSheetState(() => selected = c),
                    ),
                ],
              ),
              const SizedBox(height: 18),
            ],
            KTap(
              onTap: () {
                Navigator.of(sheetCtx).pop();
                onApplySort?.call(sort);
                onApplyCategory(selected);
              },
              radius: BorderRadius.circular(11),
              semanticLabel: kTr(context, 'عرض المنتجات', 'Show Products'),
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: p.red,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  kTr(context, 'عرض المنتجات', 'Show Products'),
                  style: kText(
                    13,
                    weight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// Reusable pill chip matching `.chip` / `.chip.selected` in `design_reference/index.html`.
class KingdomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const KingdomFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    return KTap(
      onTap: onTap,
      radius: BorderRadius.circular(30),
      selected: selected,
      child: Container(
        constraints: const BoxConstraints(minHeight: 35),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? p.red : p.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? p.red : p.line,
          ),
        ),
        child: Text(
          label,
          style: kText(
            11,
            weight: FontWeight.w500,
            color: selected ? Colors.white : p.ink,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Interactive story modal sheet matching `showStory(groupIndex, index)` in the reference.
Future<void> showKingdomStorySheet(
  BuildContext context, {
  required List<JabinHighlightEntity> groups,
  required int initialGroupIndex,
  ValueChanged<int>? onUserViewed,
}) {
  final validGroups = groups.where((g) => g.highlights.isNotEmpty).toList();
  if (validGroups.isEmpty) return Future.value();

  int groupIndex = initialGroupIndex.clamp(0, validGroups.length - 1);
  int itemIndex = 0;
  onUserViewed?.call(validGroups[groupIndex].user.id);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x6622271E),
    builder: (sheetCtx) => StatefulBuilder(
      builder: (context, setSheetState) {
        final p = KPalette.of(context);
        final group = validGroups[groupIndex];
        final items = group.highlights;
        final safeItemIdx = itemIndex.clamp(0, items.length - 1);
        final item = items[safeItemIdx];

        return KingdomSheetScaffold(
          title: group.user.name,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // .story-progress
              Row(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= safeItemIdx
                              ? p.red
                              : (p.isDark ? p.line : const Color(0xFFDEDFD5)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 13),
              // .story-media
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                  minHeight: 200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: AspectRatio(
                    aspectRatio: 1.35,
                    child: KImage(
                      url: item.mediaUrl,
                      fallbackAsset: KAssets.forName(
                        '${group.user.name} ${item.name}',
                      ),
                      fit: BoxFit.contain,
                      fallbackFit: BoxFit.cover,
                      background: p.isDark
                          ? const Color(0xFF25241E)
                          : const Color(0xFFEAE6DC),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                style: kText(
                  16,
                  weight: FontWeight.w600,
                  color: p.ink,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // .story-pagination
              Row(
                children: [
                  Expanded(
                    child: _StoryNavButton(
                      label: kTr(context, 'السابق', 'Previous'),
                      enabled: safeItemIdx > 0 || groupIndex > 0,
                      onTap: () {
                        setSheetState(() {
                          if (safeItemIdx > 0) {
                            itemIndex = safeItemIdx - 1;
                          } else if (groupIndex > 0) {
                            groupIndex--;
                            itemIndex =
                                validGroups[groupIndex].highlights.length - 1;
                            onUserViewed?.call(validGroups[groupIndex].user.id);
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${safeItemIdx + 1} / ${items.length}',
                        style: kText(11, color: p.ink),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _StoryNavButton(
                      label: kTr(context, 'التالي', 'Next'),
                      enabled: safeItemIdx < items.length - 1 ||
                          groupIndex < validGroups.length - 1,
                      onTap: () {
                        setSheetState(() {
                          if (safeItemIdx < items.length - 1) {
                            itemIndex = safeItemIdx + 1;
                          } else if (groupIndex < validGroups.length - 1) {
                            groupIndex++;
                            itemIndex = 0;
                            onUserViewed?.call(validGroups[groupIndex].user.id);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _StoryNavButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _StoryNavButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: KTap(
        onTap: enabled ? onTap : null,
        radius: BorderRadius.circular(10),
        semanticLabel: label,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: p.cream,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: kText(12, weight: FontWeight.w500, color: p.ink),
          ),
        ),
      ),
    );
  }
}

/// Interactive product options bottom sheet matching `showProduct(id)` in `design_reference/index.html`.
class KingdomProductOptionsSheet extends StatefulWidget {
  final Product product;
  final void Function({
    required double quantity,
    int? sizeId,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
  }) onConfirmAdd;
  final VoidCallback onOpenFullDetails;

  const KingdomProductOptionsSheet({
    super.key,
    required this.product,
    required this.onConfirmAdd,
    required this.onOpenFullDetails,
  });

  static Future<void> show({
    required BuildContext context,
    required Product product,
    required void Function({
      required double quantity,
      int? sizeId,
      int? cuttingOptionId,
      List<int>? packagingIds,
      List<int>? excludedPartIds,
    }) onConfirmAdd,
    required VoidCallback onOpenFullDetails,
  }) {
    final title = product.localizedTitle(context);
    return KingdomSheetScaffold.show(
      context: context,
      title: title,
      builder: (_) => KingdomProductOptionsSheet(
        product: product,
        onConfirmAdd: onConfirmAdd,
        onOpenFullDetails: onOpenFullDetails,
      ),
    );
  }

  @override
  State<KingdomProductOptionsSheet> createState() =>
      _KingdomProductOptionsSheetState();
}

class _KingdomProductOptionsSheetState extends State<KingdomProductOptionsSheet> {
  late Product _p;
  late String _portion;
  int? _sizeId;
  int? _cutId;
  int? _packId;
  final Set<int> _excludedIds = {};
  int _qty = 1;
  int _galleryIdx = 0;

  List<ProductPortion> get _portions => _p.portions;

  List<ProductSize> _sizesForPortion(String portion) {
    final list = _p.sizes
        .where((s) => portion.isEmpty || (s.portionType ?? 'full') == portion)
        .toList();
    list.sort((a, b) => a.sequence.compareTo(b.sequence));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _p = widget.product;
    _initSelectionFromProduct();
    _fetchFullProductDetailsIfNeeded();
  }

  void _initSelectionFromProduct() {
    _portion = _portions.isNotEmpty ? _portions.first.type : '';
    final sizes = _sizesForPortion(_portion);
    final defSize =
        sizes.where((s) => s.isDefault).firstOrNull ?? sizes.firstOrNull;
    _sizeId ??= defSize?.id;
    _cutId ??= _p.cuttingOptions.firstOrNull?.id;
    _packId ??= _p.packagingOptions.firstOrNull?.id;
  }

  /// If `/api/v1/home` omitted `loyalty_points` or `sizes`, fetch `/api/catalog/product/:id`
  /// in the background so real product points and sizes are always shown.
  Future<void> _fetchFullProductDetailsIfNeeded() async {
    if ((_p.loyaltyPoints ?? 0) > 0 && _p.sizes.isNotEmpty) return;
    if (!getIt.isRegistered<Dio>()) return;
    try {
      final dio = getIt<Dio>();
      final res = await dio.get(ServerStrings.productById(_p.id));
      if (res.statusCode == 200 && res.data != null) {
        final rawData = res.data['data'] ?? res.data;
        final prodMap =
            rawData is Map && rawData.containsKey('product')
                ? rawData['product']
                : rawData;
        if (prodMap is Map<String, dynamic>) {
          final fullProduct = ProductModel.fromJson(prodMap).toDomain();
          if (mounted) {
            setState(() {
              _p = fullProduct;
              _initSelectionFromProduct();
            });
          }
        }
      }
    } catch (_) {}
  }

  String _optionLabel(BuildContext context, ProductOption o) {
    if (kIsAr(context)) {
      if (o.nameAr != null && o.nameAr!.trim().isNotEmpty) {
        return o.nameAr!.trim();
      }
      if (o.name.trim().isNotEmpty) return o.name.trim();
      return o.nameEn ?? '';
    } else {
      if (o.nameEn != null && o.nameEn!.trim().isNotEmpty) {
        return o.nameEn!.trim();
      }
      if (o.name.trim().isNotEmpty) return o.name.trim();
      return o.nameAr ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    final cur = kCurrency(context);
    final sizes = _sizesForPortion(_portion);
    final selectedSize = sizes.where((s) => s.id == _sizeId).firstOrNull;
    final selectedPortion =
        _portions.where((pt) => pt.type == _portion).firstOrNull;
    final basePrice = selectedSize?.price ??
        selectedPortion?.startingPrice ??
        _p.displayPrice;

    final selectedCut =
        _p.cuttingOptions.where((o) => o.id == _cutId).firstOrNull;
    final selectedPack =
        _p.packagingOptions.where((o) => o.id == _packId).firstOrNull;
    final selectedExcluded =
        _p.excludedParts.where((o) => _excludedIds.contains(o.id)).toList();

    final extras = <ProductOption?>[
      selectedCut,
      selectedPack,
      ...selectedExcluded,
    ].fold<double>(0, (sum, o) => sum + (o?.extraPrice ?? 0));

    final unitPrice = basePrice + extras;
    final points = (selectedSize?.loyaltyPoints ?? 0) > 0
        ? selectedSize!.loyaltyPoints
        : (_p.loyaltyPoints ?? 0);
    final gallery = _p.galleryImages.isNotEmpty
        ? _p.galleryImages
        : <String>[_p.imageUrl];
    final activeImage = gallery[_galleryIdx.clamp(0, gallery.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // .sheet-photo
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 190,
            child: KImage(
              url: activeImage,
              fallbackAsset: KAssets.forName(_p.title),
              fit: BoxFit.cover,
              fallbackFit: BoxFit.cover,
              background: p.cream,
            ),
          ),
        ),
        const SizedBox(height: 15),
        if (gallery.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (int i = 0; i < gallery.length; i++)
                  KTap(
                    onTap: () => setState(() => _galleryIdx = i),
                    radius: BorderRadius.circular(6),
                    child: Container(
                      width: 48,
                      height: 43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _galleryIdx == i ? p.red : p.line,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: KImage(
                        url: gallery[i],
                        fallbackAsset: KAssets.forName(_p.title),
                        background: p.cream,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Text(
          (_p.description != null && _p.description!.trim().isNotEmpty)
              ? _p.description!.trim()
              : _p.subtitle,
          style: kText(13, color: p.muted, height: 1.6),
        ),
        if (_portions.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            kTr(context, 'حجم الحصة', 'Portion Size'),
            style: kText(12, weight: FontWeight.w500, color: p.ink),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 0; i < _portions.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Expanded(
                  child: _buildPortionButton(context, _portions[i]),
                ),
              ],
            ],
          ),
        ],
        if (sizes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            kTr(context, 'الحجم والوزن', 'Size & Weight'),
            style: kText(12, weight: FontWeight.w500, color: p.ink),
          ),
          const SizedBox(height: 6),
          _DropdownContainer<int>(
            value: _sizeId ?? sizes.first.id,
            items: [
              for (final s in sizes)
                DropdownMenuItem<int>(
                  value: s.id,
                  child: Text(
                    '${s.name}${s.effectiveWeightRange.isNotEmpty ? ' · ${s.effectiveWeightRange}' : ''} — ${kFormatNumber(s.price)} $cur',
                    style: kText(12, color: p.ink),
                  ),
                ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _sizeId = v);
            },
          ),
        ],
        if (_p.cuttingOptions.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            kTr(context, 'طريقة التقطيع', 'Cutting Method'),
            style: kText(12, weight: FontWeight.w500, color: p.ink),
          ),
          const SizedBox(height: 6),
          _DropdownContainer<int>(
            value: _cutId ?? _p.cuttingOptions.first.id,
            items: [
              for (final o in _p.cuttingOptions)
                DropdownMenuItem<int>(
                  value: o.id,
                  child: Text(
                    '${_optionLabel(context, o)}${(o.extraPrice ?? 0) > 0 ? ' (+ ${kFormatNumber(o.extraPrice)} $cur)' : ''}',
                    style: kText(12, color: p.ink),
                  ),
                ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _cutId = v);
            },
          ),
        ],
        if (_p.packagingOptions.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            kTr(context, 'طريقة التغليف', 'Packaging Method'),
            style: kText(12, weight: FontWeight.w500, color: p.ink),
          ),
          const SizedBox(height: 6),
          _DropdownContainer<int>(
            value: _packId ?? _p.packagingOptions.first.id,
            items: [
              for (final o in _p.packagingOptions)
                DropdownMenuItem<int>(
                  value: o.id,
                  child: Text(
                    '${_optionLabel(context, o)}${(o.extraPrice ?? 0) > 0 ? ' (+ ${kFormatNumber(o.extraPrice)} $cur)' : ''}',
                    style: kText(12, color: p.ink),
                  ),
                ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _packId = v);
            },
          ),
        ],
        if (_p.excludedParts.isNotEmpty) ...[
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kTr(context, 'أجزاء ترغب في استبعادها', 'Parts to Exclude'),
                  style: kText(12, weight: FontWeight.w500, color: p.ink),
                ),
                const SizedBox(height: 4),
                for (final o in _p.excludedParts)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (_excludedIds.contains(o.id)) {
                          _excludedIds.remove(o.id);
                        } else {
                          _excludedIds.add(o.id);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _excludedIds.contains(o.id),
                              activeColor: p.red,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _excludedIds.add(o.id);
                                  } else {
                                    _excludedIds.remove(o.id);
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              _optionLabel(context, o),
                              style: kText(12, color: p.ink),
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
        if (points > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              KSvgIcon(
                KIcon.star,
                size: 15,
                color: p.gold,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  kTr(
                    context,
                    'تكسب ${kFormatNumber(points)} من النقاط لهذا الاختيار',
                    'You earn ${kFormatNumber(points)} points for this selection',
                  ),
                  style: kText(11, color: p.gold),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        // .selection-summary
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: p.cream,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedSize != null
                        ? '${kTr(context, 'سعر الحجم', 'Size Price')} (${selectedSize.name})'
                        : kTr(context, 'سعر الاختيار', 'Selection Price'),
                    style: kText(11, color: p.ink),
                  ),
                  Text(
                    '${kFormatNumber(basePrice)} $cur',
                    style: kText(11, weight: FontWeight.w500, color: p.ink),
                  ),
                ],
              ),
              if ((selectedCut?.extraPrice ?? 0) > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${kTr(context, 'رسوم التقطيع', 'Cutting Fee')} (${_optionLabel(context, selectedCut!)})',
                      style: kText(11, color: p.ink),
                    ),
                    Text(
                      '+ ${kFormatNumber(selectedCut.extraPrice)} $cur',
                      style: kText(11, weight: FontWeight.w500, color: p.ink),
                    ),
                  ],
                ),
              ],
              if ((selectedPack?.extraPrice ?? 0) > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${kTr(context, 'رسوم التغليف', 'Packaging Fee')} (${_optionLabel(context, selectedPack!)})',
                      style: kText(11, color: p.ink),
                    ),
                    Text(
                      '+ ${kFormatNumber(selectedPack.extraPrice)} $cur',
                      style: kText(11, weight: FontWeight.w500, color: p.ink),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // .detail-price
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      kFormatNumber(unitPrice * _qty),
                      style: kText(
                        25,
                        weight: FontWeight.w600,
                        color: p.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cur,
                    style: kText(10, color: p.muted),
                  ),
                ],
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: p.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KTap(
                        onTap: () {
                          if (_qty > 1) setState(() => _qty--);
                        },
                        semanticLabel: kTr(
                          context,
                          'تقليل الكمية',
                          'Decrease quantity',
                        ),
                        child: SizedBox(
                          width: 34,
                          height: 36,
                          child: Center(
                            child: Icon(Icons.remove, size: 15, color: p.ink),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          '$_qty',
                          textAlign: TextAlign.center,
                          style: kText(13, color: p.ink),
                        ),
                      ),
                      const SizedBox(width: 6),
                      KTap(
                        onTap: () {
                          if (_qty < 99) setState(() => _qty++);
                        },
                        semanticLabel: kTr(
                          context,
                          'زيادة الكمية',
                          'Increase quantity',
                        ),
                        child: SizedBox(
                          width: 34,
                          height: 36,
                          child: Center(
                            child: KSvgIcon(KIcon.plus, size: 15, color: p.ink),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        KTap(
          onTap: _p.isEffectivelyAvailable
              ? () {
                  Navigator.of(context).pop();
                  widget.onConfirmAdd(
                    quantity: _qty.toDouble(),
                    sizeId: _sizeId,
                    cuttingOptionId: _cutId,
                    packagingIds: _packId != null ? <int>[_packId!] : null,
                    excludedPartIds:
                        _excludedIds.isNotEmpty ? _excludedIds.toList() : null,
                  );
                }
              : null,
          radius: BorderRadius.circular(11),
          semanticLabel: kTr(context, 'إضافة إلى السلة', 'Add to Cart'),
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: _p.isEffectivelyAvailable ? p.red : p.disabledBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _p.isEffectivelyAvailable
                      ? kTr(context, 'إضافة إلى السلة', 'Add to Cart')
                      : kTr(context, 'غير متاح حاليًا', 'Out of stock'),
                  style: kText(
                    13,
                    weight: FontWeight.w500,
                    color: _p.isEffectivelyAvailable
                        ? Colors.white
                        : p.disabledFg,
                  ),
                ),
                const SizedBox(width: 8),
                KSvgIcon(
                  KIcon.bag,
                  size: 20,
                  color: _p.isEffectivelyAvailable
                      ? Colors.white
                      : p.disabledFg,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        KTap(
          onTap: () {
            Navigator.of(context).pop();
            widget.onOpenFullDetails();
          },
          radius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: p.cream,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              kTr(
                context,
                'عرض صفحة المنتج الكاملة',
                'View Full Product Page',
              ),
              style: kText(12, weight: FontWeight.w500, color: p.ink),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortionButton(BuildContext context, ProductPortion pt) {
    final p = KPalette.of(context);
    final cur = kCurrency(context);
    final selected = _portion == pt.type;
    return KTap(
      onTap: () {
        setState(() {
          _portion = pt.type;
          final sizes = _sizesForPortion(_portion);
          final def =
              sizes.where((s) => s.isDefault).firstOrNull ?? sizes.firstOrNull;
          _sizeId = def?.id;
        });
      },
      radius: BorderRadius.circular(9),
      selected: selected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? p.redSoftBg : p.card,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? p.red : p.line,
          ),
        ),
        child: Column(
          children: [
            Text(
              pt.name,
              textAlign: TextAlign.center,
              style: kText(
                13,
                weight: FontWeight.w600,
                color: selected ? p.red : p.ink,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              kTr(
                context,
                'من ${kFormatNumber(pt.startingPrice)} $cur',
                'From ${kFormatNumber(pt.startingPrice)} $cur',
              ),
              textAlign: TextAlign.center,
              style: kText(
                10,
                color: p.muted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownContainer<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownContainer({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = KPalette.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: p.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: KSvgIcon(KIcon.down, size: 16, color: p.ink),
          dropdownColor: p.card,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
