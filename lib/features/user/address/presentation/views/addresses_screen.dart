import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/core/routes/routes.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../domain/entities/address_entity.dart';
import '../manager/address_cubit.dart';
import '../manager/address_state.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          s.addr_my_addresses,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<AddressCubit, AddressState>(
        listenWhen: (_, s) => s is AddressOperationSuccess || s is AddressError,
        listener: (context, state) {
          if (state is AddressOperationSuccess) {
            _showSnack(
              context,
              _localizedOpMsg(s, state.message),
              isError: false,
            );
          } else if (state is AddressError) {
            _showSnack(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = _getAddresses(state);

          if (addresses.isEmpty && state is! AddressLoading) {
            return _buildEmpty(context, theme, cs, s);
          }

          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: addresses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return FadeInUp(
                    duration: Duration(milliseconds: 300 + index * 80),
                    child: _AddressCard(
                      address: addresses[index],
                      onEdit: () =>
                          _openForm(context, address: addresses[index]),
                      onDelete: () =>
                          _confirmDelete(context, addresses[index], s),
                      onSetDefault: () => context
                          .read<AddressCubit>()
                          .setDefault(addresses[index].id),
                    ),
                  );
                },
              ),
              // Operation loading overlay
              if (state is AddressOperationLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMapPicker(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(S.of(context).addr_add_new),
      ),
    );
  }

  List<AddressEntity> _getAddresses(AddressState state) {
    if (state is AddressLoaded) return state.addresses;
    if (state is AddressOperationSuccess) return state.addresses;
    if (state is AddressOperationLoading) {
      // Keep previous addresses visible during loading
      final cubit = context.read<AddressCubit>();
      final prev = cubit.state;
      if (prev is AddressLoaded) return prev.addresses;
      if (prev is AddressOperationSuccess) return prev.addresses;
    }
    return [];
  }

  void _openMapPicker(BuildContext context) async {
    final result = await context.push<Map<String, dynamic>>(Routes.mapPicker);
    if (result != null && context.mounted) {
      final cubit = context.read<AddressCubit>();
      context.push(Routes.addressForm, extra: {...result, '_cubit': cubit});
    }
  }

  void _openForm(BuildContext ctx, {required AddressEntity address}) {
    final cubit = ctx.read<AddressCubit>();
    ctx.push(Routes.addressForm, extra: {'edit': address, '_cubit': cubit});
  }

  void _confirmDelete(BuildContext ctx, AddressEntity addr, S s) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(s.addr_delete_title),
        content: Text(s.addr_delete_confirm(addr.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ctx.read<AddressCubit>().deleteAddress(addr.id);
            },
            child: Text(s.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg, {required bool isError}) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Theme.of(ctx).colorScheme.error
            : Theme.of(ctx).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _localizedOpMsg(S s, String key) {
    switch (key) {
      case 'addr_saved_success':
        return s.addr_saved_success;
      case 'addr_updated_success':
        return s.addr_updated_success;
      case 'addr_deleted_success':
        return s.addr_deleted_success;
      case 'addr_default_set':
        return s.addr_default_set;
      default:
        return key;
    }
  }

  Widget _buildEmpty(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    S s,
  ) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 64,
                color: cs.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.addr_empty_title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                s.addr_empty_subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openMapPicker(context),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: Text(s.addr_add_new),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Address Card ─────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isDefault
              ? cs.primary.withOpacity(0.4)
              : cs.outlineVariant.withOpacity(0.6),
          width: address.isDefault ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Label icon + title
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconForTitle(address.title),
                      color: cs.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      address.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Default badge
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.addr_is_default,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // 3-dot menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                      if (value == 'default') onSetDefault();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(s.edit_profile),
                          ],
                        ),
                      ),
                      if (!address.isDefault)
                        PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16),
                              const SizedBox(width: 8),
                              Text(s.addr_set_default),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Address text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address.fullAddress.isNotEmpty
                          ? address.fullAddress
                          : address.shortDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (address.buildingNumber.isNotEmpty ||
                  address.floor.isNotEmpty ||
                  address.apartment.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      [
                        if (address.buildingNumber.isNotEmpty)
                          '${s.addr_building}: ${address.buildingNumber}',
                        if (address.floor.isNotEmpty)
                          '${s.addr_floor}: ${address.floor}',
                        if (address.apartment.isNotEmpty)
                          '${s.addr_apartment}: ${address.apartment}',
                      ].join(' · '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('home') || t.contains('منزل') || t.contains('بيت')) {
      return Icons.home_rounded;
    }
    if (t.contains('work') || t.contains('office') || t.contains('عمل')) {
      return Icons.work_rounded;
    }
    return Icons.location_pin;
  }
}
