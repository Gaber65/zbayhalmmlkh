import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  int _selectedTab = 0; // 0: Privacy, 1: Terms, 2: FAQ
  int? _expandedFaqIndex = 0;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'ما هي شروط استرجاع أو استبدال الذبيحة؟',
      'a':
          'طبقاً للائحة سلامة الأغذية وهيئة الغذاء والدواء، لا يقبل استرجاع اللحوم الطازجة سريعة التلف بعد التقطيع والتسليم إلا في حال وجود عيب صحي بيطري مثبت عند الاستلام أو عدم مطابقة جوهرية للصنف، مع اشتراط الإبلاغ خلال ساعتين كحد أقصى وبقاء اللحم مبرداً.',
    },
    {
      'q': 'كيف تضمن المنصة ذبحاً حلالاً ومطابقاً للشريعة؟',
      'a':
          'تذبح جميع المواشي حصرياً داخل مسالخ الأمانة الرسمية المعتمدة بأيدي قصابين مسلمين مؤهلين مع التسمية واستقبال القبلة، وبإشراف بيطري كامل قبل الذبح وبعده.',
    },
    {
      'q': 'هل يتم حفظ وتخزين بيانات بطاقاتي البنكية؟',
      'a':
          'لا يتم حفظ أي بيانات بنكية أو أرقام بطاقات إطلاقاً. المعاملات تتم عبر بوابات مشفرة مرخصة من البنك المركزي السعودي (ساما) ومتوافقة مع أعلى معايير الأمان العالمية (PCI-DSS).',
    },
    {
      'q': 'ما هي نسبة تفاوت الوزن المقبولة في الذبيحة؟',
      'a':
          'الأوزان المعروضة هي أوزان تقريبية صافية بعد الذبح والسلخ والتجويف. نسبة التفاوت الطبيعية الحيوية تتراوح بين ±5% إلى ±8%، ونلتزم دائماً بانتقاء أفضل وزن لصالح العميل.',
    },
  ];

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/966500000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall() async {
    final uri = Uri.parse('tel:920000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.white : AppColors.brandDark,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'الخصوصية والشروط والأحكام',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.brandDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'تواصل مع الدعم',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 20, color: Color(0xFF25D366)),
            ),
            onPressed: _launchWhatsApp,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _buildBottomContactBar(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Royal Hero Banner Card
            _buildRoyalHeroCard(),
            const SizedBox(height: 16),

            // 2. 4 System Trust Badges Strip
            _buildTrustBadgesStrip(isDark),
            const SizedBox(height: 20),

            // 3. Custom Tab Pills Switcher
            _buildTabPillsSwitcher(isDark),
            const SizedBox(height: 20),

            // 4. Tab Content
            if (_selectedTab == 0) ..._buildPrivacyContent(isDark),
            if (_selectedTab == 1) ..._buildTermsContent(isDark),
            if (_selectedTab == 2) ..._buildFaqContent(isDark),

            const SizedBox(height: 24),

            // 5. Official Accreditation & Legal Notice Footer
            _buildOfficialAccreditationCard(isDark),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Royal Hero Banner with Kingdom Gradient & Gold Badge
  Widget _buildRoyalHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF380004), // Deep Brand Black
            Color(0xFF8B1D24), // Brand Dark Red
            Color(0xFF5C0B11),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B1D24).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.goldLight, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'وثيقة تنظيمية معتمدة 2026',
                      style: GoogleFonts.cairo(
                        color: AppColors.goldLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.shield_outlined, color: Colors.white38, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ميثاق الخصوصية والاشتراطات الصحية لذبائح المملكة',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'نلتزم بحماية بياناتك الشخصية وضمان ذبح حلال 100% بإشراف بيطري وتوصيل مبرد وفق اللوائح السعودية.',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMiniHeroBadge('س.ت: 1010000000'),
              const SizedBox(width: 8),
              _buildMiniHeroBadge('الرقم الضريبي: 300000000000003'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: Colors.white60,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 4 System Trust Badges Strip
  Widget _buildTrustBadgesStrip(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildTrustBadgeItem(
            icon: Icons.done_all_rounded,
            title: 'ذبح حلال 100%',
            subtitle: 'مسالخ معتمدة',
            color: const Color(0xFF16A34A),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTrustBadgeItem(
            icon: Icons.ac_unit_rounded,
            title: 'سلسلة تبريد 4°C',
            subtitle: 'سيارات مجهزة',
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTrustBadgeItem(
            icon: Icons.lock_outline_rounded,
            title: 'أمان بنكي PCI',
            subtitle: 'تشفير ساما',
            color: AppColors.gold,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadgeItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 9,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Pill Switcher
  Widget _buildTabPillsSwitcher(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildPillTab(index: 0, title: 'الخصوصية والأمان', icon: Icons.lock_rounded),
          _buildPillTab(index: 1, title: 'شروط الطلب والذبح', icon: Icons.description_rounded),
          _buildPillTab(index: 2, title: 'الأسئلة الشائعة', icon: Icons.quiz_rounded),
        ],
      ),
    );
  }

  Widget _buildPillTab({required int index, required String title, required IconData icon}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 0: Privacy Content
  List<Widget> _buildPrivacyContent(bool isDark) {
    return [
      _buildSectionCard(
        number: '1',
        title: 'البيانات التي نجمعها لخدمتك',
        bullets: [
          'الاسم الكامل ورقم الجوال للتأكيد وإرسال كود التحقق (OTP).',
          'الموقع الجغرافي (GPS) والعنوان الدقيق لتوجيه سيارة التبريد إلى موقعك.',
          'تفضيلات تقطيع وتغليف الذبيحة والملاحظات المخصصة للقصاب.',
          'سجل الطلبات، فواتير الشراء الضريبية، ورصيد نقاط الولاء المكتسبة.',
        ],
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _buildSectionCard(
        number: '2',
        title: 'أمان وتشفير المعاملات المالية (PCI-DSS)',
        bullets: [
          'جميع عمليات الدفع (مدى، Apple Pay، فيزا، ماستركارد) تتم عبر بوابات مشفرة مرخصة رسمياً من البنك المركزي السعودي.',
          'نحن لا نخزن أرقام بطاقاتك الائتمانية أو رموز التحقق السرية (CVV) على خوادمنا نهائياً.',
        ],
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _buildSectionCard(
        number: '3',
        title: 'حظر بيع أو تأجير البيانات للغير',
        bullets: [
          'نتعهد تعهداً قاطعاً بعدم بيع أو مشاركة بياناتك الشخصية مع أي شركات إعلانية أو جهات خارجية.',
          'تتم مشاركة بيانات العنوان فقط مع مندوب التوصيل المعتمد لغرض تسليم طلبك حصراً.',
        ],
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _buildSectionCard(
        number: '4',
        title: 'حقوق المستخدم وحذف الحساب',
        bullets: [
          'يحق لك تعديل بياناتك أو عناوين التوصيل في أي وقت من شاشة الملف الشخصي.',
          'يمكنك طلب حذف حسابك وسجلاتك نهائياً بالتواصل المباشر مع فريق الدعم الفني.',
        ],
        isDark: isDark,
      ),
    ];
  }

  // Tab 1: Terms & Slaughter Standards
  List<Widget> _buildTermsContent(bool isDark) {
    return [
      _buildSectionCard(
        number: '1',
        title: 'الاشتراطات البيطرية والذبح الحلال',
        bullets: [
          'تذبح الذبائح يومياً في مسالخ الأمانة البلدية المرخصة وتحت إشراف بيطري كامل قبل وبعد الذبح.',
          'الذبح يتم وفق الشريعة الإسلامية بأيدي قصابين مسلمين مع النزف التام والتجويف الصحي.',
        ],
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      // Weight Specs Table Card
      _buildWeightTableCard(isDark),
      const SizedBox(height: 12),
      _buildSectionCard(
        number: '3',
        title: 'سياسة الاسترجاع والإلغاء (هيئة الغذاء والدواء)',
        bullets: [
          'اللحوم منتجات طازجة سريعة التلف مجهزة خصيصاً للعميل، ولذا لا يمكن إلغاء الطلب بعد دخوله مرحلة الذبح والتقطيع.',
          'يقبل الاستبدال أو التعويض فقط في حال وجود عيب صحي بيطري عند التسليم أو عدم مطابقة الصنف المطلوب.',
          'يجب إبلاغ خدمة العملاء خلال ساعتين كحد أقصى من الاستلام مع بقاء الذبيحة مبردة.',
        ],
        badgeColor: const Color(0xFFDC2626),
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _buildSectionCard(
        number: '4',
        title: 'شروط التوصيل والاستلام في سيارات التبريد',
        bullets: [
          'تنقل اللحوم في سيارات مجهزة بنظام تبريد حراري (درجة حرارة 4°C).',
          'يلتزم العميل بالتواجد في الموقع لاستلام الذبيحة فور وصول المندوب للحفاظ على جودتها.',
        ],
        isDark: isDark,
      ),
    ];
  }

  // Tab 2: FAQ Accordion
  List<Widget> _buildFaqContent(bool isDark) {
    return [
      ..._faqs.asMap().entries.map((entry) {
        final idx = entry.key;
        final faq = entry.value;
        final isExpanded = _expandedFaqIndex == idx;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  faq['q']!,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: isExpanded ? AppColors.primary : Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    _expandedFaqIndex = isExpanded ? null : idx;
                  });
                },
              ),
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  alignment: Alignment.centerRight,
                  child: Text(
                    faq['a']!,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    ];
  }

  // Weight Reference Table Card
  Widget _buildWeightTableCard(bool isDark) {
    final rows = [
      {'name': 'خروف نعيمي بلدي', 'portion': 'كامل كبير', 'weight': '14 - 17 كجم', 'var': '± 5%'},
      {'name': 'خروف حري طازج', 'portion': 'كامل وسط', 'weight': '12 - 15 كجم', 'var': '± 6%'},
      {'name': 'تيس عارضي بلدي', 'portion': 'كامل صغير', 'weight': '9 - 12 كجم', 'var': '± 6%'},
      {'name': 'نصف ذبيحة', 'portion': 'نصف مقسوم', 'weight': '50% من الصافي', 'var': '± 5%'},
      {'name': 'ربع ذبيحة', 'portion': 'كتف أو فخذ', 'weight': '25% من الصافي', 'var': '± 5%'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '2',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'جدول الأوزان التقريبية والتفاوت المقبول',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.2),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  _buildTableCell('الصنف', isHeader: true, isDark: isDark),
                  _buildTableCell('الوزن التقريبي', isHeader: true, isDark: isDark),
                  _buildTableCell('التفاوت', isHeader: true, isDark: isDark),
                ],
              ),
              ...rows.map(
                (r) => TableRow(
                  children: [
                    _buildTableCell(r['name']!, isDark: isDark),
                    _buildTableCell(r['weight']!, isDark: isDark, isHighlight: true),
                    _buildTableCell(r['var']!, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isHighlight = false, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: isHeader || isHighlight ? FontWeight.bold : FontWeight.normal,
          color: isHighlight
              ? AppColors.primary
              : isHeader
                  ? (isDark ? Colors.white : const Color(0xFF1E293B))
                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
        ),
      ),
    );
  }

  // Section Card with Number & Bullets
  Widget _buildSectionCard({
    required String number,
    required String title,
    required List<String> bullets,
    Color? badgeColor,
    required bool isDark,
  }) {
    final activeColor = badgeColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Official Accreditation Card
  Widget _buildOfficialAccreditationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'الجهة المسؤولة والمشغلة للمنصة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'منصة ذبائح المملكة مسجلة رسميـاً بموجب سجل تجاري رقم 1010000000 ورقم ضريبي معتمد لدى هيئة الزكاة والضريبة والجمارك 300000000000003 وتخضع للرقابة الصحية للجهات المختصة.',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Floating Contact Bar
  Widget _buildBottomContactBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _launchWhatsApp,
              icon: const Icon(Icons.chat_rounded, size: 16),
              label: Text(
                'تواصل عبر واتساب',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _makePhoneCall,
              icon: const Icon(Icons.phone_rounded, size: 16),
              label: Text(
                'اتصال بالدعم',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.brandDark,
                side: BorderSide(color: isDark ? Colors.white24 : AppColors.cardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
