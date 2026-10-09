import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/features/admin/domain/entities/admin_entities.dart';
import 'package:dhabayih_lmamlaka/features/admin/domain/repositories/admin_repository.dart';

/// Bottom sheet displaying notifications specifically formatted for regular users / customers.
class UserNotificationsSheet extends StatefulWidget {
  const UserNotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UserNotificationsSheet(),
    );
  }

  @override
  State<UserNotificationsSheet> createState() => _UserNotificationsSheetState();
}

class _UserNotificationsSheetState extends State<UserNotificationsSheet> {
  final AdminRepository _repository = getIt<AdminRepository>();
  List<AdminNotificationEntity> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _activeFilter = 'all'; // all, order, offer

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getNotifications();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.error.message;
        });
      },
      (notifications) {
        setState(() {
          _isLoading = false;
          _notifications = notifications;
        });
      },
    );
  }

  Future<void> _markAllRead() async {
    await _repository.markNotificationsRead(markAll: true);
    if (!mounted) return;
    setState(() {
      _notifications = _notifications
          .map((n) => AdminNotificationEntity(
                id: n.id,
                title: n.title,
                body: n.body,
                imageUrl: n.imageUrl,
                notificationType: n.notificationType,
                priority: n.priority,
                deepLink: n.deepLink,
                status: n.status,
                sentAt: n.sentAt,
                readAt: DateTime.now().toIso8601String(),
                orderId: n.orderId,
              ))
          .toList();
    });
  }

  List<AdminNotificationEntity> get _filteredNotifications {
    if (_activeFilter == 'order') {
      return _notifications
          .where((n) => n.notificationType == 'order' || n.orderId != null)
          .toList();
    }
    if (_activeFilter == 'offer') {
      return _notifications
          .where((n) =>
              n.notificationType == 'offer' ||
              n.notificationType == 'promo' ||
              n.notificationType == 'discount')
          .toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Grab Handle ──────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        IconlyBold.notification,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإشعارات',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'آخر التنبيهات وتحديثات طلباتك',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_notifications.isNotEmpty)
                  TextButton.icon(
                    onPressed: _markAllRead,
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text(
                      'تحديد كمقروء',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Filter Chips ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('الطلبات', 'order', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('العروض والخصومات', 'offer', isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),

          // ── Notification Items / Content ─────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : _filteredNotifications.isEmpty
                        ? _buildEmptyState(isDark)
                        : RefreshIndicator(
                            onRefresh: _fetchNotifications,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: _filteredNotifications.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = _filteredNotifications[index];
                                return _buildNotificationCard(
                                  context,
                                  item,
                                  isDark,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _activeFilter == value;
    return InkWell(
      onTap: () => setState(() => _activeFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AdminNotificationEntity item,
    bool isDark,
  ) {
    final isUnread = item.readAt == null;
    final isOrder = item.orderId != null || item.notificationType == 'order';

    IconData iconData = IconlyBold.notification;
    Color iconColor = AppColors.primary;
    if (isOrder) {
      iconData = IconlyBold.bag;
      iconColor = const Color(0xFF2563EB);
    } else if (item.notificationType == 'offer' ||
        item.notificationType == 'promo') {
      iconData = IconlyBold.discount;
      iconColor = const Color(0xFFE11D48);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (item.orderId != null) {
            Navigator.pop(context);
            context.push(Routes.orderDetails, extra: item.orderId);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primaryContainer.withValues(alpha: 0.35))
                : (isDark ? const Color(0xFF222226) : const Color(0xFFFAFAFC)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.sentAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.sentAt!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyLight.notification,
                size: 48,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد إشعارات حالياً',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'سنخبرك فور وصول أي تحديث جديد لطلباتك وعروضنا الحصرية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          Text(_errorMessage ?? 'تعذر تحميل الإشعارات'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchNotifications,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
