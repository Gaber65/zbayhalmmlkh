import 'package:flutter/material.dart';
import 'package:dhabayih_lmamlaka/core/theme/app_icons.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../../domain/entities/home_data.dart';

class CartBadgeWidget extends StatelessWidget {
  final ActiveCart? activeCart;
  final VoidCallback onPressed;

  const CartBadgeWidget({
    super.key,
    this.activeCart,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final count = activeCart?.lineCount ?? 0;

    return Semantics(
      button: true,
      label: count > 0
          ? S.of(context).cart_semantics_count(count)
          : S.of(context).cart_semantics_empty,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(AppIcons.bagOutline),
            onPressed: onPressed,
            color: colorScheme.onSurface,
            tooltip: S.of(context).my_cart,
          ),
          if (count > 0)
            PositionedDirectional(
              top: 6,
              end: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.error.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
