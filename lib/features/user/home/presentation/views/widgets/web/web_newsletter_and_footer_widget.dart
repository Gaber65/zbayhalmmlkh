import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/core/theme/app_icons.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';

class WebNewsletterAndFooterWidget extends StatefulWidget {
  const WebNewsletterAndFooterWidget({super.key});

  @override
  State<WebNewsletterAndFooterWidget> createState() =>
      _WebNewsletterAndFooterWidgetState();
}

class _WebNewsletterAndFooterWidgetState
    extends State<WebNewsletterAndFooterWidget> {
  final TextEditingController _emailController = TextEditingController();

  void _onSubscribe(BuildContext context, bool isArabic) {
    if (_emailController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'شكراً لك! تم الاشتراك في النشرة البريدية بنجاح.'
                : 'Thank you! You have successfully subscribed to our newsletter.',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
      _emailController.clear();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: [
        // ── Newsletter Subscription Section ─────────────────────────────────────
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                AppIcons.message,
                size: 44,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'انضم إلى نشرتنا البريدية للعروض الخاصة'
                    : 'Join Our VIP Newsletter',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'احصل على تحديثات فورية حول خصومات المواسم، عروض الولائم والوصول الحصري للأصناف الفاخرة.'
                    : 'Receive updates on seasonal discounts, holiday feast packages, and exclusive fresh cuts arrivals.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        AppIcons.email,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: isArabic
                                ? 'أدخل عنوان بريدك الإلكتروني...'
                                : 'Enter your email address...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _onSubscribe(context, isArabic),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          isArabic ? 'اشتراك' : 'Subscribe',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        const SizedBox(height: 30),

        // ── Comprehensive Website Footer ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Col 1: Brand Info
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 20,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isArabic ? 'ذبائح المملكة' : 'DHABAYIH LMAMLAKA',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic
                          ? 'المنصة الرائدة لطلب أجود الذبائح واللحوم الطازجة في المملكة. نقدم لكم تجربة تسوق فاخرة مع تقطيع حسب الطلب وتوصيل في أسطول مبرد.'
                          : 'The premier destination for luxury livestock & custom fresh meat cutting in Saudi Arabia. Assured hygiene and cold climate express transport.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSocialIcon(context, AppIcons.globe),
                        const SizedBox(width: 12),
                        _buildSocialIcon(context, AppIcons.camera),
                        const SizedBox(width: 12),
                        _buildSocialIcon(context, AppIcons.chat),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 48),

              // Col 2: Quick Links
              Expanded(
                flex: 2,
                child: _buildFooterColumn(
                  context,
                  title: isArabic ? 'روابط سريعة' : 'Quick Links',
                  links: [
                    _FooterLink(
                      title: S.of(context).home,
                      onTap: () => context.go(Routes.home),
                    ),
                    _FooterLink(
                      title: S.of(context).categories_title,
                      onTap: () => context.go(Routes.categories),
                    ),
                    _FooterLink(
                      title: S.of(context).todays_offers,
                      onTap: () => context.go(Routes.categories),
                    ),
                    _FooterLink(
                      title: S.of(context).best_sellers,
                      onTap: () => context.go(Routes.categories),
                    ),
                  ],
                ),
              ),

              // Col 3: Customer Care
              Expanded(
                flex: 2,
                child: _buildFooterColumn(
                  context,
                  title: isArabic ? 'خدمة العملاء' : 'Customer Care',
                  links: [
                    _FooterLink(
                      title: S.of(context).profile,
                      onTap: () => context.go(Routes.profile),
                    ),
                    _FooterLink(
                      title: S.of(context).my_cart,
                      onTap: () => context.go(Routes.cart),
                    ),
                    _FooterLink(
                      title: S.of(context).saved_addresses,
                      onTap: () => context.push(Routes.addresses),
                    ),
                    _FooterLink(
                      title: S.of(context).order_history,
                      onTap: () => context.go(Routes.orders),
                    ),
                  ],
                ),
              ),

              // Col 4: Contact Info
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'تواصل معنا' : 'Contact Us',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      context,
                      icon: Icons.location_on_outlined,
                      text: isArabic
                          ? 'الرياض، المملكة العربية السعودية'
                          : 'Riyadh, Kingdom of Saudi Arabia',
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      context,
                      icon: Icons.phone_outlined,
                      text: '+966 50 000 0000',
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      context,
                      icon: Icons.access_time_outlined,
                      text: isArabic
                          ? 'يومياً من ٨ صباحاً حتى ١١ مساءً'
                          : 'Daily: 8:00 AM - 11:00 PM',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        const SizedBox(height: 16),

        // Bottom Copyright Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic
                  ? '© ٢٠٢٦ ذبائح المملكة. جميع الحقوق محفوظة.'
                  : '© 2026 Dhabayih Lmamlaka. All rights reserved.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              S.of(context).crafted_by,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildFooterColumn(
    BuildContext context, {
    required String title,
    required List<_FooterLink> links,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: l.onTap,
              child: Text(
                l.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink {
  final String title;
  final VoidCallback onTap;
  const _FooterLink({required this.title, required this.onTap});
}
