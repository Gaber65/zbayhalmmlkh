import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/address_usecases.dart';
import '../manager/address_cubit.dart';
import '../manager/address_state.dart';

/// Address details form — opened after map picker OR when editing an address.
///
/// [extra] must be a map containing location or edit data:
///   - From map picker: {latitude, longitude, fullAddress, city, street, district, postalCode, country, countryId}
///   - From edit: {'edit': AddressEntity}
class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic> extra;

  const AddressFormScreen({super.key, required this.extra});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  // ── Controllers ─────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _buildingCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _apartmentCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _otherLabelCtrl = TextEditingController();
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();

  // ── State ────────────────────────────────────────────────────────────────
  String _selectedLabel = 'home'; // 'home' | 'work' | 'other'
  bool _isDefault = false;
  bool _isEdit = false;
  AddressEntity? _editAddress;

  // ── Geocode data ─────────────────────────────────────────────────────────
  late double _latitude;
  late double _longitude;
  late String _fullAddress;
  late String _district;
  late String _postalCode;
  late int _countryId;

  @override
  void initState() {
    super.initState();
    _initFromExtra();
  }

  void _initFromExtra() {
    final edit = widget.extra['edit'] as AddressEntity?;

    if (edit != null) {
      // ── Edit mode ─────────────────────────────────────────────────────
      _isEdit = true;
      _editAddress = edit;
      _latitude = edit.latitude;
      _longitude = edit.longitude;
      _fullAddress = edit.fullAddress;
      _cityCtrl.text = edit.city.isNotEmpty ? edit.city : 'الرياض';
      _streetCtrl.text = edit.street.isNotEmpty ? edit.street : 'الشارع العام';
      _district = edit.district;
      _postalCode = edit.postalCode;
      _countryId = edit.countryId;
      _buildingCtrl.text = edit.buildingNumber;
      _floorCtrl.text = edit.floor;
      _apartmentCtrl.text = edit.apartment;
      _landmarkCtrl.text = edit.landmark;
      _notesCtrl.text = edit.notes;
      _recipientNameCtrl.text = edit.recipientName;
      _recipientPhoneCtrl.text = edit.recipientPhone;
      _isDefault = edit.isDefault;

      final t = edit.title.toLowerCase();
      if (t == 'home' || t == 'منزل' || t == 'بيت') {
        _selectedLabel = 'home';
      } else if (t == 'work' || t == 'عمل' || t == 'office') {
        _selectedLabel = 'work';
      } else {
        _selectedLabel = 'other';
        _otherLabelCtrl.text = edit.title;
      }
    } else {
      // ── Create mode (from map picker) ─────────────────────────────────
      _latitude = (widget.extra['latitude'] as num?)?.toDouble() ?? 0.0;
      _longitude = (widget.extra['longitude'] as num?)?.toDouble() ?? 0.0;
      _fullAddress = widget.extra['fullAddress'] as String? ?? '';
      final rawCity = widget.extra['city'] as String? ?? '';
      final rawStreet = widget.extra['street'] as String? ?? '';
      _cityCtrl.text = rawCity.isNotEmpty ? rawCity : 'الرياض';
      _streetCtrl.text = rawStreet.isNotEmpty ? rawStreet : 'الشارع العام';
      _district = widget.extra['district'] as String? ?? '';
      _postalCode = widget.extra['postalCode'] as String? ?? '';
      _countryId = (widget.extra['countryId'] as num?)?.toInt() ?? 1;
    }
  }

  String get _resolvedTitle {
    switch (_selectedLabel) {
      case 'home':
        return S.of(context).addr_label_home;
      case 'work':
        return S.of(context).addr_label_work;
      default:
        return _otherLabelCtrl.text.trim().isNotEmpty
            ? _otherLabelCtrl.text.trim()
            : S.of(context).addr_label_other;
    }
  }

  @override
  void dispose() {
    _buildingCtrl.dispose();
    _floorCtrl.dispose();
    _apartmentCtrl.dispose();
    _landmarkCtrl.dispose();
    _notesCtrl.dispose();
    _otherLabelCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    super.dispose();
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  void _save(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;

    final city = _cityCtrl.text.trim().isNotEmpty
        ? _cityCtrl.text.trim()
        : 'الرياض';
    final street = _streetCtrl.text.trim().isNotEmpty
        ? _streetCtrl.text.trim()
        : 'الشارع العام';

    final params = _isEdit
        ? UpdateAddressParams(
            id: _editAddress!.id,
            title: _resolvedTitle,
            recipientName: _recipientNameCtrl.text.trim(),
            recipientPhone: _recipientPhoneCtrl.text.trim(),
            countryId: _countryId,
            city: city,
            street: street,
            district: _district,
            postalCode: _postalCode,
            fullAddress: _fullAddress.isNotEmpty
                ? _fullAddress
                : '$city, $street',
            buildingNumber: _buildingCtrl.text.trim(),
            floor: _floorCtrl.text.trim(),
            apartment: _apartmentCtrl.text.trim(),
            landmark: _landmarkCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
            isDefault: _isDefault,
          )
        : AddressParams(
            title: _resolvedTitle,
            recipientName: _recipientNameCtrl.text.trim(),
            recipientPhone: _recipientPhoneCtrl.text.trim(),
            countryId: _countryId,
            city: city,
            street: street,
            district: _district,
            postalCode: _postalCode,
            fullAddress: _fullAddress.isNotEmpty
                ? _fullAddress
                : '$city, $street',
            buildingNumber: _buildingCtrl.text.trim(),
            floor: _floorCtrl.text.trim(),
            apartment: _apartmentCtrl.text.trim(),
            landmark: _landmarkCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            latitude: _latitude,
            longitude: _longitude,
            isDefault: _isDefault,
          );

    if (_isEdit) {
      ctx.read<AddressCubit>().updateAddress(params as UpdateAddressParams);
    } else {
      ctx.read<AddressCubit>().createAddress(params);
    }
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
          _isEdit ? s.addr_edit_address : s.addr_add_new,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<AddressCubit, AddressState>(
        listenWhen: (_, s) => s is AddressOperationSuccess || s is AddressError,
        listener: (context, state) {
          if (state is AddressOperationSuccess) {
            // Pop back to addresses list — it will pick up the new state.
            context.pop();
          } else if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddressOperationLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Map preview chip ───────────────────────────────
                      _buildMapPreviewChip(context, cs, theme, s),
                      const SizedBox(height: 24),

                      // ── Address label selector ─────────────────────────
                      _buildSectionTitle(s.addr_label_title, theme),
                      const SizedBox(height: 10),
                      _buildLabelSelector(cs, theme, s),
                      if (_selectedLabel == 'other') ...[
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _otherLabelCtrl,
                          label: s.addr_label_other_hint,
                          icon: Icons.edit_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? s.addr_required
                              : null,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── Recipient ──────────────────────────────────────
                      _buildSectionTitle(s.addr_recipient_section, theme),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _recipientNameCtrl,
                        label: s.addr_recipient_name,
                        icon: Icons.person_outline_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.addr_required
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _recipientPhoneCtrl,
                        label: s.addr_recipient_phone,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cityCtrl,
                              label: s.addr_city,
                              icon: Icons.location_city_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? s.addr_required
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _streetCtrl,
                              label: s.addr_street,
                              icon: Icons.add_road_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? s.addr_required
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Building details ───────────────────────────────
                      _buildSectionTitle(s.addr_building_section, theme),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _buildingCtrl,
                              label: s.addr_building,
                              icon: Icons.domain_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _floorCtrl,
                              label: s.addr_floor,
                              icon: Icons.layers_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _apartmentCtrl,
                        label: s.addr_apartment,
                        icon: Icons.apartment_rounded,
                      ),
                      const SizedBox(height: 24),

                      // ── Additional info ────────────────────────────────
                      _buildSectionTitle(s.addr_additional_section, theme),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _landmarkCtrl,
                        label: s.addr_landmark,
                        icon: Icons.place_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _notesCtrl,
                        label: s.addr_notes,
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // ── Default switch ─────────────────────────────────
                      _buildDefaultSwitch(cs, theme, s),
                    ],
                  ),
                ),
              ),

              // ── Loading overlay ──────────────────────────────────────────
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.15),
                  child: const Center(child: CircularProgressIndicator()),
                ),

              // ── Save button ──────────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    16 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(
                      top: BorderSide(color: cs.outlineVariant, width: 0.8),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _save(context),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(s.save_changes),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Builders ─────────────────────────────────────────────────────────────

  Widget _buildMapPreviewChip(
    BuildContext ctx,
    ColorScheme cs,
    ThemeData theme,
    S s,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.addr_full_address,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fullAddress.isNotEmpty
                      ? _fullAddress
                      : '${_latitude.toStringAsFixed(5)}, ${_longitude.toStringAsFixed(5)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLabelSelector(ColorScheme cs, ThemeData theme, S s) {
    final labels = [
      ('home', Icons.home_rounded, s.addr_label_home),
      ('work', Icons.work_rounded, s.addr_label_work),
      ('other', Icons.more_horiz_rounded, s.addr_label_other),
    ];

    return Row(
      children: labels.map((entry) {
        final (key, icon, label) = entry;
        final selected = _selectedLabel == key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedLabel = key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? cs.primary : cs.outlineVariant,
                    width: selected ? 0 : 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildDefaultSwitch(ColorScheme cs, ThemeData theme, S s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          s.addr_set_default,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          s.addr_set_default_hint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        value: _isDefault,
        onChanged: (v) => setState(() => _isDefault = v),
        activeThumbColor: cs.primary,
      ),
    );
  }
}
