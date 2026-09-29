import 'package:flutter/material.dart';
// Explicit imports from Moyasar to avoid naming conflicts with our AppPaymentStatus.
import 'package:moyasar/moyasar.dart'
    show PaymentConfig, CreditCard, STCPay, PaymentResponse, PaymentStatus;
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';

/// Native payment screen using the Moyasar embedded SDK.
///
/// Supports:
/// - Credit/Debit cards: Visa, Mastercard, Mada  (default)
/// - STC Pay: when [paymentMethodCode] == 'stc_pay'
///
/// Returns the Moyasar [PaymentResponse.id] string on success,
/// or `null` on failure / cancellation.
class NativePaymentScreen extends StatefulWidget {
  final String publishableKey;
  final int amountMinorUnits;
  final int orderId;
  final String orderNumber;
  final double totalAmount;

  /// Used to decide which Moyasar widget to render (card vs STC Pay).
  final String paymentMethodCode;

  const NativePaymentScreen({
    super.key,
    required this.publishableKey,
    required this.amountMinorUnits,
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    this.paymentMethodCode = 'visa',
  });

  @override
  State<NativePaymentScreen> createState() => _NativePaymentScreenState();
}

class _NativePaymentScreenState extends State<NativePaymentScreen> {
  late final PaymentConfig _paymentConfig;

  bool get _isStcPay => widget.paymentMethodCode == 'stc_pay';

  @override
  void initState() {
    super.initState();
    _paymentConfig = PaymentConfig(
      publishableApiKey: widget.publishableKey,
      amount: widget.amountMinorUnits,
      description: 'طلب رقم ${widget.orderNumber}',
      metadata: {
        'order_id': widget.orderId.toString(),
      },
    );
  }

  void _onPaymentResult(dynamic result) {
    debugPrint('NativePaymentScreen: received result: $result (${result.runtimeType})');
    if (result is PaymentResponse) {
      if (result.status == PaymentStatus.paid ||
          result.status == PaymentStatus.authorized ||
          result.status == PaymentStatus.captured) {
        Navigator.of(context).pop(result.id);
        return;
      }
      if (result.id.isNotEmpty && result.status != PaymentStatus.failed) {
        Navigator.of(context).pop(result.id);
        return;
      }
    } else if (result is Map) {
      final id = result['id']?.toString();
      if (id != null && id.isNotEmpty) {
        Navigator.of(context).pop(id);
        return;
      }
    }
    try {
      final dynamic dyn = result;
      final String? id = dyn?.id?.toString();
      if (id != null && id.isNotEmpty) {
        Navigator.of(context).pop(id);
        return;
      }
    } catch (_) {}

    // Show error message so user can see why it failed
    String errorMsg = 'تعذر إتمام الدفع بالبطاقة، يرجى التأكد من البيانات أو المحاولة ببطاقة أخرى';
    try {
      final dynamic dyn = result;
      if (dyn?.message != null) {
        errorMsg = dyn.message.toString();
      }
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isStcPay ? 'الدفع عبر STC Pay' : 'الدفع الآمن بالبطاقة',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'إلغاء',
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Order Summary Card ────────────────────────────────────────
            _buildOrderSummaryCard(theme, cs),
            const SizedBox(height: 24),

            // ── Payment Widget (Card or STC Pay) ─────────────────────────
            if (_isStcPay)
              STCPay(
                config: _paymentConfig,
                onPaymentResult: _onPaymentResult,
              )
            else
              CreditCard(
                config: _paymentConfig,
                onPaymentResult: _onPaymentResult,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رقم الطلب',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                widget.orderNumber,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبلغ الإجمالي',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '${widget.totalAmount.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
