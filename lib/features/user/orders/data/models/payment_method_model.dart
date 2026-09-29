import '../../domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({
    required super.id,
    required super.name,
    required super.code,
    required super.paymentType,
    required super.provider,
    required super.isInstallment,
    required super.maxInstallments,
    required super.description,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      paymentType: json['payment_type'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      isInstallment: json['is_installment'] as bool? ?? false,
      maxInstallments: json['max_installments'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  PaymentMethodEntity toDomain() => PaymentMethodEntity(
        id: id,
        name: name,
        code: code,
        paymentType: paymentType,
        provider: provider,
        isInstallment: isInstallment,
        maxInstallments: maxInstallments,
        description: description,
      );
}
