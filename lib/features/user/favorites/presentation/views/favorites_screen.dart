import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/widgets/product_card.dart';
import 'package:dhabayih_lmamlaka/core/widgets/responsive_layout.dart';
import '../manager/favorites_cubit.dart';
import '../manager/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          isArabic ? 'المفضلة' : 'My Favorites',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: cs.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          if (state is FavoritesLoaded && state.feedbackMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.feedbackMessage!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 54, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.read<FavoritesCubit>().loadFavorites(),
                      child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final favorites = state is FavoritesLoaded ? state.favorites : [];

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 50,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isArabic ? 'قائمة المفضلة فارغة' : 'Your Wishlist is Empty',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isArabic
                          ? 'لم تقم بحفظ أي ذبائح أو منتجات في المفضلة بعد. تصفح تشكيلة الذبائح واختر ما يناسبك!'
                          : 'You have not added any products to your favorites yet. Explore our selections and save your favorite items!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () => context.go(Routes.categories),
                      icon: const Icon(Icons.explore_rounded, size: 20),
                      label: Text(
                        isArabic ? 'تصفح الأقسام والمنتجات' : 'Browse Categories',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final isMobile = ResponsiveLayout.isMobile(context);

          return RefreshIndicator(
            onRefresh: () => context.read<FavoritesCubit>().loadFavorites(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? '${favorites.length} منتجات محفوظة' : '${favorites.length} Saved items',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final fav = favorites[index];
                        final prod = fav.toProduct();
                        return ProductCard(
                          id: fav.id,
                          product: prod,
                          imageUrl: fav.imageUrl,
                          title: fav.title,
                          subtitle: fav.subtitle,
                          price: fav.price,
                          originalPrice: fav.originalPrice,
                          tag: fav.discountTag,
                          isFavorite: true,
                          onFavoriteToggle: () {
                            context.read<FavoritesCubit>().removeFavorite(fav.id);
                          },
                          onAddToCart: () {
                            context.push(Routes.productDetails, extra: prod);
                          },
                          onTap: () {
                            context.push(Routes.productDetails, extra: prod);
                          },
                        );
                      },
                      childCount: favorites.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }
}
