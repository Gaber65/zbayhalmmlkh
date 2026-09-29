import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_marketing_cubit.dart';
import '../widgets/banner_form_dialog.dart';
import '../widgets/broadcast_notification_dialog.dart';
import '../widgets/coupon_form_dialog.dart';
import '../widgets/offer_form_dialog.dart';
import '../widgets/admin_image_upload_picker.dart';
import '../../../user/offers/domain/entities/offer_entity.dart';

class AdminMarketingView extends StatefulWidget {
  const AdminMarketingView({super.key});

  @override
  State<AdminMarketingView> createState() => _AdminMarketingViewState();
}

class _AdminMarketingViewState extends State<AdminMarketingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (context.read<AdminMarketingCubit>().state is AdminMarketingInitial) {
      context.read<AdminMarketingCubit>().loadMarketingData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openOfferDialog([OfferEntity? offer]) {
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (_) => OfferFormDialog(
        offer: offer,
        onSave: (data) async {
          final cubit = context.read<AdminMarketingCubit>();
          final success = offer != null
              ? await cubit.updateOffer(offer.id, data)
              : await cubit.createOffer(data);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  i18n.isArabic
                      ? (offer != null ? 'تم تعديل بيانات العرض بنجاح' : 'تمت إضافة العرض الترويجي بنجاح')
                      : (offer != null ? 'Offer updated successfully' : 'Offer added successfully'),
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _openCouponDialog([AdminCouponEntity? coupon]) {
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (_) => CouponFormDialog(
        coupon: coupon,
        onSave: (data) async {
          final success = await context
              .read<AdminMarketingCubit>()
              .createCoupon(data);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  i18n.isArabic
                      ? 'تم حفظ كود الخصم بنجاح 🎉'
                      : 'Promo coupon saved successfully 🎉',
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  void _openBannerDialog([AdminBannerEntity? banner]) {
    final i18n = AdminI18n.of(context);

    showDialog(
      context: context,
      builder: (_) => BannerFormDialog(
        banner: banner,
        onSave: (data) async {
          final cubit = context.read<AdminMarketingCubit>();
          final success = banner != null
              ? await cubit.updateBanner(banner.id, data)
              : await cubit.createBanner(data);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  i18n.isArabic
                      ? (banner != null ? 'تم تعديل البنر الإعلاني بنجاح' : 'تمت إضافة البنر الإعلاني بنجاح')
                      : (banner != null ? 'Banner updated successfully' : 'Banner added successfully'),
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          } else if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  i18n.isArabic
                      ? 'فشل في حفظ البنر، يرجى المحاولة مرة أخرى'
                      : 'Failed to save banner, please try again',
                ),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    return Column(
      children: [
        // ── Top Broadcast Notification CTA ───────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1F1F23), Color(0xFF18181B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  IconlyBold.notification,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.isArabic
                          ? 'حملة إشعارات ترويجية'
                          : 'Promotional Push Campaign',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      i18n.isArabic
                          ? 'أرسل عروضك وتنبيهاتك فوراً لهواتف جميع العملاء'
                          : 'Send instant push alerts & offers to all devices',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BroadcastNotificationDialog(
                      onSend: (title, body, topic) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final cubit = context.read<AdminMarketingCubit>();
                        final success = await cubit.sendBroadcastNotification(
                          title: title,
                          body: body,
                          topic: topic,
                        );
                        if (success && mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(i18n.pushSuccess)),
                          );
                        }
                        return success;
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  i18n.isArabic ? 'إرسال الآن' : 'Send Now',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Tabs for Coupons, Banners, and Highlights ───────────────────
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? Colors.white60 : AppColors.secondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: [
              Tab(text: i18n.tabCoupons),
              Tab(text: i18n.tabBanners),
              Tab(text: i18n.isArabic ? 'العروض الترويجية' : 'Promotions'),
              Tab(text: i18n.isArabic ? 'القصص والهايلايتس' : 'Stories & Highlights'),
            ],
          ),
        ),

        const Divider(height: 1),

        // ── Tab Contents ──────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCouponsTab(isDark, i18n),
              _buildBannersTab(isDark, i18n),
              _buildOffersTab(isDark, i18n),
              _buildHighlightsTab(isDark, i18n),
            ],
          ),
        ),
      ],
    );
  }

  // ── Coupons Tab ─────────────────────────────────────────────────────────
  Widget _buildCouponsTab(bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminMarketingCubit, AdminMarketingState>(
      builder: (context, state) {
        if (state is AdminMarketingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminMarketingLoaded) {
          final coupons = state.coupons;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${i18n.tabCoupons} (${coupons.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openCouponDialog(),
                      icon: const Icon(
                        IconlyLight.plus,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        i18n.addCoupon,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context
                      .read<AdminMarketingCubit>()
                      .loadMarketingData(silent: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E24)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                IconlyBold.discount,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          coupon.code,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            letterSpacing: 1.1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          coupon.discountType == 'percentage'
                                              ? '${i18n.isArabic ? 'خصم' : 'Discount'} ${coupon.discountValue.toInt()}%'
                                              : '${i18n.isArabic ? 'خصم' : 'Discount'} ${coupon.discountValue} ${i18n.sar}',
                                          style: const TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${i18n.minOrderAmount}: ${coupon.minOrderValue} ${i18n.sar} • ${i18n.isArabic ? 'استخدامات' : 'Uses'}: ${coupon.currentUses}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white60
                                          : AppColors.secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: coupon.isActive,
                              activeThumbColor: const Color(0xFF10B981),
                              onChanged: (val) {
                                context
                                    .read<AdminMarketingCubit>()
                                    .toggleCoupon(coupon.id, val);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                IconlyLight.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              tooltip: i18n.delete,
                              onPressed: () {
                                context
                                    .read<AdminMarketingCubit>()
                                    .deleteCoupon(coupon.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Banners Tab ─────────────────────────────────────────────────────────
  Widget _buildBannersTab(bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminMarketingCubit, AdminMarketingState>(
      builder: (context, state) {
        if (state is AdminMarketingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminMarketingLoaded) {
          final banners = state.banners;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${i18n.tabBanners} (${banners.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openBannerDialog(),
                      icon: const Icon(
                        IconlyLight.plus,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        i18n.addBanner,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context
                      .read<AdminMarketingCubit>()
                      .loadMarketingData(silent: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E24)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Container(
                                height: 130,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: banner.imageUrl.isNotEmpty
                                    ? Image.network(
                                        banner.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          IconlyLight.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const Icon(
                                        IconlyLight.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    banner.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      IconlyLight.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: i18n.delete,
                                    onPressed: () {
                                      context
                                          .read<AdminMarketingCubit>()
                                          .deleteBanner(banner.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Highlights / Stories Tab ───────────────────────────────────────────
  Widget _buildHighlightsTab(bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminMarketingCubit, AdminMarketingState>(
      builder: (context, state) {
        if (state is AdminMarketingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminMarketingLoaded) {
          final highlights = state.highlights;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${i18n.isArabic ? 'القصص الترويجية النشطة' : 'Active Stories'} (${highlights.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openAddHighlightDialog(),
                      icon: const Icon(IconlyLight.plus, size: 16, color: Colors.white),
                      label: Text(
                        i18n.isArabic ? 'إضافة قصة / هايلايت' : 'Add Story',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: highlights.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(IconlyLight.video, size: 48, color: isDark ? Colors.white38 : Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              i18n.isArabic ? 'لا توجد قصص أو هايلايتس منشورة حالياً' : 'No active highlights published yet',
                              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<AdminMarketingCubit>().loadMarketingData(silent: true),
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: highlights.length,
                          itemBuilder: (context, index) {
                            final item = highlights[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                          child: Container(
                                            width: double.infinity,
                                            color: Colors.grey.shade300,
                                            child: item.mediaUrl.isNotEmpty
                                                ? Image.network(
                                                    item.mediaUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) => const Icon(IconlyLight.video, size: 40),
                                                  )
                                                : const Icon(IconlyLight.video, size: 40),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.6),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  item.mediaType == 'video' ? IconlyBold.video : IconlyBold.image,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item.mediaType.toUpperCase(),
                                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title ?? (i18n.isArabic ? 'قصة مميزة' : 'Story'),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(IconlyLight.delete, size: 18, color: Colors.red),
                                          onPressed: () => context.read<AdminMarketingCubit>().deleteHighlight(item.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _openAddHighlightDialog() {
    final cubit = context.read<AdminMarketingCubit>();
    final i18n = AdminI18n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urlController = TextEditingController();
    final titleController = TextEditingController();
    String mediaType = 'image';
    String? pickedImagePath;
    String? pickedBase64;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
          title: Text(
            i18n.isArabic ? 'نشر قصة / هايلايت جديد' : 'Publish New Story',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'عنوان القصة (اختياري)' : 'Story Title',
                    prefixIcon: const Icon(IconlyLight.paper),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                AdminImageUploadPicker(
                  label: i18n.isArabic ? 'رفع صورة القصة من جهازك' : 'Upload Story Media',
                  onImagePicked: ({imagePath, base64Image, imageBytes, fileName}) {
                    setDialogState(() {
                      pickedImagePath = imagePath;
                      pickedBase64 = base64Image;
                    });
                  },
                  onImageRemoved: () {
                    setDialogState(() {
                      pickedImagePath = null;
                      pickedBase64 = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: i18n.isArabic ? 'أو أدخل رابط الوسائط (URL)' : 'Or Media URL',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(i18n.isArabic ? 'صورة' : 'Image')),
                        selected: mediaType == 'image',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: mediaType == 'image' ? Colors.white : Colors.black87),
                        onSelected: (_) => setDialogState(() => mediaType = 'image'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(i18n.isArabic ? 'فيديو' : 'Video')),
                        selected: mediaType == 'video',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: mediaType == 'video' ? Colors.white : Colors.black87),
                        onSelected: (_) => setDialogState(() => mediaType = 'video'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(i18n.cancel)),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                if (pickedImagePath == null && pickedBase64 == null && url.isEmpty) return;
                Navigator.of(ctx).pop();
                final success = await cubit.createHighlight({
                  if (pickedImagePath != null) 'image_path': pickedImagePath,
                  if (pickedBase64 != null) 'base64_image': pickedBase64,
                  if (url.isNotEmpty) 'media_url': url,
                  'media_type': mediaType,
                  'title': titleController.text.trim(),
                });
                if (success && mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(i18n.isArabic ? 'تم نشر القصة بنجاح 📸' : 'Story published successfully 📸'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(i18n.save, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Offers Tab ──────────────────────────────────────────────────────────
  Widget _buildOffersTab(bool isDark, AdminI18n i18n) {
    return BlocBuilder<AdminMarketingCubit, AdminMarketingState>(
      builder: (context, state) {
        if (state is AdminMarketingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminMarketingLoaded) {
          final offers = state.offers;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${i18n.isArabic ? 'العروض الترويجية' : 'Promotional Offers'} (${offers.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openOfferDialog(),
                      icon: const Icon(
                        IconlyLight.plus,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        i18n.isArabic ? 'إضافة عرض ترويجي' : 'Add Promotion',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: offers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconlyLight.discount,
                              size: 64,
                              color: isDark ? Colors.white24 : AppColors.secondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              i18n.isArabic ? 'لا توجد عروض ترويجية نشطة' : 'No active promotional offers',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return _buildOfferCard(offer, isDark, i18n);
                        },
                      ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildOfferCard(OfferEntity offer, bool isDark, AdminI18n i18n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer.bannerImageUrl != null && offer.bannerImageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                offer.bannerImageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: AppColors.primaryContainer,
                  child: const Center(child: Icon(IconlyBold.discount, size: 40, color: AppColors.primary)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        offer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    if (offer.badgeText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer.badgeText,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (offer.subtitle != null && offer.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    offer.subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
                if (offer.startDate != null || offer.endDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(IconlyLight.calendar, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${offer.startDate ?? ''} ${offer.endDate != null ? '→ ${offer.endDate}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          i18n.isArabic ? 'الحالة' : 'Status',
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: offer.isActive,
                          activeTrackColor: AppColors.primary,
                          onChanged: (_) => context.read<AdminMarketingCubit>().toggleOffer(offer.id),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(IconlyLight.edit, size: 18),
                          tooltip: i18n.edit,
                          onPressed: () => _openOfferDialog(offer),
                        ),
                        IconButton(
                          icon: const Icon(IconlyLight.delete, size: 18, color: Colors.red),
                          tooltip: i18n.delete,
                          onPressed: () => _confirmDeleteOffer(offer),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOffer(OfferEntity offer) {
    final i18n = AdminI18n.of(context);
    final cubit = context.read<AdminMarketingCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.isArabic ? 'حذف العرض الترويجي' : 'Delete Promotion'),
        content: Text(
          i18n.isArabic
              ? 'هل أنت متأكد من حذف العرض "${offer.name}"؟'
              : 'Are you sure you want to delete offer "${offer.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await cubit.deleteOffer(offer.id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(i18n.isArabic ? 'تم حذف العرض بنجاح' : 'Offer deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(i18n.delete),
          ),
        ],
      ),
    );
  }
}

