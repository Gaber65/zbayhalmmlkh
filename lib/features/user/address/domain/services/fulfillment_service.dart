import 'package:shared_preferences/shared_preferences.dart';

/// Helper service to save and retrieve the user's selected fulfillment mode
/// (Home Delivery vs Store Branch Pickup) and active branch / address data.
class FulfillmentService {
  static const String _keyMode = 'fulfillment_mode'; // 'delivery' | 'pickup'
  static const String _keyBranchName = 'selected_branch_name';
  static const String _keyBranchAddress = 'selected_branch_address';
  static const String _keyLocationDisplay = 'selected_location_display';
  static const String _keyAddressId = 'selected_address_id';

  /// Save store pickup selection
  static Future<void> saveStorePickup({
    String branchName = '',
    String branchAddress = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, 'pickup');
    await prefs.setString(_keyBranchName, branchName);
    await prefs.setString(_keyBranchAddress, branchAddress);
    await prefs.setString(
      _keyLocationDisplay,
      'الاستلام من الفرع',
    );
  }

  /// Save home delivery selection
  static Future<void> saveHomeDelivery({
    required int addressId,
    required String displayAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, 'delivery');
    await prefs.setInt(_keyAddressId, addressId);
    await prefs.setString(_keyLocationDisplay, displayAddress);
  }

  /// Check if active mode is Store Pickup
  static Future<bool> isStorePickup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMode) == 'pickup';
  }

  /// Get active fulfillment mode ('delivery' | 'pickup')
  static Future<String> getFulfillmentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMode) ?? 'delivery';
  }

  /// Get selected branch details (name, address)
  static Future<Map<String, String>?> getSelectedBranch() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyBranchName);
    final address = prefs.getString(_keyBranchAddress);
    if (name == null || name.isEmpty) return null;
    return {
      'name': name,
      'address': address ?? '',
    };
  }

  /// Get persistent display location text for home header & cart
  static Future<String?> getDisplayLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocationDisplay);
  }
}
