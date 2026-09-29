import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/orders/domain/entities/order_entity.dart';
import '../../core/admin_i18n.dart';

class AdminOrderCard extends StatelessWidget {
  final OrderListItemEntity order;
  final VoidCallback onTap;
  final Function(String newStatus) onStatusChange;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusChange,
  });

  Color _getStatusColor(String state) {
    switch (state) {
      case 'draft':
      case 'pending_payment':
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF3B82F6);
      case 'preparing':
        return const Color(0xFFF97316);
      case 'ready_pickup':
        return const Color(0xFF8B5CF6);
      case 'out_delivery':
      case 'out_for_delivery':
        return const Color(0xFF06B6D4);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'refunded':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLocalized(String state, AdminI18n i18n) {
    switch (state) {
      case 'draft':
        return i18n.statusDraft;
      case 'pending_payment':
      case 'pending':
        return i18n.statusPending;
      case 'confirmed':
        return i18n.statusConfirmed;
      case 'preparing':
        return i18n.statusProcessing;
      case 'ready_pickup':
        return i18n.statusReadyPickup;
      case 'out_delivery':
      case 'out_for_delivery':
        return i18n.statusOutForDelivery;
      case 'delivered':
        return i18n.statusDelivered;
      case 'cancelled':
        return i18n.statusCancelled;
      case 'refunded':
        return i18n.statusRefunded;
      default:
        return state;
    }
  }

  void _callCustomer(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _whatsappCustomer(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);
    final statusColor = _getStatusColor(order.state);
    final isNew = order.state == 'pending_payment' || order.state == 'draft' || order.state == 'pending';
    final isPaid = order.paymentStatus == 'paid';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNew
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
          width: isNew ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isNew
                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Order Ref, Date, Status Badge ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(IconlyBold.bag, color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  order.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: order.name));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(i18n.isArabic ? 'تم نسخ رقم الطلب' : 'Order # copied'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.copy_rounded, size: 13, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              order.date,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white54 : AppColors.secondary,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _getStatusLocalized(order.state, i18n),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Customer Info & Quick Communication ─────────────────────────
                if (order.customerName != null && order.customerName!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141418) : const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(IconlyLight.profile, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.customerName!,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                          IconButton(
                            icon: const Icon(Icons.phone_rounded, size: 16, color: Colors.green),
                            tooltip: 'اتصال',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            onPressed: () => _callCustomer(order.customerPhone!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF25D366)),
                            tooltip: 'واتساب',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            onPressed: () => _whatsappCustomer(order.customerPhone!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // ── Financials, Badges & Delivery ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Items Count & Delivery Type
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(IconlyLight.paper, size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${order.itemCount} ${i18n.itemsCount}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isPaid ? (i18n.isArabic ? 'مدفوع' : 'Paid') : (i18n.isArabic ? 'غير مدفوع' : 'Unpaid'),
                            style: TextStyle(
                              color: isPaid ? Colors.green : Colors.red,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (order.deliveryType != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            order.deliveryType == 'pickup' ? (i18n.isArabic ? 'استلام من الفرع' : 'Pickup') : (i18n.isArabic ? 'توصيل' : 'Delivery'),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Total Price
                    Text(
                      '${order.total.toStringAsFixed(2)} ${i18n.sar}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Smart Next Action Button ──────────────────────────────────
                _buildNextActionButton(context, i18n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextActionButton(BuildContext context, AdminI18n i18n) {
    String? nextActionTitle;
    String? nextState;
    Color actionColor = AppColors.primary;
    IconData actionIcon = Icons.arrow_forward;

    switch (order.state) {
      case 'draft':
      case 'pending_payment':
      case 'pending':
        nextActionTitle = i18n.actionConfirm;
        nextState = 'confirmed';
        actionColor = const Color(0xFF3B82F6);
        actionIcon = Icons.check_circle_outline;
        break;
      case 'confirmed':
        nextActionTitle = i18n.actionStartPreparing;
        nextState = 'preparing';
        actionColor = const Color(0xFFF97316);
        actionIcon = Icons.outdoor_grill_rounded;
        break;
      case 'preparing':
        if (order.deliveryType == 'pickup') {
          nextActionTitle = i18n.actionMarkReady;
          nextState = 'ready_pickup';
        } else {
          nextActionTitle = i18n.actionOutForDelivery;
          nextState = 'out_delivery';
        }
        actionColor = const Color(0xFF06B6D4);
        actionIcon = Icons.local_shipping_outlined;
        break;
      case 'ready_pickup':
      case 'out_delivery':
      case 'out_for_delivery':
        nextActionTitle = i18n.actionMarkDelivered;
        nextState = 'delivered';
        actionColor = const Color(0xFF10B981);
        actionIcon = Icons.done_all_rounded;
        break;
      default:
        break;
    }

    return Row(
      children: [
        if (nextActionTitle != null && nextState != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onStatusChange(nextState!),
              icon: Icon(actionIcon, size: 16, color: Colors.white),
              label: Text(
                nextActionTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            i18n.isArabic ? 'التفاصيل' : 'Details',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
