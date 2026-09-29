import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../user/orders/domain/entities/order_entity.dart';
import '../../../user/orders/presentation/views/widgets/invoice_preview_sheet.dart';
import '../../core/admin_i18n.dart';
import '../manager/admin_orders_cubit.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  OrderDetailEntity? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    final detail = await context.read<AdminOrdersCubit>().loadOrderDetail(widget.orderId);
    if (mounted) {
      setState(() {
        _order = detail;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final i18n = AdminI18n.of(context);
    final success = await context.read<AdminOrdersCubit>().updateOrderStatus(widget.orderId, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(i18n.isArabic ? 'تم تحديث حالة الطلب ومزامنته مع Odoo' : 'Order status updated & synced'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      _loadDetails();
    }
  }

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

  void _openGoogleMaps(String address) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AdminI18n.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(i18n.orderDetailsTitle)),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final order = _order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(i18n.orderDetailsTitle)),
        body: Center(child: Text(i18n.isArabic ? 'لم يتم العثور على بيانات الطلب' : 'Order details not found')),
      );
    }

    final statusColor = _getStatusColor(order.state);
    final isPaid = order.paymentStatus == 'paid';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121214) : const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              order.date,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: i18n.isArabic ? 'الفاتورة والطباعة' : 'Invoice & Print',
            onPressed: () => InvoicePreviewSheet.show(context, order: order, isAdmin: true),
          ),
          IconButton(
            icon: const Icon(IconlyLight.activity),
            tooltip: i18n.isArabic ? 'تحديث' : 'Refresh',
            onPressed: _loadDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Odoo Header Style Action Bar & Status Stepper ─────────────
            _buildOdooHeaderActions(order, statusColor, isDark, i18n),
            const SizedBox(height: 16),

            // ── 2. Customer & Delivery Card ──────────────────────────────────
            _buildCustomerAndDeliveryCard(order, isDark, i18n),
            const SizedBox(height: 16),

            // ── 3. Order Items & Custom Specifications ───────────────────────
            _buildOrderItemsCard(order, isDark, i18n),
            const SizedBox(height: 16),

            // ── 4. Financials & Payment Details ──────────────────────────────
            _buildFinancialsAndPaymentCard(order, isPaid, isDark, i18n),
            const SizedBox(height: 16),

            // ── 5. Interactive Timeline (History) ────────────────────────────
            _buildTimelineCard(order, isDark, i18n),
          ],
        ),
      ),
    );
  }

  // ── Odoo Style Header Actions ──────────────────────────────────────────────
  Widget _buildOdooHeaderActions(OrderDetailEntity order, Color statusColor, bool isDark, AdminI18n i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(IconlyBold.shield_done, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i18n.isArabic ? 'حالة الطلب الحالية' : 'Current Status',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                      ),
                      Text(
                        _getStatusLocalized(order.state, i18n),
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${order.lines.length} ${i18n.itemsCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Action Buttons (ERP State Transitions)
          Text(
            i18n.isArabic ? 'إجراءات إدارة العمليات (Odoo Workflow):' : 'Order Workflow Actions:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                title: i18n.isArabic ? 'الفاتورة والطباعة' : 'Invoice & Print',
                color: const Color(0xFF0F766E),
                icon: Icons.receipt_long_rounded,
                onTap: () => InvoicePreviewSheet.show(context, order: order, isAdmin: true),
              ),
              if (order.state == 'draft' || order.state == 'pending_payment' || order.state == 'pending')
                _buildActionButton(
                  title: i18n.actionConfirm,
                  color: const Color(0xFF3B82F6),
                  icon: Icons.check_circle_outline,
                  onTap: () => _updateStatus('confirmed'),
                ),
              if (order.state == 'confirmed')
                _buildActionButton(
                  title: i18n.actionStartPreparing,
                  color: const Color(0xFFF97316),
                  icon: Icons.outdoor_grill_rounded,
                  onTap: () => _updateStatus('preparing'),
                ),
              if (order.state == 'preparing') ...[
                _buildActionButton(
                  title: i18n.actionMarkReady,
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.inventory_2_outlined,
                  onTap: () => _updateStatus('ready_pickup'),
                ),
                _buildActionButton(
                  title: i18n.actionOutForDelivery,
                  color: const Color(0xFF06B6D4),
                  icon: Icons.local_shipping_outlined,
                  onTap: () => _updateStatus('out_delivery'),
                ),
              ],
              if (order.state == 'ready_pickup' || order.state == 'out_delivery')
                _buildActionButton(
                  title: i18n.actionMarkDelivered,
                  color: const Color(0xFF10B981),
                  icon: Icons.done_all_rounded,
                  onTap: () => _updateStatus('delivered'),
                ),
              if (order.state != 'delivered' && order.state != 'cancelled' && order.state != 'refunded')
                _buildActionButton(
                  title: i18n.actionCancel,
                  color: const Color(0xFFEF4444),
                  icon: Icons.cancel_outlined,
                  isOutlined: true,
                  onTap: () => _updateStatus('cancelled'),
                ),
              if (order.state == 'delivered')
                _buildActionButton(
                  title: i18n.actionRefund,
                  color: const Color(0xFF9333EA),
                  icon: Icons.replay_rounded,
                  isOutlined: true,
                  onTap: () => _updateStatus('refunded'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color color,
    required IconData icon,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15, color: color),
        label: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11.5)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  // ── Customer & Delivery Details ────────────────────────────────────────────
  Widget _buildCustomerAndDeliveryCard(OrderDetailEntity order, bool isDark, AdminI18n i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(IconlyBold.profile, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                i18n.isArabic ? 'بيانات العميل والتوصيل' : 'Customer & Delivery Info',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.deliveryType == 'pickup' ? i18n.deliveryTypePickup : i18n.deliveryTypeHome,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Customer Name, Email & Phone
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName != null && order.customerName!.isNotEmpty
                          ? order.customerName!
                          : (i18n.isArabic ? 'عميل المتجر' : 'Store Customer'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                    const SizedBox(height: 3),
                    if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            order.customerPhone!,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ],
                      ),
                    if (order.customerEmail != null && order.customerEmail!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            order.customerEmail!,
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                IconButton.filledTonal(
                  icon: const Icon(Icons.phone_rounded, color: Colors.green, size: 18),
                  tooltip: 'اتصال هاتف',
                  onPressed: () => _callCustomer(order.customerPhone!),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 18),
                  tooltip: 'واتساب',
                  onPressed: () => _whatsappCustomer(order.customerPhone!),
                ),
              ],
            ],
          ),

          // Address & Maps Link
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141418) : const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(IconlyLight.location, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.shippingAddress != null && order.shippingAddress!.isNotEmpty
                        ? order.shippingAddress!
                        : (order.deliveryType == 'pickup'
                            ? (i18n.isArabic ? 'استلام الطلب مباشرة من الفرع' : 'Store Pickup')
                            : (i18n.isArabic ? 'لم يتم تحديد عنوان تفصيلي' : 'No detailed address')),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (order.shippingAddress != null && order.shippingAddress!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _openGoogleMaps(order.shippingAddress!),
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: Text(i18n.isArabic ? 'الخريطة' : 'Map', style: const TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${i18n.isArabic ? "ملاحظات الطلب:" : "Order Notes:"} ${order.notes}',
              style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: isDark ? Colors.white60 : Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  // ── Order Items & Custom Specifications ────────────────────────────────────
  Widget _buildOrderItemsCard(OrderDetailEntity order, bool isDark, AdminI18n i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(IconlyBold.work, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                i18n.isArabic ? 'تفاصيل الذبائح والمنتجات المطلوبة' : 'Order Items & Cutting Options',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          ...order.lines.map((line) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141418) : const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name, Quantity & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          line.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                      Text(
                        '${line.priceSubtotal.toStringAsFixed(2)} ${i18n.sar}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الكمية: ${line.quantity.toInt()} × ${line.priceUnit.toStringAsFixed(2)} ${i18n.sar}',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                  ),

                  // Cutting, Packaging & Excluded Parts Badges
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (line.cuttingOption != null)
                        _buildOptionBadge(line.cuttingOption!.name, Colors.blue, isDark),
                      if (line.packaging != null)
                        _buildOptionBadge(line.packaging!.name, Colors.purple, isDark),
                      ...line.excludedParts.map(
                        (p) => _buildOptionBadge(p.name, Colors.amber.shade800, isDark),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Financials & Payment Details ───────────────────────────────────────────
  Widget _buildFinancialsAndPaymentCard(OrderDetailEntity order, bool isPaid, bool isDark, AdminI18n i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(IconlyBold.wallet, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    i18n.isArabic ? 'الفاتورة وحالة الدفع' : 'Invoice & Payment',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? (i18n.isArabic ? 'تم الدفع' : 'Paid') : (i18n.isArabic ? 'بانتظار السداد' : 'Unpaid'),
                  style: TextStyle(color: isPaid ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Payment method & Ref
          if (order.paymentMethod != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(i18n.isArabic ? 'طريقة الدفع:' : 'Payment Method:', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                Text(order.paymentMethod!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (order.transactionRef != null && order.transactionRef!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(i18n.isArabic ? 'مرجع المعاملة:' : 'Transaction Ref:', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                Text(order.transactionRef!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
          ],

          _buildSummaryRow(i18n.isArabic ? 'المجموع الفرعي' : 'Subtotal', '${order.subtotal.toStringAsFixed(2)} ${i18n.sar}', isDark),
          if (order.deliveryFee > 0)
            _buildSummaryRow(i18n.isArabic ? 'رسوم التوصيل' : 'Delivery Fee', '${order.deliveryFee.toStringAsFixed(2)} ${i18n.sar}', isDark),
          if (order.couponCode != null && order.discountAmount > 0)
            _buildSummaryRow('${i18n.isArabic ? "خصم كوبون" : "Coupon"} (${order.couponCode})', '-${order.discountAmount.toStringAsFixed(2)} ${i18n.sar}', isDark, isGreen: true),
          if (order.pointsRedeemed > 0 && order.loyaltyDiscountAmount > 0)
            _buildSummaryRow('${i18n.isArabic ? "خصم نقاط الولاء" : "Loyalty Discount"} (${order.pointsRedeemed} نقطة)', '-${order.loyaltyDiscountAmount.toStringAsFixed(2)} ${i18n.sar}', isDark, isGreen: true),
          if (order.taxAmount > 0)
            _buildSummaryRow(i18n.isArabic ? 'ضريبة القيمة المضافة' : 'VAT', '${order.taxAmount.toStringAsFixed(2)} ${i18n.sar}', isDark),

          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                i18n.isArabic ? 'الإجمالي النهائي' : 'Grand Total',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              Text(
                '${order.total.toStringAsFixed(2)} ${i18n.sar}',
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isGreen ? Colors.green : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // ── Interactive Timeline (History) ─────────────────────────────────────────
  Widget _buildTimelineCard(OrderDetailEntity order, bool isDark, AdminI18n i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(IconlyBold.time_circle, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                i18n.orderTimeline,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (order.timeline.isEmpty)
            Text(
              i18n.isArabic ? 'لا توجد حركات مسجلة للطلب بعد' : 'No timeline records yet',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.timeline.length,
              itemBuilder: (context, index) {
                final item = order.timeline[index];
                final isLast = index == order.timeline.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 36,
                            color: isDark ? Colors.white12 : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getStatusLocalized(item.statusTo, i18n),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                                Text(
                                  item.timestamp,
                                  style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white38 : Colors.black38),
                                ),
                              ],
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
