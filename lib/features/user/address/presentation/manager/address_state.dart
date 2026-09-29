import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class AddressOperationLoading extends AddressState {
  final String operation; // 'create' | 'update' | 'delete' | 'setDefault'
  const AddressOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class AddressOperationSuccess extends AddressState {
  final String message;
  final List<AddressEntity> addresses;

  const AddressOperationSuccess({required this.message, required this.addresses});

  @override
  List<Object?> get props => [message, addresses];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
