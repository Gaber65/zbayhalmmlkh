import 'package:flutter/material.dart';
import 'payment_request.dart';
import 'payment_result.dart';

abstract class PaymentGateway {
  String get name;
  Future<PaymentResult> processPayment(BuildContext context, PaymentRequest request);
}
