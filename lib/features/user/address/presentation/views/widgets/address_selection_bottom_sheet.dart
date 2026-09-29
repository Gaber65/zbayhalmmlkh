import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../../domain/entities/address_entity.dart';
import '../../manager/address_cubit.dart';
import '../../manager/address_state.dart';
import '../../../domain/services/fulfillment_service.dart';

/// Modal bottom sheet for switching between Home Delivery (saved addresses)
/// and Store Branch Pickup.
class AddressSelectionBottomSheet extends StatefulWidget {
  final String? initialLocation;

  const AddressSelectionBottomSheet({super.key, this.initialLocation});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? initialLocation,
    AddressCubit? cubit,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final content = AddressSelectionBottomSheet(
          initialLocation: initialLocation,
        );
        return cubit != null
            ? BlocProvider.value(value: cubit, child: content)
            : content;
      },
    );
  }

  @override
  State<AddressSelectionBottomSheet> createState() =>
      _AddressSelectionBottomSheetState();
}

class _AddressSelectionBottomSheetState
    extends State<AddressSelectionBottomSheet> {
  int _modeIndex = 0; // 0 = Home Delivery, 1 = Store Pickup
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Load addresses if cubit is available
    final cubit = context.read<AddressCubit?>();
    if (cubit != null && cubit.state is! AddressLoaded) {
      cubit.loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.addr_select_delivery_type,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mode Selector Toggle (Home Delivery vs Store Pickup)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildModeToggle(cs, theme, s),
            ),
            const SizedBox(height: 20),

            // Tab Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _modeIndex == 0
                    ? _buildDeliveryTab(cs, theme, s)
                    : _buildPickupTab(cs, theme, s),
              ),
            ),

            const SizedBox(height: 16),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  child: Text(s.addr_confirm_selection),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mode Toggle ─────────────────────────────────────────────────────────────

  Widget _buildModeToggle(ColorScheme cs, ThemeData theme, S s) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              index: 0,
              icon: Icons.delivery_dining_rounded,
              label: s.addr_delivery,
              cs: cs,
              theme: theme,
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              index: 1,
              icon: Icons.storefront_rounded,
              label: s.addr_pickup,
              cs: cs,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required int index,
    required IconData icon,
    required String label,
    required ColorScheme cs,
    required ThemeData theme,
  }) {
    final selected = _modeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _modeIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Home Delivery Tab ───────────────────────────────────────────────────────

  Widget _buildDeliveryTab(ColorScheme cs, ThemeData theme, S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.addr_select_address,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: _addNewAddress,
              icon: const Icon(Icons.add_location_alt_rounded, size: 16),
              label: Text(
                s.addr_add_new_short,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final addresses = _getAddresses(state);

            if (addresses.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 40,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.addr_empty_title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.addr_empty_subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final addr = addresses[index];
                final isSelected =
                    (_selectedAddressId == null && addr.isDefault) ||
                    _selectedAddressId == addr.id;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedAddressId = addr.id);
                    if (!addr.isDefault) {
                      context.read<AddressCubit>().setDefault(addr.id);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.06)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? cs.primary
                            : cs.outlineVariant.withValues(alpha: 0.6),
                        width: isSelected ? 1.8 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: addr.id,
                          groupValue:
                              _selectedAddressId ??
                              addresses
                                  .firstWhere(
                                    (a) => a.isDefault,
                                    orElse: () => addresses.first,
                                  )
                                  .id,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedAddressId = val);
                              context.read<AddressCubit>().setDefault(val);
                            }
                          },
                          activeColor: cs.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    addr.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (addr.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        s.addr_is_default,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: cs.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                addr.fullAddress.isNotEmpty
                                    ? addr.fullAddress
                                    : addr.shortDisplay,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ── Store Pickup Tab ────────────────────────────────────────────────────────

  Widget _buildPickupTab(ColorScheme cs, ThemeData theme, S s) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.addr_pickup,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'استلام الطلب مباشرة من الفرع دون أي رسوم توصيل إضافية',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  // ── Helpers & Handlers ─────────────────────────────────────────────────────

  List<AddressEntity> _getAddresses(AddressState state) {
    if (state is AddressLoaded) return state.addresses;
    if (state is AddressOperationSuccess) return state.addresses;
    return [];
  }

  void _addNewAddress() async {
    final nav = Navigator.of(context);
    nav.pop(); // Close bottom sheet first
    final result = await context.push<Map<String, dynamic>>(Routes.mapPicker);
    if (result != null && mounted) {
      final cubit = context.read<AddressCubit?>();
      context.push(Routes.addressForm, extra: {...result, '_cubit': ?cubit});
    }
  }

  void _onConfirm() async {
    if (_modeIndex == 0) {
      // Home Delivery mode
      final state = context.read<AddressCubit?>()?.state;
      final addresses = _getAddresses(state ?? const AddressInitial());

      final selectedAddr = addresses.firstWhere(
        (a) => a.id == _selectedAddressId,
        orElse: () => addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.isNotEmpty
              ? addresses.first
              : const AddressEntity(
                  id: 0,
                  title: 'Home',
                  recipientName: '',
                  recipientPhone: '',
                  countryId: 1,
                  countryName: '',
                  city: 'الرياض',
                  street: 'السعودية',
                  district: '',
                  postalCode: '',
                  fullAddress: 'الرياض، السعودية',
                  buildingNumber: '',
                  floor: '',
                  apartment: '',
                  landmark: '',
                  notes: '',
                  latitude: 24.7136,
                  longitude: 46.6753,
                  isDefault: true,
                ),
        ),
      );

      final displayText = selectedAddr.shortDisplay.isNotEmpty
          ? selectedAddr.shortDisplay
          : selectedAddr.fullAddress;

      await FulfillmentService.saveHomeDelivery(
        addressId: selectedAddr.id,
        displayAddress: displayText,
      );

      if (mounted) {
        Navigator.pop(context, {
          'mode': 'delivery',
          'displayText': displayText,
          'address': selectedAddr,
        });
      }
    } else {
      // Store Pickup mode
      final displayText = S.of(context).addr_pickup;

      await FulfillmentService.saveStorePickup(
        branchName: displayText,
        branchAddress: '',
      );

      if (mounted) {
        Navigator.pop(context, {'mode': 'pickup', 'displayText': displayText});
      }
    }
  }
}
