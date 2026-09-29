import 'package:flutter/material.dart';
import 'package:dhabayih_lmamlaka/core/theme/app_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/widgets/product_card.dart';
import '../manager/search_cubit.dart';
import '../manager/search_state.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchCubit>()..loadInitial(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(AppIcons.arrowLeft, color: AppColors.onSurface),
            onPressed: () => context.pop(),
          ),
          titleSpacing: 0,
          title: Builder(
            builder: (context) {
              return Container(
                margin: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    context.read<SearchCubit>().searchQueryChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: S.of(context).search_hint,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline),
                    prefixIcon: const Icon(AppIcons.search, color: AppColors.outline),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(AppIcons.close, color: AppColors.outline),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchCubit>().clearSearch();
                            },
                          ),
                        IconButton(
                          icon: const Icon(AppIcons.filter, color: AppColors.primary),
                          onPressed: () => _showFilterModal(context),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              );
            }
          ),
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SearchError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is SearchInitial) {
              return _buildInitialView(context, state);
            } else if (state is SearchLoaded) {
              if (state.results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_outlined, size: 64, color: AppColors.outline),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).no_results_for(state.query),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(24.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  final product = state.results[index];
                  return ProductCard(
                    imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : 'https://via.placeholder.com/150',
                    title: product.title,
                    subtitle: product.subtitle,
                    price: product.price,
                    onAddToCart: () {},
                    onTap: () {
                      context.push(Routes.productDetails, extra: {
                        'id': product.id,
                        'title': product.title,
                        'subtitle': product.subtitle,
                        'price': product.price,
                        'imageUrl': product.imageUrl,
                      });
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInitialView(BuildContext context, SearchInitial state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentSearches.isNotEmpty) ...[
            Text(
              S.of(context).recent_searches,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.recentSearches.map((search) => _buildChip(context, search)).toList(),
            ),
            const SizedBox(height: 32),
          ],
          if (state.popularSearches.isNotEmpty) ...[
            Text(
              S.of(context).popular_searches,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.popularSearches.map((search) => _buildChip(context, search, isPopular: true)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, {bool isPopular = false}) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        context.read<SearchCubit>().searchQueryChanged(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPopular ? AppColors.primaryContainer.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? AppColors.primaryContainer : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPopular) ...[
              const Icon(Icons.trending_up, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isPopular ? AppColors.primary : AppColors.onSurface,
                fontWeight: isPopular ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).filters,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).sort_by,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(context, S.of(context).relevance, isSelected: true),
                  _buildFilterChip(context, S.of(context).price_low_to_high),
                  _buildFilterChip(context, S.of(context).price_high_to_low),
                  _buildFilterChip(context, S.of(context).newest_arrivals),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).price_range,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              RangeSlider(
                values: const RangeValues(10, 500),
                min: 0,
                max: 1000,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceContainerHigh,
                onChanged: (values) {},
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).sar_value('10'), style: Theme.of(context).textTheme.bodyMedium),
                  Text(S.of(context).sar_value('500'), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).apply_filters, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isSelected ? Colors.white : AppColors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
