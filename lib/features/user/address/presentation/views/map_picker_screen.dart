import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';

/// Full-screen interactive Google Maps location picker.
/// Returns a [Map<String, dynamic>] with geocoded address data on confirm.
class MapPickerScreen extends StatefulWidget {
  /// If provided, the map opens on this position (for editing).
  final LatLng? initialPosition;

  const MapPickerScreen({super.key, this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Default center: Riyadh, KSA
  static const LatLng _riyadh = LatLng(24.7136, 46.6753);

  GoogleMapController? _mapController;
  LatLng _center = _riyadh;

  bool _isGeocoding = false;
  bool _permissionDenied = false;
  bool _gpsDisabled = false;
  bool _isDragging = false;
  bool _hasResult = false;

  String _addressPreview = '';
  String _city = '';
  String _street = '';
  String _district = '';
  String _postalCode = '';
  String _country = '';
  int _countryId = 1;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _center = widget.initialPosition ?? _riyadh;
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Location Permission & GPS ────────────────────────────────────────────

  Future<void> _initLocation() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      if (result.isPermanentlyDenied) {
        setState(() => _permissionDenied = true);
        return;
      }
      if (result.isDenied) {
        setState(() => _permissionDenied = true);
        return;
      }
    }
    if (status.isPermanentlyDenied) {
      setState(() => _permissionDenied = true);
      return;
    }

    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      setState(() => _gpsDisabled = true);
      return;
    }

    if (widget.initialPosition == null) {
      await _goToCurrentLocation();
    } else {
      _reverseGeocode(_center);
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      setState(() => _isGeocoding = true);
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final newPos = LatLng(position.latitude, position.longitude);
      _center = newPos;
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 16),
        ),
      );
      await _reverseGeocode(newPos);
    } catch (_) {
      // Fall back to default center silently
      setState(() => _isGeocoding = false);
    }
  }

  // ─── Geocoding ────────────────────────────────────────────────────────────

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() {
      _isGeocoding = true;
      _hasResult = false;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      ).timeout(const Duration(seconds: 8));

      if (placemarks.isEmpty) {
        setState(() {
          _isGeocoding = false;
          _city = 'الرياض';
          _street = 'الشارع العام';
          _addressPreview = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        });
        return;
      }

      final p = placemarks.first;
      final parts = [
        p.name,
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.country,
      ].where((e) => e != null && e.isNotEmpty).toList();

      setState(() {
        _city = (p.locality?.isNotEmpty == true)
            ? p.locality!
            : ((p.administrativeArea?.isNotEmpty == true) ? p.administrativeArea! : 'الرياض');
        _street = (p.street?.isNotEmpty == true)
            ? p.street!
            : ((p.thoroughfare?.isNotEmpty == true)
                ? p.thoroughfare!
                : ((p.subLocality?.isNotEmpty == true) ? p.subLocality! : 'الشارع العام'));
        _district = p.subLocality ?? p.subAdministrativeArea ?? '';
        _postalCode = p.postalCode ?? '';
        _country = p.country ?? '';
        _countryId = 1;
        _addressPreview = parts.take(4).join(', ');
        _isGeocoding = false;
        _hasResult = true;
      });
    } on TimeoutException {
      setState(() {
        _isGeocoding = false;
        _city = 'الرياض';
        _street = 'الشارع العام';
        _addressPreview = S.of(context).addr_geocoding_failed;
      });
    } catch (_) {
      setState(() {
        _isGeocoding = false;
        _city = 'الرياض';
        _street = 'الشارع العام';
        _addressPreview = S.of(context).addr_geocoding_failed;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
    if (!_isDragging) {
      setState(() {
        _isDragging = true;
        _hasResult = false;
      });
    }
    _debounce?.cancel();
  }

  void _onCameraIdle() {
    setState(() => _isDragging = false);
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _reverseGeocode(_center);
    });
  }

  void _confirm() {
    Navigator.of(context).pop({
      'latitude': _center.latitude,
      'longitude': _center.longitude,
      'fullAddress': _addressPreview,
      'city': _city,
      'street': _street,
      'district': _district,
      'postalCode': _postalCode,
      'country': _country,
      'countryId': _countryId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (c) => _mapController = c,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Center pin ────────────────────────────────────────────────────
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(
                0, _isDragging ? -20 : -24, 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 10,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Top bar (back + title) ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _MapButton(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: Text(
                          s.addr_title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Current location button ────────────────────────────────────
          Positioned(
            bottom: 240,
            right: 16,
            child: _MapButton(
              onTap: _goToCurrentLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // ── Permission / GPS error banners ─────────────────────────────
          if (_permissionDenied)
            _buildErrorBanner(
              context,
              icon: Icons.location_disabled_rounded,
              message: s.addr_permission_denied,
              action: s.addr_open_settings,
              onAction: () => openAppSettings(),
            ),
          if (_gpsDisabled && !_permissionDenied)
            _buildErrorBanner(
              context,
              icon: Icons.gps_off_rounded,
              message: s.addr_gps_disabled,
              action: s.addr_enable_gps,
              onAction: () async {
                await Geolocator.openLocationSettings();
                setState(() => _gpsDisabled = false);
                await _initLocation();
              },
            ),

          // ── Bottom address preview sheet ───────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(context, theme, cs, s, mediaQuery),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    S s,
    MediaQueryData mq,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + mq.viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Address preview
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isGeocoding || _isDragging
                    ? Shimmer.fromColors(
                        baseColor: cs.surfaceContainerHighest,
                        highlightColor: cs.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 14,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasResult
                                ? s.addr_confirm_location
                                : s.addr_searching,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _addressPreview.isNotEmpty
                                ? _addressPreview
                                : '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGeocoding ? null : _confirm,
              child: Text(s.addr_confirm_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String action,
    required VoidCallback onAction,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: cs.onErrorContainer)),
            ),
            TextButton(
              onPressed: onAction,
              child: Text(action, style: TextStyle(color: cs.error)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular floating button for the map overlay.
class _MapButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _MapButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            child: child,
          ),
        ),
      ),
    );
  }
}
