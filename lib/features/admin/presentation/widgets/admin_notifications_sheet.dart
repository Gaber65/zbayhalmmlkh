import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../core/admin_i18n.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';
import 'broadcast_notification_dialog.dart';

class AdminNotificationsSheet extends StatefulWidget {
  final Function(int orderId)? onOpenOrderDetail;
  final Function(int tabIndex)? onNavigateTab;

  const AdminNotificationsSheet({
    super.key,
    this.onOpenOrderDetail,
    this.onNavigateTab,
  });

  static Future<void> show(
    BuildContext context, {
    Function(int orderId)? onOpenOrderDetail,
    Function(int tabIndex)? onNavigateTab,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminNotificationsSheet(
        onOpenOrderDetail: onOpenOrderDetail,
        onNavigateTab: onNavigateTab,
      ),
    );
  }

  @override
  State<AdminNotificationsSheet> createState() =>
      _AdminNotificationsSheetState();
}

class _AdminNotificationsSheetState extends State<AdminNotificationsSheet> {
  final AdminRepository _repository = getIt<AdminRepository>();
  List<AdminNotificationEntity> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _activeFilter = 'all'; // all, order, unread, loyalty, system
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    _fetchNotifications();
  }

  void _handleNotificationTap(AdminNotificationEntity item) {
    // 1. Mark as read in background if unread
    if (item.status != 'read') {
      _repository.markNotificationsRead(id: item.id);
    }

    // 2. Extract Deep Link / Target Action
    int? targetOrderId = item.orderId;
    if (targetOrderId == null && item.deepLink != null) {
      final match = RegExp(r'orders/(\d+)').firstMatch(item.deepLink!);
      if (match != null) {
        targetOrderId = int.tryParse(match.group(1)!);
      }
    }

    // Check if deep link or type routes to specific sections
    final link = (item.deepLink ?? '').toLowerCase();
    final type = item.notificationType.toLowerCase();

    Navigator.pop(context); // Close bottom sheet first

    if (targetOrderId != null && widget.onOpenOrderDetail != null) {
      widget.onOpenOrderDetail!(targetOrderId);
    } else if ((type == 'loyalty' || link.contains('loyalty')) && widget.onNavigateTab != null) {
      widget.onNavigateTab!(7); // Settings & Loyalty
    } else if ((type == 'marketing' || link.contains('marketing') || link.contains('banner')) && widget.onNavigateTab != null) {
      widget.onNavigateTab!(6); // Marketing & Coupons
    } else if ((type == 'user' || link.contains('user') || link.contains('customer')) && widget.onNavigateTab != null) {
      widget.onNavigateTab!(4); // Users CRM
    } else if ((type == 'product' || link.contains('product')) && widget.onNavigateTab != null) {
      widget.onNavigateTab!(2); // Products
    } else if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(1); // Default to Orders tab
    }
  }

  List<AdminNotificationEntity> get _filteredNotifications {
    var list = _notifications;

    // Filter by category
    if (_activeFilter == 'unread') {
      list = list.where((n) => n.status != 'read').toList();
    } else if (_activeFilter == 'order') {
      list = list.where((n) => n.notificationType == 'order' || n.orderId != null).toList();
    } else if (_activeFilter == 'loyalty') {
      list = list.where((n) => n.notificationType == 'loyalty').toList();
    } else if (_activeFilter == 'system') {
      list = list.where((n) => n.notificationType != 'order' && n.notificationType != 'loyalty').toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((n) {
        final title = n.title.toLowerCase();
        final body = n.body.toLowerCase();
        final orderNum = n.orderId?.toString() ?? '';
        return title.contains(q) || body.contains(q) || orderNum.contains(q);
      }).toList();
    }

    return list;
  }

  int _getCountForFilter(String filterKey) {
    if (filterKey == 'all') return _notifications.length;
    if (filterKey == 'unread') return _notifications.where((n) => n.status != 'read').length;
    if (filterKey == 'order') return _notifications.where((n) => n.notificationType == 'order' || n.orderId != null).length;
    if (filterKey == 'loyalty') return _notifications.where((n) => n.notificationType == 'loyalty').length;
    if (filterKey == 'system') return _notifications.where((n) => n.notificationType != 'order' && n.notificationType != 'loyalty').length;
    return 0;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'order':
        return const Color(0xFF3B82F6);
      case 'loyalty':
        return const Color(0xFF8B5CF6);
      case 'marketing':
        return const Color(0xFFF97316);
      case 'system':
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'order':
        return IconlyBold.bag;
      case 'loyalty':
        return IconlyBold.star;
      case 'marketing':
        return IconlyBold.volume_up;
      case 'system':
      default:
        return IconlyBold.notification;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);
    final displayedList = _filteredNotifications;
    final unreadTotal = _getCountForFilter('unread');

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Drag Handle ───────────────────────────────────────────────
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // ── Header: Title, Total Badge, Mark All Read ─────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    IconlyBold.notification,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            i18n.isArabic ? 'مركز التنبيهات والإشعارات' : 'Notification Center',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (unreadTotal > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadTotal',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${_notifications.length} ${i18n.isArabic ? "إشعار مسجل في النظام" : "Total Notifications"}',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (_notifications.isNotEmpty)
                  TextButton.icon(
                    onPressed: _markAllRead,
                    icon: const Icon(IconlyLight.tick_square, size: 16),
                    label: Text(
                      i18n.isArabic ? 'قراءة الكل' : 'Mark All Read',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Search & Filter Navigation Bar ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222228) : const Color(0xFFF4F4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: i18n.isArabic ? 'بحث في التنبيهات، رقم الطلب، أو الرسالة...' : 'Search notifications, order #...',
                  hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                  prefixIcon: const Icon(IconlyLight.search, size: 18, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Advanced Navigation Filter Tabs (Categories) ──────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavChip('all', i18n.isArabic ? 'الكل' : 'All', isDark),
                const SizedBox(width: 6),
                _buildNavChip('unread', i18n.isArabic ? 'غير مقروءة' : 'Unread', isDark, isHighlight: unreadTotal > 0),
                const SizedBox(width: 6),
                _buildNavChip('order', i18n.isArabic ? 'الطلبات' : 'Orders', isDark),
                const SizedBox(width: 6),
                _buildNavChip('loyalty', i18n.isArabic ? 'نقاط الولاء' : 'Loyalty', isDark),
                const SizedBox(width: 6),
                _buildNavChip('system', i18n.isArabic ? 'العامة والنظام' : 'System', isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Actions Row: Broadcast Push Notification CTA ─────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222228) : const Color(0xFFF9F7F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    i18n.isArabic ? 'إرسال إشعار فوري لجميع العملاء' : 'Send Broadcast Push Notification',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BroadcastNotificationDialog(
                        onSend: (title, body, topic) async {
                          return await _repository
                              .sendBroadcastNotification(
                                title: title,
                                body: body,
                                topic: topic,
                              )
                              .then((res) => res.getOrElse(() => false));
                        },
                      ),
                    ).then((_) => _fetchNotifications());
                  },
                  icon: const Icon(IconlyLight.send, size: 13, color: Colors.white),
                  label: Text(
                    i18n.isArabic ? 'إرسال إشعار' : 'Broadcast',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 12),

          // ── Content List ─────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(IconlyLight.danger, size: 44, color: Colors.red),
                            const SizedBox(height: 10),
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: _fetchNotifications,
                              child: Text(i18n.retry),
                            ),
                          ],
                        ),
                      )
                    : displayedList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF222228) : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(IconlyLight.notification, size: 44, color: Colors.grey.shade400),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  i18n.isArabic ? 'لا توجد تنبيهات مطابقة' : 'No matching notifications',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  i18n.isArabic
                                      ? 'جميع التنبيهات والطلبات الواردة ستظهر هنا مباشرة'
                                      : 'All incoming updates will appear here automatically',
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _fetchNotifications,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: displayedList.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = displayedList[index];
                                final isUnread = item.status != 'read';
                                final typeColor = _getTypeColor(item.notificationType);
                                final typeIcon = _getTypeIcon(item.notificationType);

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _handleNotificationTap(item),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isUnread
                                            ? (isDark ? const Color(0xFF251A1D) : const Color(0xFFFDF4F5))
                                            : (isDark ? const Color(0xFF1E1E24) : Colors.grey.shade50),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isUnread
                                              ? AppColors.primary.withValues(alpha: 0.35)
                                              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                          width: isUnread ? 1.2 : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(9),
                                            decoration: BoxDecoration(
                                              color: typeColor.withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(typeIcon, size: 18, color: typeColor),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.title,
                                                        style: TextStyle(
                                                          fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                                          fontSize: 13.5,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isUnread) ...[
                                                      Container(
                                                        width: 7,
                                                        height: 7,
                                                        decoration: const BoxDecoration(
                                                          color: AppColors.primary,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                    ],
                                                    if (item.sentAt != null)
                                                      Text(
                                                        item.sentAt!.length >= 16
                                                            ? item.sentAt!.substring(0, 16)
                                                            : item.sentAt!,
                                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.body,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                                    height: 1.35,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),

                                                // ── Direct Navigation Action Chip ────────────────
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    if (item.orderId != null)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          '${i18n.isArabic ? "طلب رقم" : "Order"} #${item.orderId}',
                                                          style: const TextStyle(
                                                            fontSize: 10.5,
                                                            color: Color(0xFF3B82F6),
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      const SizedBox.shrink(),

                                                    Row(
                                                      children: [
                                                        Text(
                                                          i18n.isArabic ? 'عرض التفاصيل' : 'View Details',
                                                          style: TextStyle(
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.bold,
                                                            color: typeColor,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Icon(
                                                          i18n.isArabic ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                                                          size: 10,
                                                          color: typeColor,
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
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavChip(String key, String label, bool isDark, {bool isHighlight = false}) {
    final isSelected = _activeFilter == key;
    final count = _getCountForFilter(key);

    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isHighlight
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : (isDark ? const Color(0xFF222228) : const Color(0xFFF4F4F7))),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isHighlight
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04))),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isHighlight ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87)),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isHighlight ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (isHighlight ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
