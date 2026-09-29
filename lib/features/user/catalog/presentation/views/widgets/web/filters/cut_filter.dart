import 'package:flutter/material.dart';

class CutFilter extends StatelessWidget {
  final List<String> cuts;
  final String? selectedCut;
  final ValueChanged<String?> onCutSelected;

  const CutFilter({
    super.key,
    required this.cuts,
    required this.selectedCut,
    required this.onCutSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUT',
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF544244),
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cuts.map((cut) {
            final isSelected = selectedCut == cut;
            return InkWell(
              onTap: () => onCutSelected(isSelected ? null : cut),
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF002C17).withValues(alpha: 0.1) : const Color(0xFFF5ECE7),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  cut,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected ? const Color(0xFF002C17) : const Color(0xFF544244),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
