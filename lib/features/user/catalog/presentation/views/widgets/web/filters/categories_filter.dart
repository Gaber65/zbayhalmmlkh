import 'package:flutter/material.dart';
import '../../../../../domain/entities/category.dart';

class CategoriesFilter extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;

  const CategoriesFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORIES',
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF544244),
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildCheckboxItem(
          context: context,
          label: 'All Products',
          isSelected: selectedCategory == null,
          onTap: () => onCategorySelected(null),
        ),
        ...categories.map((category) {
          return _buildCheckboxItem(
            context: context,
            label: category.name,
            isSelected: selectedCategory?.id == category.id,
            onTap: () => onCategorySelected(category),
          );
        }),
      ],
    );
  }

  Widget _buildCheckboxItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF1E1B18),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF877274),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
