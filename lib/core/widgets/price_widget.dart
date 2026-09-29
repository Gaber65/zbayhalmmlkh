import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Official Saudi Riyal SVG icon widget.
class SaudiRiyalIcon extends StatelessWidget {
  final double? size;
  final double? width;
  final double? height;
  final Color? color;

  const SaudiRiyalIcon({
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
    final w = width ?? size ?? 14.0;
    final h = height ?? size ?? 16.0;

    return SvgPicture.asset(
      'assets/images/saudi_riyal.svg',
      width: w,
      height: h,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}

/// Helper to embed the Saudi Riyal icon in [Text.rich] or [RichText].
InlineSpan saudiRiyalSpan({
  double size = 13.0,
  Color? color,
  EdgeInsetsGeometry padding = const EdgeInsetsDirectional.only(start: 3.0),
}) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Padding(
      padding: padding,
      child: SaudiRiyalIcon(
        size: size,
        color: color,
      ),
    ),
  );
}

/// Standardized price widget that shows numeric price and Saudi Riyal icon.
class PriceWidget extends StatelessWidget {
  final num price;
  final double? originalPrice;
  final TextStyle? style;
  final TextStyle? originalStyle;
  final Color? color;
  final double? iconSize;
  final bool showOriginal;
  final String? prefix;
  final String? suffix;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  const PriceWidget({
    super.key,
    required this.price,
    this.originalPrice,
    this.style,
    this.originalStyle,
    this.color,
    this.iconSize,
    this.showOriginal = true,
    this.prefix,
    this.suffix,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  static String format(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? style?.color ?? theme.colorScheme.primary;
    final effectiveStyle = (style ?? theme.textTheme.titleMedium)?.copyWith(
      color: effectiveColor,
      fontWeight: style?.fontWeight ?? FontWeight.bold,
    );
    final calculatedIconSize = iconSize ?? (effectiveStyle?.fontSize != null ? effectiveStyle!.fontSize! * 0.85 : 14.0);

    final hasDiscount = showOriginal && originalPrice != null && originalPrice! > price;

    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (prefix != null) ...[
          Text(prefix!, style: effectiveStyle),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            format(price),
            style: effectiveStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 3),
        SaudiRiyalIcon(
          size: calculatedIconSize,
          color: effectiveColor,
        ),
        if (suffix != null) ...[
          const SizedBox(width: 4),
          Text(suffix!, style: effectiveStyle),
        ],
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              format(originalPrice!),
              style: (originalStyle ?? theme.textTheme.bodySmall)?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: originalStyle?.color ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: originalStyle?.fontSize ?? ((effectiveStyle?.fontSize ?? 14) * 0.75),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 2),
          SaudiRiyalIcon(
            size: calculatedIconSize * 0.75,
            color: originalStyle?.color ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ],
      ],
    );
  }
}
