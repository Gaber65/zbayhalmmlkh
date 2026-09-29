import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String paymentType;
  final String provider;
  final bool isInstallment;
  final int maxInstallments;
  final String description;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.paymentType,
    required this.provider,
    required this.isInstallment,
    required this.maxInstallments,
    required this.description,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        paymentType,
        provider,
        isInstallment,
        maxInstallments,
        description,
      ];
}
