import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../core/api/server_strings.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/services/app_update_service.dart';
import '../../../../../../core/utils/whatsapp_helper.dart';
import '../../../../../../core/widgets/product_card.dart';
import '../../../../../../core/widgets/responsive_layout.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../shared/auth/domain/repositories/auth_repository.dart';
import '../../../../shared/auth/presentation/manager/auth_cubit.dart';
import '../../../../shared/auth/presentation/manager/auth_state.dart';
import '../../../address/domain/services/fulfillment_service.dart';
import '../../../address/presentation/manager/address_cubit.dart';
import '../../../address/presentation/views/widgets/address_selection_bottom_sheet.dart';
import '../../../cart/presentation/manager/cart_cubit.dart';
import '../../../cart/presentation/manager/cart_state.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../favorites/presentation/manager/favorites_cubit.dart';
import '../../../favorites/presentation/manager/favorites_state.dart';
import '../../../offers/data/models/offer_model.dart';
import '../../../profile/presentation/manager/profile_cubit.dart';
import '../../../profile/presentation/manager/profile_state.dart';
import '../../domain/entities/home_data.dart';
import '../manager/home_cubit.dart';
import '../manager/home_state.dart';
import 'widgets/kingdom/kingdom_categories_and_products.dart';
import 'widgets/kingdom/kingdom_design.dart';
import 'widgets/kingdom/kingdom_header_and_banner.dart';
import 'widgets/kingdom/kingdom_offers_stories_footer.dart';
import 'widgets/kingdom/kingdom_sheets.dart';
import 'widgets/section_header_widget.dart';
import 'widgets/user_notifications_sheet.dart';
import 'widgets/web/web_category_section_widget.dart';
import 'widgets/web/web_featured_collections_widget.dart';
import 'widgets/web/web_hero_section_widget.dart';
import 'widgets/web/web_navbar_widget.dart';
import 'widgets/web/web_newsletter_and_footer_widget.dart';
import 'widgets/web/web_testimonials_widget.dart';
import 'widgets/web/web_why_choose_us_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  String? _selectedLocationOverride;
  String _fulfillmentMode = 'delivery';
  final Set<int> _viewedStoryUserIds = {};
  int? _localCartLineCountOverride;
  int? _liveLoyaltyPoints;
  double? _liveBalance;

  @override
  void initState() {
    super.initState();
    _loadSavedFulfillment();
    _registerFcmIfAuthenticated();
    _fetchLiveUserPointsAndBalance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.checkUpdate(context);
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveUserPointsAndBalance() async {
    if (!getIt.isRegistered<Dio>()) return;
    final dio = getIt<Dio>();
    int? fetchedPoints;
    double? fetchedBalance;

    int? parseInt(dynamic raw) {
      if (raw == null) return null;
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw is String) return double.tryParse(raw.trim())?.toInt();
      return null;
    }

    double? parseDouble(dynamic raw) {
      if (raw == null) return null;
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw.trim());
      return null;
    }

    try {
      final meRes = await dio.get(ServerStrings.profile);
      final raw = meRes.data;
      final data = raw is Map<String, dynamic>
          ? (raw['data'] is Map<String, dynamic>
              ? raw['data'] as Map<String, dynamic>
              : raw)
          : null;
      if (data != null) {
        final pts = parseInt(
          data['loyalty_points'] ??
              data['points'] ??
              data['current_points'] ??
              data['total_points'],
        );
        final bal = parseDouble(
          data['balance'] ?? data['wallet_balance'] ?? data['credit'],
        );
        if (pts != null) fetchedPoints = pts;
        if (bal != null && bal > 0) fetchedBalance = bal;
      }
    } catch (_) {}

    if (fetchedPoints == null || fetchedPoints <= 0) {
      try {
        final loyRes = await dio.get(ServerStrings.loyaltySummary);
        final raw = loyRes.data;
        final data = raw is Map<String, dynamic>
            ? (raw['data'] is Map<String, dynamic>
                ? raw['data'] as Map<String, dynamic>
                : raw)
            : null;
        if (data != null) {
          final pts = parseInt(
            data['current_points'] ??
                data['loyalty_points'] ??
                data['points'] ??
                data['total_points'],
          );
          if (pts != null) fetchedPoints = pts;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    if (fetchedPoints != null || fetchedBalance != null) {
      setState(() {
        if (fetchedPoints != null) _liveLoyaltyPoints = fetchedPoints;
        if (fetchedBalance != null) _liveBalance = fetchedBalance;
      });
    }
  }

  void _registerFcmIfAuthenticated() {
    try {
      FirebaseMessaging.instance.subscribeToTopic('all');
    } catch (e) {
      debugPrint('Failed to subscribe to topic: $e');
    }

    if (!getIt.isRegistered<AuthRepository>()) return;
    final authRepo = getIt<AuthRepository>();
    authRepo.getCachedUser().then((result) {
      result.fold((_) {}, (user) {
        if (user != null) {
          authRepo.registerFcmToken();
        }
      });
    });
  }

  Future<void> _loadSavedFulfillment() async {
    try {
      final mode = await FulfillmentService.getFulfillmentMode();
      final locationText = await FulfillmentService.getDisplayLocation();
      if (mounted) {
        setState(() {
          _fulfillmentMode = mode;
          if (locationText != null && locationText.isNotEmpty) {
            _selectedLocationOverride = locationText;
          }
        });
      }
    } catch (_) {}
  }

  void _onRefresh(BuildContext context) async {
    await Future.wait([
      context.read<HomeCubit>().fetchHomeData(),
      _fetchLiveUserPointsAndBalance(),
    ]);
    _refreshController.refreshCompleted();
  }

  void _openAddressSelectionBottomSheet(
    BuildContext context, {
    String? mode,
  }) async {
    final result = await AddressSelectionBottomSheet.show(
      context,
      initialLocation: _selectedLocationOverride,
      initialMode: mode ?? _fulfillmentMode,
      cubit: getIt<AddressCubit>()..loadAddresses(),
    );

    if (result != null && mounted) {
      final resMode = result['mode'] as String?;
      final text = result['displayText'] as String?;
      setState(() {
        if (resMode != null) _fulfillmentMode = resMode;
        if (text != null && text.isNotEmpty) {
          _selectedLocationOverride = text;
        }
      });
    }
  }

  void _showKingdomToast(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: kText(12, color: Colors.white, height: 1.4),
        ),
        backgroundColor: const Color(0xFF303B2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(milliseconds: 2300),
      ),
    );
  }

  HomeCubit _resolveHomeCubit(BuildContext context) {
    try {
      return context.read<HomeCubit>();
    } catch (_) {
      return getIt<HomeCubit>()..fetchHomeData();
    }
  }

  CartCubit? _resolveCartCubit(BuildContext context) {
    try {
      return context.read<CartCubit>();
    } catch (_) {
      if (getIt.isRegistered<CartCubit>()) {
        return getIt<CartCubit>();
      }
      return null;
    }
  }

  int _resolveFavoritesCount(BuildContext context) {
    try {
      final favState = context.watch<FavoritesCubit>().state;
      if (favState is FavoritesLoaded) {
        return favState.favoriteIds.length;
      }
    } catch (_) {}
    return 0;
  }

  int? _resolveLoyaltyPointsOverride(BuildContext context) {
    try {
      final profileState = context.watch<ProfileCubit>().state;
      if (profileState is ProfileLoaded && profileState.profile.loyaltyPoints > 0) {
        return profileState.profile.loyaltyPoints;
      }
    } catch (_) {}
    return _liveLoyaltyPoints;
  }

  int _resolveActiveCartLines(BuildContext context, HomeData? homeData) {
    if (_localCartLineCountOverride != null) {
      return _localCartLineCountOverride!;
    }
    try {
      final cartState = context.watch<CartCubit>().state;
      if (cartState is CartLoaded) {
        return cartState.cart.itemCount;
      }
      if (cartState is CartItemAdded) {
        return cartState.cart.itemCount;
      }
    } catch (_) {}
    return homeData?.userHighlight?.activeCart?.lineCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final p = KPalette.of(context);

    Widget content = BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeLoaded || state is HomeError) {
          _refreshController.refreshCompleted();
          _refreshController.loadComplete();
        }
      },
      builder: (context, state) {
        final bool isLoading = state is HomeLoading || state is HomeInitial;
        final HomeData? homeData = state is HomeLoaded ? state.homeData : null;
        final EffectiveHomeData effective = _effectiveHomeData(homeData);

        if (state is HomeError) {
          return Scaffold(
            backgroundColor: isMobile ? p.paper : Theme.of(context).colorScheme.surface,
            body: SmartRefresher(
              controller: _refreshController,
              enablePullDown: !kIsWeb,
              header: WaterDropMaterialHeader(
                backgroundColor: p.red,
                color: Colors.white,
              ),
              onRefresh: () => _onRefresh(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(context, state.message),
                  ),
                ],
              ),
            ),
          );
        }

        if (isMobile) {
          return _buildMobileScaffold(
            context,
            homeData: effective.data,
            isLoading: isLoading && homeData == null,
          );
        }

        final colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Skeletonizer(
            enabled: isLoading && homeData == null,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                WebNavbarWidget(
                  userHighlight: effective.data.userHighlight,
                  deliveryLocation: _selectedLocationOverride ??
                      effective.data.deliveryLocation,
                  onLocationTap: () => _openAddressSelectionBottomSheet(context),
                ),
                SliverToBoxAdapter(
                  child: _buildDesktopContent(
                    context,
                    effective.data,
                    isLoading,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Provide HomeCubit & CartCubit if not already provided higher up in the tree.
    bool hasHomeCubit = false;
    try {
      context.read<HomeCubit>();
      hasHomeCubit = true;
    } catch (_) {}

    bool hasCartCubit = false;
    try {
      context.read<CartCubit>();
      hasCartCubit = true;
    } catch (_) {}

    final providers = <BlocProvider>[
      if (!hasHomeCubit)
        BlocProvider<HomeCubit>(
          create: (ctx) => _resolveHomeCubit(ctx),
        ),
      if (!hasCartCubit && getIt.isRegistered<CartCubit>())
        BlocProvider<CartCubit>(
          create: (_) => getIt<CartCubit>(),
        ),
    ];

    if (providers.isNotEmpty) {
      content = MultiBlocProvider(
        providers: providers,
        child: content,
      );
    }

    return content;
  }

  EffectiveHomeData _effectiveHomeData(HomeData? homeData) {
    if (homeData != null) {
      return EffectiveHomeData(homeData);
    }
    // Skeleton placeholder while loading
    return const EffectiveHomeData(HomeData());
  }

  Widget _buildMobileScaffold(
    BuildContext context, {
    required HomeData homeData,
    required bool isLoading,
  }) {
    final p = KPalette.of(context);
    final favCount = _resolveFavoritesCount(context);
    final deliveryLoc = _selectedLocationOverride ?? homeData.deliveryLocation;
    final activeLines = _resolveActiveCartLines(context, homeData);
    final cartCubit = _resolveCartCubit(context);

    Widget body = Column(
      children: [
        KingdomHeaderWidget(
          deliveryLocation: deliveryLoc,
          favoritesCount: favCount,
          onLocationTap: () => _openAddressSelectionBottomSheet(context),
          onFavoritesTap: () => context.push(Routes.favorites),
          onNotificationsTap: () => UserNotificationsSheet.show(context),
          onSearchTap: () => context.push(Routes.search),
          onFilterTap: () {
            showKingdomFilterSheet(
              context,
              categories: homeData.categories,
              onApplyCategory: (selectedCategory) {
                if (selectedCategory != null) {
                  context.push(
                    Routes.productsByCategory,
                    extra: selectedCategory,
                  );
                } else {
                  context.push(Routes.categories);
                }
              },
            );
          },
        ),
        Expanded(
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: !kIsWeb,
            header: WaterDropMaterialHeader(
              backgroundColor: p.red,
              color: Colors.white,
            ),
            onRefresh: () => _onRefresh(context),
            child: Skeletonizer(
              enabled: isLoading,
              child: SingleChildScrollView(
                physics: kIsWeb
                    ? const AlwaysScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                child: _buildMobileBody(
                  context,
                  homeData: homeData,
                  activeCartLineCount: activeLines,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (cartCubit != null) {
      body = BlocListener<CartCubit, CartState>(
        bloc: cartCubit,
        listenWhen: (_, _) => true,
        listener: (ctx, cartState) {
          if (cartState is CartItemAdded) {
            setState(() {
              _localCartLineCountOverride = cartState.cart.itemCount;
            });
            _showKingdomToast(
              ctx,
              kTr(ctx, 'تمت الإضافة إلى سلتك', 'Added to your cart'),
            );
          } else if (cartState is CartItemAddError) {
            _showKingdomToast(ctx, cartState.message);
          }
        },
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: p.paper,
      body: body,
    );
  }

  Widget _buildMobileBody(
    BuildContext context, {
    required HomeData homeData,
    required int activeCartLineCount,
  }) {
    final activeOffers = homeData.offers.where((o) => o.isActive).toList();
    final storyGroups = homeData.jabinHighlight
        .where((g) => g.highlights.isNotEmpty)
        .toList();
    final pointsOverride = _resolveLoyaltyPointsOverride(context);
    final userH = homeData.userHighlight;
    final effectivePoints = pointsOverride ??
        ((userH != null && userH.loyaltyPoints > 0)
            ? userH.loyaltyPoints
            : null);
    final effectiveBalance = _liveBalance ?? userH?.effectiveBalance ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. User welcome line (#userSlot -> .welcome-line)
        KingdomWelcomeLineWidget(
          userHighlight: userH,
          loyaltyPointsOverride: pointsOverride,
          balanceOverride: _liveBalance,
          onWalletTap: () => showKingdomWalletSheet(
            context,
            balance: effectiveBalance,
            loyaltyPoints: effectivePoints,
          ),
          onLoyaltyTap: () => showKingdomLoyaltySheet(
            context,
            balance: effectiveBalance,
            loyaltyPoints: effectivePoints,
          ),
        ),

        // 2. Hero banner stage + caption + prev/dots/next (#bannerSection)
        if (homeData.banners.isNotEmpty)
          KingdomBannerSectionWidget(
            banners: homeData.banners,
            onBannerTap: (banner) => _onBannerTap(context, banner, homeData),
          ),

        // 3. Customer reviews / grouped stories (#storiesSection — "تجارب العملاء")
        // Moved near the top of the home screen immediately below the main banner.
        if (storyGroups.isNotEmpty)
          KingdomStoriesSection(
            groups: storyGroups,
            viewedUserIds: _viewedStoryUserIds,
            onGroupTap: (groupIndex) {
              showKingdomStorySheet(
                context,
                groups: storyGroups,
                initialGroupIndex: groupIndex,
                onUserViewed: (userId) {
                  if (mounted) {
                    setState(() => _viewedStoryUserIds.add(userId));
                  }
                },
              );
            },
          ),

        // 4. Two-column photographic categories (#categoriesSection — all categories visible)
        if (homeData.categories.isNotEmpty)
          KingdomCategoriesSection(
            categories: homeData.categories,
            onCategoryTap: (category) {
              context.push(Routes.productsByCategory, extra: category);
            },
            onViewAllCategories: () => context.push(Routes.categories),
          ),

        // 5. Best sellers horizontal strip (#bestsellersSection — "الأكثر طلبًا")
        if (homeData.bestSellers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KingdomSectionHeader(
                  title: kTr(context, 'الأكثر طلبًا', 'Best Sellers'),
                  actionLabel: kTr(context, 'عرض الكل', 'View All'),
                  onActionTap: () => context.push(Routes.categories),
                ),
                KingdomHorizontalProductList(
                  products: homeData.bestSellers,
                  onProductTap: (p) => _onProductDetailTap(context, p),
                  onProductCtaTap: (p) => _onProductCtaTap(context, p),
                ),
              ],
            ),
          ),

        // 6. Active cart summary banner (#activeCartSlot)
        if (activeCartLineCount > 0)
          KingdomActiveCartBanner(
            lineCount: activeCartLineCount,
            onTap: () => context.go(Routes.cart),
          ),

        // 7. Promotional offers row (#offersSection — "العروض الترويجية")
        if (activeOffers.isNotEmpty)
          KingdomOffersSection(
            offers: activeOffers,
            onOfferTap: (offer) {
              context.push(Routes.offerDetails, extra: offer);
            },
            onViewAllTap: () {
              if (activeOffers.length == 1) {
                context.push(Routes.offerDetails, extra: activeOffers.first);
              } else {
                showKingdomAllOffersSheet(
                  context,
                  offers: activeOffers,
                  onSelectOffer: (offer) {
                    context.push(Routes.offerDetails, extra: offer);
                  },
                );
              }
            },
          ),

        // 8. Featured products 2-column grid (#featuredSection — "المنتجات المميزة")
        if (homeData.featuredProducts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KingdomSectionHeader(
                  title: kTr(context, 'المنتجات المميزة', 'Featured Products'),
                  actionLabel: kTr(context, 'عرض الكل', 'View All'),
                  onActionTap: () => context.push(Routes.categories),
                ),
                KingdomProductGrid(
                  products: homeData.featuredProducts,
                  onProductTap: (p) => _onProductDetailTap(context, p),
                  onProductCtaTap: (p) => _onProductCtaTap(context, p),
                ),
              ],
            ),
          ),

        // 9. Recommended products horizontal strip ("منتجات مقترحة لك")
        if (homeData.recommendedProducts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KingdomSectionHeader(
                  title: kTr(context, 'منتجات مقترحة لك', 'Recommended for You'),
                  actionLabel: kTr(context, 'عرض الكل', 'View All'),
                  onActionTap: () => context.push(Routes.categories),
                ),
                KingdomHorizontalProductList(
                  products: homeData.recommendedProducts,
                  onProductTap: (p) => _onProductDetailTap(context, p),
                  onProductCtaTap: (p) => _onProductCtaTap(context, p),
                ),
              ],
            ),
          ),

        // 10. Services strip + WhatsApp support row + footer
        KingdomSupportAndFooterSection(
          onSupportTap: () => WhatsAppHelper.launchSupportChat(),
        ),
      ],
    );
  }

  Future<void> _onBannerTap(
    BuildContext context,
    BannerEntity banner,
    HomeData homeData,
  ) async {
    // 1. Direct match in loaded HomeData offers
    if (banner.offerId != null) {
      final matchedOffer = homeData.offers
          .where((o) => o.id == banner.offerId)
          .firstOrNull;
      if (matchedOffer != null) {
        context.push(Routes.offerDetails, extra: matchedOffer);
        return;
      }
      // Fallback: fetch offer from backend as DynamicBannersWidget did
      try {
        final dio = getIt<Dio>();
        final res = await dio.get('/api/v1/offers/${banner.offerId}');
        final data = res.data['data'] ?? res.data;
        final offer =
            OfferModel.fromJson(data as Map<String, dynamic>).toDomain();
        if (context.mounted) {
          context.push(Routes.offerDetails, extra: offer);
          return;
        }
      } catch (_) {}
    }

    // 2. DeepLink handling (/categories/:id, /products/:id, or external URL)
    final link = banner.deepLink?.trim() ?? '';
    if (link.isNotEmpty) {
      final catMatch = RegExp(r'^/categories/(\d+)$').firstMatch(link);
      if (!context.mounted) return;
      if (catMatch != null) {
        final catId = int.tryParse(catMatch.group(1)!);
        final cat =
            homeData.categories.where((c) => c.id == catId).firstOrNull;
        if (cat != null) {
          context.push(Routes.productsByCategory, extra: cat);
        } else {
          context.push(Routes.categories);
        }
        return;
      }

      final prodMatch = RegExp(r'^/products/(\d+)$').firstMatch(link);
      if (prodMatch != null) {
        final prodId = int.tryParse(prodMatch.group(1)!);
        final allProducts = <Product>[
          ...homeData.featuredProducts,
          ...homeData.bestSellers,
          ...homeData.recommendedProducts,
        ];
        final prod = allProducts.where((p) => p.id == prodId).firstOrNull;
        if (prod != null) {
          _onProductDetailTap(context, prod);
          return;
        }
      }

      if (link.startsWith('http://') || link.startsWith('https://')) {
        await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (context.mounted && homeData.offers.isNotEmpty) {
      context.push(Routes.offerDetails, extra: homeData.offers.first);
    }
  }

  void _onProductDetailTap(BuildContext context, Product product) {
    if (product.isCarcass || product.effectivePortions.isNotEmpty) {
      context.push(Routes.carcassPortions, extra: product);
    } else {
      context.push(Routes.productDetails, extra: product);
    }
  }

  void _onProductCtaTap(BuildContext context, Product product) {
    if (!product.isEffectivelyAvailable) return;

    if (product.hasConfigurableOptions) {
      KingdomProductOptionsSheet.show(
        context: context,
        product: product,
        onConfirmAdd: ({
          required double quantity,
          int? sizeId,
          int? cuttingOptionId,
          List<int>? packagingIds,
          List<int>? excludedPartIds,
        }) {
          _performAddToCart(
            context,
            product: product,
            quantity: quantity,
            sizeId: sizeId,
            cuttingOptionId: cuttingOptionId,
            packagingIds: packagingIds,
            excludedPartIds: excludedPartIds,
          );
        },
        onOpenFullDetails: () => _onProductDetailTap(context, product),
      );
      return;
    }

    _performAddToCart(
      context,
      product: product,
      quantity: 1,
    );
  }

  void _performAddToCart(
    BuildContext context, {
    required Product product,
    required double quantity,
    int? sizeId,
    int? cuttingOptionId,
    List<int>? packagingIds,
    List<int>? excludedPartIds,
  }) {
    bool isAuthenticated = false;
    try {
      isAuthenticated = context.read<AuthCubit>().state is AuthAuthenticated;
    } catch (_) {}

    final cartCubit = _resolveCartCubit(context);
    if (isAuthenticated && cartCubit != null) {
      cartCubit.addToCart(
        productId: product.id,
        quantity: quantity,
        sizeId: sizeId,
        cuttingOptionId: cuttingOptionId,
        packagingIds: packagingIds,
        excludedPartIds: excludedPartIds,
      );
      return;
    }

    setState(() {
      _localCartLineCountOverride = (_localCartLineCountOverride ??
              (context.read<HomeCubit>().state is HomeLoaded
                  ? (context.read<HomeCubit>().state as HomeLoaded)
                          .homeData
                          .userHighlight
                          ?.activeCart
                          ?.lineCount ??
                      0
                  : 0)) +
          1;
    });
    _showKingdomToast(
      context,
      kTr(context, 'تمت الإضافة إلى سلتك', 'Added to your cart'),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final p = KPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: p.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: kText(14, weight: FontWeight.w500, color: p.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeCubit>().fetchHomeData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: p.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(S.of(context).retry_button),
            ),
          ],
        ),
      ),
    );
  }

  // ── Desktop / Web layout preserved ─────────────────────────────────────────

  Widget _buildDesktopContent(
    BuildContext context,
    HomeData? homeData,
    bool isLoading,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1360),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              WebHeroSectionWidget(banners: homeData?.banners ?? []),
              const WebTestimonialsWidget(),
              if (homeData != null && homeData.categories.isNotEmpty)
                WebCategorySectionWidget(categories: homeData.categories),
              const WebFeaturedCollectionsWidget(),
              if (homeData != null && homeData.featuredProducts.isNotEmpty) ...[
                SectionHeaderWidget(
                  title: S.of(context).featured_products,
                  onViewAll: () => context.push(Routes.categories),
                ),
                const SizedBox(height: 16),
                _buildWebProductGrid(homeData.featuredProducts),
                const SizedBox(height: 36),
              ],
              if (homeData != null && homeData.bestSellers.isNotEmpty) ...[
                SectionHeaderWidget(
                  title: S.of(context).best_sellers,
                  onViewAll: () => context.push(Routes.categories),
                ),
                const SizedBox(height: 16),
                _buildWebProductGrid(homeData.bestSellers),
                const SizedBox(height: 36),
              ],
              if (homeData != null &&
                  homeData.recommendedProducts.isNotEmpty) ...[
                SectionHeaderWidget(
                  title: S.of(context).recommended_products,
                  onViewAll: () => context.push(Routes.categories),
                ),
                const SizedBox(height: 16),
                _buildWebProductGrid(homeData.recommendedProducts),
                const SizedBox(height: 36),
              ],
              const WebWhyChooseUsWidget(),
              const WebNewsletterAndFooterWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebProductGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        childAspectRatio: 0.70,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          id: product.id,
          product: product,
          imageUrl: product.imageUrl,
          title: product.title,
          subtitle: product.subtitle,
          price: product.price,
          originalPrice: product.originalPrice,
          tag: product.isOffer ? S.of(context).sale_tag : null,
          onAddToCart: () => _onProductDetailTap(context, product),
          onTap: () => _onProductDetailTap(context, product),
        );
      },
    );
  }
}

class EffectiveHomeData {
  final HomeData data;
  const EffectiveHomeData(this.data);
}
