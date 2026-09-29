import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/address_usecases.dart';
import 'address_state.dart';

@injectable
class AddressCubit extends Cubit<AddressState> {
  final GetAddressesUseCase _getAddresses;
  final CreateAddressUseCase _createAddress;
  final UpdateAddressUseCase _updateAddress;
  final DeleteAddressUseCase _deleteAddress;
  final SetDefaultAddressUseCase _setDefault;

  // Local list to update optimistically without re-fetching.
  List<AddressEntity> _addresses = [];

  AddressCubit({
    required GetAddressesUseCase getAddresses,
    required CreateAddressUseCase createAddress,
    required UpdateAddressUseCase updateAddress,
    required DeleteAddressUseCase deleteAddress,
    required SetDefaultAddressUseCase setDefault,
  })  : _getAddresses = getAddresses,
        _createAddress = createAddress,
        _updateAddress = updateAddress,
        _deleteAddress = deleteAddress,
        _setDefault = setDefault,
        super(const AddressInitial());

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadAddresses() async {
    emit(const AddressLoading());
    final result = await _getAddresses();
    result.fold(
      (failure) => emit(AddressError(failure.error.message)),
      (list) {
        _addresses = list;
        emit(AddressLoaded(List.unmodifiable(_addresses)));
      },
    );
  }

  // ─── Create ────────────────────────────────────────────────────────────────

  Future<void> createAddress(AddressParams params) async {
    emit(const AddressOperationLoading('create'));
    final result = await _createAddress(params);
    result.fold(
      (failure) => emit(AddressError(failure.error.message)),
      (created) {
        _addresses = [created, ..._addresses];
        // If new address is default, clear other defaults
        if (created.isDefault) {
          _addresses = _addresses
              .map((a) => a.id == created.id ? a : a.copyWith(isDefault: false))
              .toList();
        }
        emit(AddressOperationSuccess(
          message: 'addr_saved_success',
          addresses: List.unmodifiable(_addresses),
        ));
      },
    );
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<void> updateAddress(UpdateAddressParams params) async {
    emit(const AddressOperationLoading('update'));
    final result = await _updateAddress(params);
    result.fold(
      (failure) => emit(AddressError(failure.error.message)),
      (updated) {
        _addresses = _addresses.map((a) {
          if (a.id == updated.id) return updated;
          if (updated.isDefault) return a.copyWith(isDefault: false);
          return a;
        }).toList();
        emit(AddressOperationSuccess(
          message: 'addr_updated_success',
          addresses: List.unmodifiable(_addresses),
        ));
      },
    );
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteAddress(int id) async {
    emit(const AddressOperationLoading('delete'));
    final result = await _deleteAddress(id);
    result.fold(
      (failure) => emit(AddressError(failure.error.message)),
      (_) {
        _addresses = _addresses.where((a) => a.id != id).toList();
        emit(AddressOperationSuccess(
          message: 'addr_deleted_success',
          addresses: List.unmodifiable(_addresses),
        ));
      },
    );
  }

  // ─── Set Default ───────────────────────────────────────────────────────────

  Future<void> setDefault(int id) async {
    emit(const AddressOperationLoading('setDefault'));
    final result = await _setDefault(id);
    result.fold(
      (failure) => emit(AddressError(failure.error.message)),
      (_) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
        emit(AddressOperationSuccess(
          message: 'addr_default_set',
          addresses: List.unmodifiable(_addresses),
        ));
      },
    );
  }
}
