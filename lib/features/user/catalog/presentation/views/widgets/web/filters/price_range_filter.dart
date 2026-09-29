import 'package:flutter/material.dart';

class PriceRangeFilter extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onChanged;

  const PriceRangeFilter({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.onChanged,
  });

  @override
  State<PriceRangeFilter> createState() => _PriceRangeFilterState();
}

class _PriceRangeFilterState extends State<PriceRangeFilter> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    _currentRangeValues = RangeValues(widget.minPrice, widget.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRICE RANGE',
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF544244),
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: const Color(0xFFE1DFDB),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: RangeSlider(
            values: _currentRangeValues,
            min: widget.minPrice,
            max: widget.maxPrice,
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
              widget.onChanged(values);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_currentRangeValues.start.round()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF544244),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Text(
              '\$${_currentRangeValues.end.round()}+',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF544244),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
