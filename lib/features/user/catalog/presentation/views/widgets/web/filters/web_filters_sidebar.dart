import 'package:flutter/material.dart';
import '../../../../../domain/entities/category.dart';
import 'categories_filter.dart';
import 'price_range_filter.dart';
import 'cut_filter.dart';

class WebFiltersSidebar extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;
  
  // Filter properties for Price and Cut
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final List<String> cuts;
  final String? selectedCut;
  final ValueChanged<String?> onCutSelected;

  const WebFiltersSidebar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceRangeChanged,
    required this.cuts,
    required this.selectedCut,
    required this.onCutSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.only(right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoriesFilter(
            categories: categories,
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFF5ECE7), height: 1),
          const SizedBox(height: 32),
          PriceRangeFilter(
            minPrice: minPrice,
            maxPrice: maxPrice,
            onChanged: onPriceRangeChanged,
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFF5ECE7), height: 1),
          const SizedBox(height: 32),
          CutFilter(
            cuts: cuts,
            selectedCut: selectedCut,
            onCutSelected: onCutSelected,
          ),
        ],
      ),
    );
  }
}
