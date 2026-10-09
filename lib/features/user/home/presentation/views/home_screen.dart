import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:dhabayih_lmamlaka/core/theme/app_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhabayih_lmamlaka/features/user/offers/domain/entities/offer_entity.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../../core/routes/routes.dart';
import '../../../../../../core/widgets/category_chip.dart';
import '../../../../../../core/widgets/product_card.dart';
import '../../../../../../core/widgets/responsive_layout.dart';
import '../../../../../../generated/l10n.dart';
import '../../domain/entities/home_data.dart';
import '../manager/home_cubit.dart';
import '../manager/home_state.dart';
import 'widgets/dynamic_banners_widget.dart';
import 'widgets/jabin_highlight_widget.dart';
import 'widgets/section_header_widget.dart';
import 'widgets/user_highlight_widget.dart';
import 'widgets/trust_badges_widget.dart';
import 'widgets/web/web_navbar_widget.dart';
import 'widgets/web/web_hero_section_widget.dart';
import 'widgets/web/web_category_section_widget.dart';
import 'widgets/web/web_featured_collections_widget.dart';
import 'widgets/web/web_why_choose_us_widget.dart';
import 'widgets/web/web_testimonials_widget.dart';
import 'widgets/web/web_newsletter_and_footer_widget.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../address/presentation/views/widgets/address_selection_bottom_sheet.dart';
import '../../../address/presentation/manager/address_cubit.dart';
import '../../../address/domain/services/fulfillment_service.dart';
import 'widgets/user_notifications_sheet.dart';
import '../../../../shared/auth/domain/repositories/auth_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSavedFulfillment();
    _registerFcmIfAuthenticated();
  }

  void _registerFcmIfAuthenticated() {
    try {
      FirebaseMessaging.instance.subscribeToTopic('all');
    } catch (e) {
      debugPrint('Failed to subscribe to topic: $e');
    }

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
    final locationText = await FulfillmentService.getDisplayLocation();
    if (locationText != null && locationText.isNotEmpty && mounted) {
      setState(() {
        _selectedLocationOverride = locationText;
      });
    }
  }

  void _onRefresh(BuildContext context) async {
    await context.read<HomeCubit>().fetchHomeData();
    _refreshController.refreshCompleted();
  }

  void _openAddressSelectionBottomSheet(BuildContext context) async {
    final result = await AddressSelectionBottomSheet.show(
      context,
      initialLocation: _selectedLocationOverride,
      cubit: getIt<AddressCubit>()..loadAddresses(),
    );

    if (result != null && mounted) {
      final text = result['displayText'] as String?;
      if (text != null && text.isNotEmpty) {
        setState(() {
          _selectedLocationOverride = text;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocProvider(
        create: (context) => getIt<HomeCubit>()..fetchHomeData(),
        child: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded || state is HomeError) {
              _refreshController.refreshCompleted();
              _refreshController.loadComplete();
            }
          },
          builder: (context, state) {
            bool isLoading = state is HomeLoading || state is HomeInitial;
            HomeData? homeData;

            if (state is HomeLoaded) {
              homeData = state.homeData;
            }

            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: !kIsWeb,
              header: WaterDropMaterialHeader(
                backgroundColor: colorScheme.primary,
                color: colorScheme.onPrimary,
              ),
              onRefresh: () => _onRefresh(context),
              child: state is HomeError
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildErrorState(context, state.message),
                        ),
                      ],
                    )
                  : Skeletonizer(
                      enabled: isLoading,
                      child: CustomScrollView(
                        physics: kIsWeb
                            ? const AlwaysScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        slivers: [
                          !ResponsiveLayout.isMobile(context)
                              ? WebNavbarWidget(
                                  userHighlight: homeData?.userHighlight,
                                  deliveryLocation:
                                      _selectedLocationOverride ??
                                      homeData?.deliveryLocation,
                                  onLocationTap: () =>
                                      _openAddressSelectionBottomSheet(context),
                                )
                              : _buildAppBar(context, homeData),
                          if (homeData != null || isLoading)
                            SliverToBoxAdapter(
                              child: ResponsiveLayout(
                                mobile: _buildMobileContent(
                                  context,
                                  homeData,
                                  isLoading,
                                ),
                                tablet: _buildDesktopContent(
                                  context,
                                  homeData,
                                  isLoading,
                                ),
                                desktop: _buildDesktopContent(
                                  context,
                                  homeData,
                                  isLoading,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeCubit>().fetchHomeData(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(S.of(context).retry_button),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, HomeData? homeData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: UserHighlightWidget(
        userHighlight: homeData?.userHighlight,
        deliveryLocation:
            _selectedLocationOverride ?? homeData?.deliveryLocation,
        onLocationTap: () => _openAddressSelectionBottomSheet(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_outline_rounded),
          tooltip: 'المفضلة',
          onPressed: () => context.push(Routes.favorites),
        ),
        IconButton(
          icon: const Icon(AppIcons.notification),
          tooltip: S.of(context).notifications,
          onPressed: () => UserNotificationsSheet.show(context),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileContent(
    BuildContext context,
    HomeData? homeData,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildWelcomeHeaderCard(context, homeData?.userHighlight),
        const SizedBox(height: 16),
        if (homeData != null && homeData.jabinHighlight.isNotEmpty) ...[
          JabinHighlightWidget(highlights: homeData.jabinHighlight),
          const SizedBox(height: 16),
        ],
        if (homeData != null && homeData.banners.isNotEmpty)
          DynamicBannersWidget(banners: homeData.banners),
        const TrustBadgesWidget(),

        if (homeData != null && homeData.offers.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionHeaderWidget(
            title: Localizations.localeOf(context).languageCode == 'ar'
                ? 'العروض الترويجية'
                : 'Special Offers',
            onViewAll: () {
              context.push(Routes.offerDetails, extra: homeData.offers.first);
            },
          ),
          const SizedBox(height: 8),
          _buildOffersSection(context, homeData.offers),
        ],

        const SizedBox(height: 20),
        if (homeData != null && homeData.categories.isNotEmpty) ...[
          SectionHeaderWidget(
            title: S.of(context).categories_title,
            onViewAll: () => context.push(Routes.categories),
          ),
          const SizedBox(height: 8),
          _buildCategories(homeData.categories),
        ],

        const SizedBox(height: 20),
        if (homeData != null && homeData.featuredProducts.isNotEmpty) ...[
          SectionHeaderWidget(
            title: S.of(context).featured_products,
            onViewAll: () => context.push(Routes.categories),
          ),
          const SizedBox(height: 8),
          _buildProductHorizontalList(homeData.featuredProducts),
        ],

        const SizedBox(height: 20),
        if (homeData != null && homeData.bestSellers.isNotEmpty) ...[
          SectionHeaderWidget(
            title: S.of(context).best_sellers,
            onViewAll: () => context.push(Routes.categories),
          ),
          const SizedBox(height: 8),
          _buildProductHorizontalList(homeData.bestSellers),
        ],

        const SizedBox(height: 20),
        if (homeData != null && homeData.recommendedProducts.isNotEmpty) ...[
          SectionHeaderWidget(
            title: S.of(context).recommended_products,
            onViewAll: () => context.push(Routes.categories),
          ),
          const SizedBox(height: 8),
          _buildProductHorizontalList(homeData.recommendedProducts),
        ],
        const SizedBox(height: 110),
      ],
    );
  }

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
              // 1. Hero Section Banner & CTA
              WebHeroSectionWidget(banners: homeData?.banners ?? []),

              // 2. Browse by Category Circular Section
              if (homeData != null && homeData.categories.isNotEmpty)
                WebCategorySectionWidget(categories: homeData.categories),

              // 3. Featured Collections & Bento Promos
              const WebFeaturedCollectionsWidget(),

              // 4. Trending & Featured Products Section
              if (homeData != null && homeData.featuredProducts.isNotEmpty) ...[
                SectionHeaderWidget(
                  title: S.of(context).featured_products,
                  onViewAll: () => context.push(Routes.categories),
                ),
                const SizedBox(height: 16),
                _buildWebProductGrid(homeData.featuredProducts),
                const SizedBox(height: 36),
              ],

              // 5. Best Sellers Section
              if (homeData != null && homeData.bestSellers.isNotEmpty) ...[
                SectionHeaderWidget(
                  title: S.of(context).best_sellers,
                  onViewAll: () => context.push(Routes.categories),
                ),
                const SizedBox(height: 16),
                _buildWebProductGrid(homeData.bestSellers),
                const SizedBox(height: 36),
              ],

              // 6. Recommended Products Section
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

              // 7. Why Choose Us Dark Features Section
              const WebWhyChooseUsWidget(),

              // 8. Customer Testimonials Section
              const WebTestimonialsWidget(),

              // 9. Newsletter Subscription & Comprehensive Footer
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
          onAddToCart: () {
            context.push(Routes.productDetails, extra: product);
          },
          onTap: () {
            context.push(Routes.productDetails, extra: product);
          },
        );
      },
    );
  }

  Widget _buildWelcomeHeaderCard(
    BuildContext context,
    UserHighlight? userHighlight,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userName = userHighlight?.name.isNotEmpty == true
        ? userHighlight!.name
        : S.of(context).guest_user;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: S.of(context).hello_label,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                TextSpan(
                  text: '$userName 👋',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).home_intro_subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          // Integrated Pill Search Bar
          Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => context.push(Routes.search),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.search,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        S.of(context).search_placeholder,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.filter,
                        size: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<Category> categories) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: CategoryChip(
              label: category.name,
              imageUrl: category.imageUrl.isNotEmpty ? category.imageUrl : "",
              onTap: () {
                context.push(Routes.productsByCategory, extra: category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductHorizontalList(List<Product> products) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: SizedBox(
              width: 165,
              child: ProductCard(
                id: product.id,
                product: product,
                imageUrl: product.imageUrl,
                title: product.title,
                subtitle: product.subtitle,
                price: product.price,
                originalPrice: product.originalPrice,
                tag: product.isOffer ? S.of(context).sale_tag : null,
                onAddToCart: () {
                  context.push(Routes.productDetails, extra: product);
                },
                onTap: () {
                  context.push(Routes.productDetails, extra: product);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context, List<OfferEntity> offers) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizedBox(
      height: 155,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: GestureDetector(
              onTap: () {
                context.push(Routes.offerDetails, extra: offer);
              },
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Background image or gradient
                    if (offer.bannerImageUrl != null && offer.bannerImageUrl!.isNotEmpty)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: offer.bannerImageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _buildOfferCardGradient(),
                        ),
                      )
                    else
                      Positioned.fill(child: _buildOfferCardGradient()),

                    // Dark overlay for legibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          offer.badgeText.isNotEmpty ? offer.badgeText : 'عرض خاص',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            offer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (offer.subtitle != null && offer.subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              offer.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${offer.products.length} منتجات مشمولة',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferCardGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C1810), Color(0xFF8B2500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.local_offer_outlined, size: 48, color: Colors.white12),
      ),
    );
  }
}

