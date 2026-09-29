import 'package:flutter/material.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';

class WebWhyChooseUsWidget extends StatelessWidget {
  const WebWhyChooseUsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isNarrow = MediaQuery.sizeOf(context).width < 900;

    final features = [
      {
        'icon': Icons.verified_outlined,
        'title': isArabic ? 'جودة طازجة ומضمونة' : 'Verified Fresh Quality',
        'desc': isArabic
            ? 'ذبائح مختارة بعناية من أفضل المزارع مع فحوصات طبية وبيطرية دقيقة.'
            : 'Carefully selected livestock from top pastures with rigorous veterinary inspections.',
      },
      {
        'icon': Icons.ac_unit_rounded,
        'title': isArabic ? 'توصيل مبرد وسريع' : 'Express Cold Transport',
        'desc': isArabic
            ? 'أسطول سيارات مبردة لضمان وصول طلبك بدرجة حرارة مثالية وفي أسرع وقت.'
            : 'Specialized climate-controlled fleet ensuring meat arrives fresh and at safe temperatures.',
      },
      {
        'icon': Icons.clean_hands_outlined,
        'title': isArabic ? '١٠٠٪ حلال وآمن' : '100% Halal & Hygienic',
        'desc': isArabic
            ? 'ذبح شرعي معتمد وأعلى معايير التعقيم والسلامة الغذائية أثناء التقطيع والتغليف.'
            : 'Certified Sharia-compliant butchery with highest sterilization and vacuum safety protocols.',
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': isArabic ? 'دعم متواصل ٢٤/٧' : '24/7 Dedicated Support',
        'desc': isArabic
            ? 'فريق خدمة عملاء مكرس لخدمتك والإجابة على استفساراتك ومتابعة طلباتك في أي وقت.'
            : 'Responsive customer care team available around the clock to assist with your custom orders.',
      },
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 24.0 : 48.0,
        vertical: isNarrow ? 40.0 : 56.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161619),
            Color(0xFF221517),
            Color(0xFF1B1617),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isArabic ? 'لماذا تختار ذبائح المملكة؟' : 'Why Choose Dhabayih Lmamlaka?',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: isNarrow ? 24 : 30,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'نحن نلتزم بتقديم تجربة استثنائية تجمع بين الأصالة وأعلى معايير الجودة الفاخرة.'
                : 'Committed to delivering an unrivaled meat dining experience combining authenticity & premium luxury.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          if (isNarrow)
            Column(
              children: features.map((feat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: _buildFeatureItem(theme, colorScheme, feat),
                );
              }).toList(),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feat) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildFeatureItem(theme, colorScheme, feat),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, ColorScheme colorScheme, Map<String, Object> feat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            feat['icon'] as IconData,
            size: 32,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          feat['title'] as String,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          feat['desc'] as String,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
            height: 1.5,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
