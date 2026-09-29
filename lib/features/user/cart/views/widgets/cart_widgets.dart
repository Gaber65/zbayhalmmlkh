import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/domain/entities/cart.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_cubit.dart';

class CartItemCard extends StatelessWidget {
  final CartLineEntity line;
  const CartItemCard({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final cuttingName = line.cuttingOption != null
        ? (isAr
              ? (line.cuttingOption!.nameAr ?? line.cuttingOption!.name)
              : (line.cuttingOption!.nameEn ?? line.cuttingOption!.name))
        : null;

    final pkgNames = line.packagingOptions
        .map((p) => isAr ? (p.nameAr ?? p.name) : (p.nameEn ?? p.name))
        .join(', ');

    final excludedNames = line.excludedParts
        .map((p) => isAr ? (p.nameAr ?? p.name) : (p.nameEn ?? p.name))
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 76,
                  height: 76,
                  color: cs.surfaceContainerHighest,
                  child:
                      line.productImageUrl != null &&
                          line.productImageUrl!.isNotEmpty
                      ? Image.network(
                          line.productImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.inventory_2_outlined,
                            color: cs.primary,
                          ),
                        )
                      : Icon(Icons.inventory_2_outlined, color: cs.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            line.productName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            context.read<CartCubit>().removeFromCart(
                              productId: line.productId,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${line.priceUnit.toStringAsFixed(2)} ${s.sar}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (cuttingName != null ||
              pkgNames.isNotEmpty ||
              excludedNames.isNotEmpty ||
              (line.notes != null && line.notes!.isNotEmpty)) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (cuttingName != null)
                  OptionBadge(
                    icon: Icons.content_cut_rounded,
                    label: '${s.cutting_options}: $cuttingName',
                    color: cs.primary,
                  ),
                if (pkgNames.isNotEmpty)
                  OptionBadge(
                    icon: Icons.inventory_2_outlined,
                    label: '${s.packaging_options}: $pkgNames',
                    color: Colors.blueAccent,
                  ),
                if (excludedNames.isNotEmpty)
                  OptionBadge(
                    icon: Icons.do_not_disturb_alt_outlined,
                    label: '${s.excluded_parts}: $excludedNames',
                    color: Colors.deepOrange,
                  ),
                if (line.notes != null && line.notes!.isNotEmpty)
                  OptionBadge(
                    icon: Icons.edit_note_rounded,
                    label: line.notes!,
                    color: Colors.purple,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  context.push(Routes.productDetails, extra: line.productId);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 14, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        s.edit,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (line.quantity > 1) {
                          context.read<CartCubit>().updateCartItem(
                            productId: line.productId,
                            quantity: line.quantity - 1,
                          );
                        } else {
                          context.read<CartCubit>().removeFromCart(
                            productId: line.productId,
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Text(
                      '${line.quantity.toInt()}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<CartCubit>().updateCartItem(
                          productId: line.productId,
                          quantity: line.quantity + 1,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${line.lineTotal.toStringAsFixed(2)} ${s.sar}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OptionBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const OptionBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
