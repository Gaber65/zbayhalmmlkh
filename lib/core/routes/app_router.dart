import 'package:dhabayih_lmamlaka/features/admin/presentation/manager/admin_orders_cubit.dart';
import 'package:dhabayih_lmamlaka/features/admin/presentation/views/admin_order_details_screen.dart';
import 'package:dhabayih_lmamlaka/features/admin/views/admin_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../features/shared/splash/splash_screen.dart';
import '../../features/shared/onboarding/onboarding_screen.dart';
import '../../features/shared/auth/presentation/views/login_screen.dart';
import '../../features/shared/auth/presentation/views/register_screen.dart';
import '../../features/shared/auth/presentation/views/otp_screen.dart';
import '../../features/shared/auth/presentation/manager/auth_cubit.dart';
import '../../features/shared/auth/presentation/manager/auth_state.dart';
import '../../features/shared/auth/domain/entities/user_type.dart';
import '../../features/user/home/presentation/views/home_screen.dart';
import '../../features/user/product/views/product_details_screen.dart';
import '../../features/user/cart/views/cart_screen.dart';
import '../../features/user/catalog/presentation/views/categories_screen.dart';
import '../../features/user/catalog/presentation/views/products_by_category_screen.dart';
import '../../features/user/catalog/domain/entities/category.dart';
import '../../features/user/search/presentation/views/search_screen.dart';
import '../../features/user/offers/domain/entities/offer_entity.dart';
import '../../features/user/offers/presentation/views/offer_details_screen.dart';
import '../../features/user/profile/presentation/views/profile_screen.dart';
import '../../features/user/address/presentation/views/addresses_screen.dart';
import '../../features/user/address/presentation/views/map_picker_screen.dart';
import '../../features/user/address/presentation/views/address_form_screen.dart';
import '../../features/user/address/presentation/manager/address_cubit.dart';
import '../../features/user/orders/presentation/views/checkout_screen.dart';
import '../../features/user/orders/presentation/manager/checkout_cubit.dart';
import '../../features/user/orders/presentation/views/order_success_screen.dart';
import '../../features/user/orders/presentation/views/orders_screen.dart';
import '../../features/user/orders/presentation/views/order_details_screen.dart';
import '../../features/user/orders/domain/entities/order_entity.dart';
import '../../features/user/cart/domain/entities/cart.dart';
import '../di/injection.dart';
import '../widgets/main_navigation_shell.dart';
import 'routes.dart';


final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = _rootNavigatorKey;
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // ── Address Management ──────────────────────────────────────────────
      GoRoute(
        path: Routes.addresses,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AddressCubit>()..loadAddresses(),
          child: const AddressesScreen(),
        ),
      ),
      GoRoute(
        path: Routes.mapPicker,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final lat = extra?['latitude'] as double?;
          final lng = extra?['longitude'] as double?;
          return MapPickerScreen(
            initialPosition: (lat != null && lng != null)
                ? LatLng(lat, lng)
                : null,
          );
        },
      ),
      GoRoute(
        path: Routes.addressForm,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final cubit = extra['_cubit'] as AddressCubit?;
          final formExtra = Map<String, dynamic>.from(extra)..remove('_cubit');
          final child = AddressFormScreen(extra: formExtra);
          return cubit != null
              ? BlocProvider.value(value: cubit, child: child)
              : child;
        },
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final isLogin = extra['isLogin'] as bool? ?? true;
          return OtpScreen(email: email, isLogin: isLogin);
        },
      ),
      GoRoute(
        path: Routes.productDetails,
        builder: (context, state) {
          final product = state.extra;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: Routes.productsByCategory,
        builder: (context, state) {
          final category = state.extra as Category;
          return ProductsByCategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: Routes.offerDetails,
        builder: (context, state) {
          final offer = state.extra as OfferEntity;
          return OfferDetailsScreen(offer: offer);
        },
      ),
      GoRoute(
        path: Routes.checkout,
        builder: (context, state) {
          final cart = state.extra as CartEntity;
          return CheckoutScreen(cart: cart);
        },
      ),
      GoRoute(
        path: Routes.orderSuccess,
        builder: (context, state) {
          final result = state.extra as CheckoutResultEntity;
          return OrderSuccessScreen(result: result);
        },
      ),
      GoRoute(
        path: Routes.orderDetails,
        builder: (context, state) {
          final orderId = state.extra as int;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: Routes.adminDashboard,
        redirect: (context, state) {
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated && authState.user.userType != UserType.admin) {
            return Routes.home;
          }
          if (authState is AuthUnauthenticated) {
            return Routes.login;
          }
          return null;
        },
        builder: (context, state) => const AdminLayout(),
      ),
      GoRoute(
        path: Routes.adminOrderDetails,
        builder: (context, state) {
          final orderId = state.extra as int;
          return BlocProvider.value(
            value: getIt<AdminOrdersCubit>(),
            child: AdminOrderDetailsScreen(orderId: orderId),
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.categories,
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: Routes.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: Routes.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
