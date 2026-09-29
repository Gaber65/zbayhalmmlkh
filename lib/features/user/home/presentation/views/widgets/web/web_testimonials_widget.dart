import 'package:flutter/material.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';

class WebTestimonialsWidget extends StatelessWidget {
  const WebTestimonialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isNarrow = MediaQuery.sizeOf(context).width < 950;

    final reviews = [
      {
        'quote': isArabic
            ? '"ما شاء الله تبارك الله، الذبائح فاخرة جداً والتقطيع والترتيب يبيض الوجه عند الضيوف. التوصيل وصل بالوقت وكان مبرد وبأعلى جودة."'
            : '"Incredible quality and presentation! The cuts were immaculately arranged and delivered right on time in a refrigerated van. Highly recommended for feasts."',
        'name': isArabic ? 'عبدالله الغامدي' : 'Abdullah Al-Ghamdi',
        'city': isArabic ? 'الرياض' : 'Riyadh',
        'avatar': 'A',
      },
      {
        'quote': isArabic
            ? '"أول مرة أطلب من التطبيق وبكل صراحة أبهرني التغليف الاحترافي (فاكيوم) والنظافة الفائقة اللحم طزاجته عالية وممتاز في الطبخ."'
            : '"First time ordering and I was deeply impressed by the vacuum sealing and extreme cleanliness. The meat was wonderfully fresh and cooked to tender perfection."',
        'name': isArabic ? 'فهد القحطاني' : 'Fahad Al-Qahtani',
        'city': isArabic ? 'الرياض' : 'Riyadh',
        'avatar': 'F',
      },
      {
        'quote': isArabic
            ? '"خدمة العملاء ممتازة وسريعين بالرد. التزمت بالميعاد وجابوا الطلب حسب المواصفات والتقطيع اللي اخترته بدقة. مستمر بالطلب معكم أكيد."'
            : '"Customer support is super helpful and responsive. They adhered exactly to the customized butchery instructions I provided. Definitely my go-to store now!"',
        'name': isArabic ? 'نورة العتيبي' : 'Noura Al-Otaibi',
        'city': isArabic ? 'الدرعية' : 'Diriyah',
        'avatar': 'N',
      },
    ];

    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                isArabic ? 'آراء وتجارب عملائنا' : 'What Our Customers Say',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        if (isNarrow)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: reviews.map((rev) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _buildReviewCard(theme, colorScheme, rev, isArabic),
              );
            }).toList(),
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: reviews.map((rev) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: _buildReviewCard(theme, colorScheme, rev, isArabic),
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildReviewCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, Object> rev,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(26.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stars
              Row(
                children: List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.tertiary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Quote
              Text(
                rev['quote'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Reviewer Identity
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  rev['avatar'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            rev['name'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isArabic
                          ? 'عميل موثق • ${rev["city"]}'
                          : 'Verified Buyer • ${rev["city"]}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
