import 'package:flutter/material.dart';
import 'payment_gateway.dart';
import 'payment_request.dart';
import 'payment_result.dart';
import 'payment_status.dart';

class PaymentService {
  final Map<String, PaymentGateway> _gateways = {};

  void registerGateway(PaymentGateway gateway) {
    _gateways[gateway.name] = gateway;
  }

  Future<PaymentResult> processPayment(BuildContext context, String gatewayName, PaymentRequest request) async {
    final gateway = _gateways[gatewayName];
    if (gateway == null) {
      return PaymentResult(
        status: AppPaymentStatus.failed,
        errorMessage: 'بوابة الدفع غير مدعومة حالياً ($gatewayName)',
      );
    }
    return await gateway.processPayment(context, request);
  }
}
