import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/di/injection.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../manager/order_cubit.dart';
import '../manager/order_state.dart';
import '../../domain/entities/order_entity.dart';
import 'widgets/invoice_preview_sheet.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<OrderCubit>();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    _cubit.fetchOrderDetail(widget.orderId);
  }

  String _getTranslatedState(String state, S s) {
    switch (state) {
      case 'draft':
        return s.order_status_draft;
      case 'pending_payment':
        return s.order_status_pending;
      case 'confirmed':
        return s.order_status_confirmed;
      case 'preparing':
        return s.order_status_preparing;
      case 'ready_pickup':
        return s.order_status_ready;
      case 'out_delivery':
        return s.order_status_out;
      case 'delivered':
        return s.order_status_delivered;
      case 'cancelled':
        return s.order_status_cancelled;
      case 'refunded':
        return s.order_status_refunded;
      default:
        return state;
    }
  }

  Color _getStatusColor(String state, ColorScheme cs) {
    switch (state) {
      case 'draft':
      case 'pending_payment':
        return Colors.amber;
      case 'confirmed':
      case 'preparing':
        return cs.primary;
      case 'ready_pickup':
      case 'out_delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'refunded':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }

  void _showCancelDialog(BuildContext context, S s, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.cancel_order),
        content: Text(s.cancel_order_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              s.select_option, // placeholder for cancel/no
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _cubit.cancelOrder(widget.orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: Text(s.cancel_order),
          ),
        ],
      ),
    );
  }

  void _showReceiveDialog(BuildContext context, S s, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد استلام الطلب'),
        content: const Text('هل تؤكد استلامك للطلب بنجاح؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _cubit.receiveOrder(widget.orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderCancelLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          } else if (state is OrderCancelError) {
            Navigator.of(context).pop(); // Dismiss loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          } else if (state is OrderCancelSuccess) {
            Navigator.of(context).pop(); // Dismiss loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.cancel_order_success),
                backgroundColor: Colors.green,
              ),
            );
            _loadOrderDetails(); // Reload order detail
          } else if (state is OrderReceiveLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          } else if (state is OrderReceiveError) {
            Navigator.of(context).pop(); // Dismiss loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          } else if (state is OrderReceiveSuccess) {
            Navigator.of(context).pop(); // Dismiss loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadOrderDetails(); // Reload order detail
          }
        },
        child: Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text(
              s.order_details,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.receipt_long_rounded),
                tooltip: 'الفاتورة الضريبية',
                onPressed: () {
                  final state = _cubit.state;
                  if (state is OrderDetailLoaded) {
                    InvoicePreviewSheet.show(context, order: state.order);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadOrderDetails,
              ),
            ],
          ),
          body: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is OrderDetailLoaded) {
                final order = state.order;
                final statusColor = _getStatusColor(order.state, cs);

                return RefreshIndicator(
                  onRefresh: () async => _loadOrderDetails(),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Order ID & State Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${s.order_date}: ${order.date}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getTranslatedState(order.state, s),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. Fulfillment info
                        if (order.notes != null && order.notes!.isNotEmpty) ...[
                          Text(
                            s.notes_label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: cs.outlineVariant.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              order.notes!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 3. Products list with customizations
                        Text(
                          s.order_summary,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.lines.length,
                          itemBuilder: (context, index) {
                            final line = order.lines[index];
                            return _buildOrderLineCard(line, s, theme, cs);
                          },
                        ),
                        const SizedBox(height: 16),

                        // 4. Payment Info
                        _buildPaymentDetailsCard(order, s, theme, cs),
                        const SizedBox(height: 16),

                        // 4.1 Invoice Banner Card
                        InkWell(
                          onTap: () => InvoicePreviewSheet.show(context, order: order),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'فاتورة ضريبية مبسطة',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'معاينة الفاتورة ومشاركتها عبر واتساب أو تحميل PDF',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'عرض',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 5. Timeline Tracking
                        if (order.timeline.isNotEmpty) ...[
                          Text(
                            s.tracking_timeline,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTimelineCard(order.timeline, s, theme, cs),
                          const SizedBox(height: 24),
                        ],

                        // 6. Cancel Button if cancellable
                        if (order.isCancellable)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showCancelDialog(context, s, cs),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.errorContainer,
                                foregroundColor: cs.onErrorContainer,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                s.cancel_order,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        // 7. Confirm Receipt Button
                        if (order.isReceivable)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showReceiveDialog(context, s, cs),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'تأكيد استلام الطلب',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else if (state is OrderError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrderDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                        ),
                        child: Text(s.error_retry),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrderLineCard(
      OrderLineEntity line, S s, ThemeData theme, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  line.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${line.priceSubtotal.toStringAsFixed(2)} ${s.sar}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${s.quantity_label}: ${line.quantity} × ${line.priceUnit.toStringAsFixed(2)} ${s.sar}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          if (line.cuttingOption != null ||
              line.packaging != null ||
              line.excludedParts.isNotEmpty) ...[
            const Divider(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (line.cuttingOption != null)
                  _buildOptionBadge(
                    Icons.content_cut_rounded,
                    line.cuttingOption!.name,
                    Colors.amber,
                    cs,
                  ),
                if (line.packaging != null)
                  _buildOptionBadge(
                    Icons.inventory_2_rounded,
                    line.packaging!.name,
                    Colors.green,
                    cs,
                  ),
                for (var part in line.excludedParts)
                  _buildOptionBadge(
                    Icons.remove_circle_outline_rounded,
                    part.name,
                    cs.error,
                    cs,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionBadge(
      IconData icon, String label, Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(
      OrderDetailEntity order, S s, ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
              s.subtotal, '${order.subtotal.toStringAsFixed(2)} ${s.sar}', theme, cs),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              s.discount,
              '-${order.discountAmount.toStringAsFixed(2)} ${s.sar}',
              theme,
              cs,
              textColor: cs.error,
            ),
          ],
          if (order.loyaltyDiscountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              s.loyalty_discount,
              '-${order.loyaltyDiscountAmount.toStringAsFixed(2)} ${s.sar}',
              theme,
              cs,
              textColor: cs.error,
            ),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow(
              s.tax, '${order.taxAmount.toStringAsFixed(2)} ${s.sar}', theme, cs),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.order_total,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              Text(
                '${order.total.toStringAsFixed(2)} ${s.sar}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      String label, String value, ThemeData theme, ColorScheme cs,
      {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(
      List<OrderTimelineEntity> timeline, S s, ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: timeline.length,
        itemBuilder: (context, index) {
          final event = timeline[index];
          final isLast = index == timeline.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: VerticalDivider(
                          color: AppColors.primary.withOpacity(0.5),
                          thickness: 2,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.timestamp,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
