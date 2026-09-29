import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/domain/entities/cart.dart';
import '../cart_widgets.dart';

class CartWebView extends StatelessWidget {
  final CartEntity cart;
  final bool isPickup;
  final String? fulfillmentText;

  const CartWebView({
    super.key,
    required this.cart,
    required this.isPickup,
    this.fulfillmentText,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return _buildEmptyCart(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Cart Items
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).my_cart,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.lines.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return CartItemCard(line: cart.lines[index]);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              // Right Column: Checkout Summary
              Expanded(
                flex: 1,
                child: _buildCheckoutSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            s.cart_empty,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            s.explore_catalog,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.order_summary,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (fulfillmentText != null && fulfillmentText!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPickup ? Icons.storefront_rounded : Icons.location_on_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fulfillmentText!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.subtotal,
                  style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
              Text('${cart.subtotal.toStringAsFixed(2)} ${s.sar}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.total,
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.onSurface)),
              Text('${cart.total.toStringAsFixed(2)} ${s.sar}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.push(Routes.checkout, extra: cart);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.proceed_checkout,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
