import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import 'package:dhabayih_lmamlaka/features/user/address/domain/services/fulfillment_service.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/domain/entities/cart.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/cart/presentation/manager/cart_state.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_cubit.dart';
import 'package:dhabayih_lmamlaka/features/shared/auth/presentation/manager/auth_state.dart';
import 'package:dhabayih_lmamlaka/core/widgets/guest_prompt_widget.dart';

import 'widgets/mobile/cart_mobile_view.dart';
import 'widgets/web/cart_web_view.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isPickup = false;
  String? _fulfillmentText;

  @override
  void initState() {
    super.initState();
    _loadFulfillment();
  }

  Future<void> _loadFulfillment() async {
    final isPickupMode = await FulfillmentService.isStorePickup();
    final locationText = await FulfillmentService.getDisplayLocation();
    if (mounted) {
      setState(() {
        _isPickup = isPickupMode;
        _fulfillmentText = locationText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final bool isGuest = authState is! AuthAuthenticated;

        return BlocProvider(
          create: (_) => getIt<CartCubit>()..fetchCart(),
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              title: Text(
                S.of(context).my_cart,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.home);
                  }
                },
              ),
            ),
            body: isGuest
                ? const GuestPromptWidget()
                : BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state is CartLoading || state is CartInitial) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CartError) {
                        return _buildErrorView(context, state.message);
                      } else if (state is CartLoaded) {
                        return _buildCartContent(context, state.cart);
                      } else if (state is CartItemAdded) {
                        return _buildCartContent(context, state.cart);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<CartCubit>().fetchCart(),
              icon: const Icon(Icons.refresh),
              label: Text(S.of(context).retry_button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartEntity cart) {
    return ResponsiveLayout(
      mobile: CartMobileView(
        cart: cart,
        isPickup: _isPickup,
        fulfillmentText: _fulfillmentText,
      ),
      desktop: CartWebView(
        cart: cart,
        isPickup: _isPickup,
        fulfillmentText: _fulfillmentText,
      ),
    );
  }
}
