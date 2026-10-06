import 'package:flutter/material.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/core/widgets/price_widget.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        ?trailing,
      ],
    );
  }
}

class StockBadge extends StatelessWidget {
  final bool isAvailable;
  const StockBadge({super.key, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final color = isAvailable ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? s.in_stock : s.out_of_stock,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PriceSection extends StatelessWidget {
  final Product product;
  const PriceSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    final saving = product.savingAmount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PriceWidget(
          price: product.displayPrice,
          originalPrice: product.isOnOffer && product.price > 0 ? product.price : null,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: product.isOnOffer ? cs.error : cs.primary,
            fontWeight: FontWeight.bold,
          ),
          originalStyle: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        if (saving != null && saving > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              s.saving_label(saving.toStringAsFixed(0)),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class LoyaltyBadge extends StatelessWidget {
  final int points;
  const LoyaltyBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.primary.withValues(alpha: 0.15)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            s.points_count(points),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final double quantity;
  final ValueChanged<double> onChanged;
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _QBtn(
          icon: Icons.remove,
          onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          cs: cs,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            quantity.toInt().toString(),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        _QBtn(icon: Icons.add, onTap: () => onChanged(quantity + 1), cs: cs),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme cs;
  const _QBtn({required this.icon, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? cs.onPrimary : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class CuttingOptionsSelector extends StatelessWidget {
  final List<ProductOption> options;
  final ProductOption? selected;
  final ValueChanged<ProductOption?> onSelect;
  const CuttingOptionsSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected?.id == opt.id;
        final label = isAr
            ? (opt.nameAr ?? opt.name)
            : (opt.nameEn ?? opt.name);
        return GestureDetector(
          onTap: () => onSelect(isSelected ? null : opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cs.primary : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class PackagingOptionsSelector extends StatelessWidget {
  final List<ProductOption> options;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;
  const PackagingOptionsSelector({
    super.key,
    required this.options,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      children: options.map((opt) {
        final isSelected = selectedIds.contains(opt.id);
        final label = isAr
            ? (opt.nameAr ?? opt.name)
            : (opt.nameEn ?? opt.name);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) => onToggle(opt.id),
          title: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          activeColor: cs.primary,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }
}

class ExcludedPartsSelector extends StatelessWidget {
  final List<ProductOption> parts;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;
  const ExcludedPartsSelector({
    super.key,
    required this.parts,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      children: parts.map((part) {
        final isSelected = selectedIds.contains(part.id);
        final label = isAr
            ? (part.nameAr ?? part.name)
            : (part.nameEn ?? part.name);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) => onToggle(part.id),
          title: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          activeColor: cs.error.withValues(alpha: 0.85),
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }
}

class SelectionSummary extends StatelessWidget {
  final Product product;
  final ProductOption? selectedCuttingOption;
  final Set<int> selectedPackagingIds;
  final Set<int> selectedExcludedPartIds;
  final double quantity;

  const SelectionSummary({
    super.key,
    required this.product,
    required this.selectedCuttingOption,
    required this.selectedPackagingIds,
    required this.selectedExcludedPartIds,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';

    final selectedPkgs = product.packagingOptions.where(
      (p) => selectedPackagingIds.contains(p.id),
    );
    final selectedExcluded = product.excludedParts.where(
      (p) => selectedExcludedPartIds.contains(p.id),
    );

    final hasSummary =
        selectedCuttingOption != null ||
        selectedPkgs.isNotEmpty ||
        selectedExcluded.isNotEmpty;

    if (!hasSummary) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.your_selection,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 10),
          if (selectedCuttingOption != null)
            SummaryRow(
              icon: Icons.content_cut_rounded,
              label: s.cutting_options,
              value: isAr
                  ? (selectedCuttingOption!.nameAr ??
                        selectedCuttingOption!.name)
                  : (selectedCuttingOption!.nameEn ??
                        selectedCuttingOption!.name),
            ),
          if (selectedPkgs.isNotEmpty)
            SummaryRow(
              icon: Icons.inventory_2_outlined,
              label: s.packaging_options,
              value: selectedPkgs
                  .map(
                    (p) => isAr ? (p.nameAr ?? p.name) : (p.nameEn ?? p.name),
                  )
                  .join(', '),
            ),
          if (selectedExcluded.isNotEmpty)
            SummaryRow(
              icon: Icons.do_not_disturb_alt_outlined,
              label: s.excluded_parts,
              value: selectedExcluded
                  .map(
                    (p) => isAr ? (p.nameAr ?? p.name) : (p.nameEn ?? p.name),
                  )
                  .join(', '),
            ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.total,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              PriceWidget(
                price: product.displayPrice * quantity,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const SummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
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

/// Double card row showing Price in SAR and Points Price
class CarcassPriceCards extends StatelessWidget {
  final double price;
  final int pointsPrice;

  const CarcassPriceCards({
    super.key,
    required this.price,
    required this.pointsPrice,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // 1. Regular Price Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السعر',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ر.س',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Points Price Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'السعر بالنقاط',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      pointsPrice > 0 ? pointsPrice.toString() : (price * 4).toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'نقطة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Calories full-width row with lightning icon
class CaloriesBadgeBar extends StatelessWidget {
  final int calories;

  const CaloriesBadgeBar({super.key, required this.calories});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            calories.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '/  السعرات الحرارية',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loyalty Reward row with star icon
class LoyaltyRewardBar extends StatelessWidget {
  final int points;

  const LoyaltyRewardBar({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFF16A34A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نقاط الولاء',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'اكسب ${points.toStringAsFixed(2)} نقطة ولاء عند شراء هذا المنتج',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
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

/// Carcass size vertical radio selector matching screenshot
class CarcassSizesSelector extends StatelessWidget {
  final List<ProductSize> sizes;
  final ProductSize? selected;
  final ValueChanged<ProductSize> onSelect;

  const CarcassSizesSelector({
    super.key,
    required this.sizes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: sizes.map((size) {
        final isSelected = selected?.id == size.id;

        return GestureDetector(
          onTap: () => onSelect(size),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? cs.primaryContainer.withValues(alpha: 0.3) : const Color(0xFFF0FDF4))
                  : (isDark ? cs.surfaceContainerHighest : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF16A34A) : cs.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF16A34A) : cs.onSurfaceVariant.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Name and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        size.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF166534) : cs.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (size.subTitle != null && size.subTitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          size.subTitle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Price
                Text(
                  '${size.price.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? const Color(0xFF16A34A) : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

