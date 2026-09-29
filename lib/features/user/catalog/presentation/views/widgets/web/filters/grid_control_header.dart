import 'package:flutter/material.dart';

class GridControlHeader extends StatelessWidget {
  final String? selectedSort;
  final ValueChanged<String?> onSortChanged;
  final ValueChanged<String>? onSearchChanged;

  const GridControlHeader({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF2ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF877274),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF877274)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Sort Dropdown
          Row(
            children: [
              Text(
                'Sort by:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF544244),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5ECE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDAC0C2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSort,
                    hint: Text(
                      'Recommended',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1E1B18),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF544244)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1E1B18),
                    ),
                    onChanged: onSortChanged,
                    items: const [
                      DropdownMenuItem(value: 'Recommended', child: Text('Recommended')),
                      DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                      DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
                      DropdownMenuItem(value: 'Newest', child: Text('Newest')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
