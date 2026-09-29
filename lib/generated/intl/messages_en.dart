// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "Added ${count} item(s) to cart";

  static String m1(label) => "Delete \"${label}\"? This cannot be undone.";

  static String m2(points) => "Available points: ${points}";

  static String m3(count) => "Cart with ${count} items";

  static String m4(count) => "${count} items";

  static String m5(query) => "No results found for \"${query}\"";

  static String m6(price) => "Order Online  •  ${price} SAR";

  static String m7(count) => "${count} Points";

  static String m8(count) => "4.7 stars (${count} reviews)";

  static String m9(value) => "${value} SAR";

  static String m10(amount) => "Save ${amount} SAR";

  static String m11(count) => "Fresh Cut (${count})";

  static String m12(count) => "Popular (${count})";

  static String m13(count) => "Special (${count})";

  static String m14(count) => "${count} Kg";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "active_orders": MessageLookupByLibrary.simpleMessage("Active"),
    "add_to_cart": MessageLookupByLibrary.simpleMessage("Add to Cart"),
    "added_to_cart": m0,
    "addr_add_new": MessageLookupByLibrary.simpleMessage("Add Address"),
    "addr_add_new_short": MessageLookupByLibrary.simpleMessage(
      "Add New Address",
    ),
    "addr_additional_section": MessageLookupByLibrary.simpleMessage(
      "Additional Information",
    ),
    "addr_apartment": MessageLookupByLibrary.simpleMessage("Apartment"),
    "addr_branch_hours": MessageLookupByLibrary.simpleMessage(
      "Open daily: 8:00 AM - 11:00 PM",
    ),
    "addr_branch_main": MessageLookupByLibrary.simpleMessage(
      "Main Branch - Riyadh",
    ),
    "addr_branch_rawdah": MessageLookupByLibrary.simpleMessage(
      "Al Rawdah Branch - Riyadh",
    ),
    "addr_branch_sahafa": MessageLookupByLibrary.simpleMessage(
      "Al Sahafa Branch - Riyadh",
    ),
    "addr_building": MessageLookupByLibrary.simpleMessage("Building"),
    "addr_building_section": MessageLookupByLibrary.simpleMessage(
      "Building Details",
    ),
    "addr_city": MessageLookupByLibrary.simpleMessage("City"),
    "addr_confirm_location": MessageLookupByLibrary.simpleMessage(
      "Confirm Location",
    ),
    "addr_confirm_selection": MessageLookupByLibrary.simpleMessage(
      "Confirm Selection",
    ),
    "addr_default_set": MessageLookupByLibrary.simpleMessage(
      "Default address updated",
    ),
    "addr_delete_confirm": m1,
    "addr_delete_title": MessageLookupByLibrary.simpleMessage("Delete Address"),
    "addr_deleted_success": MessageLookupByLibrary.simpleMessage(
      "Address deleted",
    ),
    "addr_delivery": MessageLookupByLibrary.simpleMessage("Home Delivery"),
    "addr_edit_address": MessageLookupByLibrary.simpleMessage("Edit Address"),
    "addr_empty_subtitle": MessageLookupByLibrary.simpleMessage(
      "Add your first delivery address to get started.",
    ),
    "addr_empty_title": MessageLookupByLibrary.simpleMessage(
      "No Saved Addresses",
    ),
    "addr_enable_gps": MessageLookupByLibrary.simpleMessage("Enable GPS"),
    "addr_floor": MessageLookupByLibrary.simpleMessage("Floor"),
    "addr_full_address": MessageLookupByLibrary.simpleMessage(
      "Selected Location",
    ),
    "addr_geocoding_failed": MessageLookupByLibrary.simpleMessage(
      "Could not detect address",
    ),
    "addr_gps_disabled": MessageLookupByLibrary.simpleMessage(
      "GPS is disabled",
    ),
    "addr_is_default": MessageLookupByLibrary.simpleMessage("Default"),
    "addr_label_home": MessageLookupByLibrary.simpleMessage("Home"),
    "addr_label_other": MessageLookupByLibrary.simpleMessage("Other"),
    "addr_label_other_hint": MessageLookupByLibrary.simpleMessage("Label name"),
    "addr_label_title": MessageLookupByLibrary.simpleMessage("Address Label"),
    "addr_label_work": MessageLookupByLibrary.simpleMessage("Work"),
    "addr_landmark": MessageLookupByLibrary.simpleMessage("Nearby Landmark"),
    "addr_my_addresses": MessageLookupByLibrary.simpleMessage("My Addresses"),
    "addr_network_error": MessageLookupByLibrary.simpleMessage(
      "Network error. Please try again.",
    ),
    "addr_notes": MessageLookupByLibrary.simpleMessage("Delivery Notes"),
    "addr_open_settings": MessageLookupByLibrary.simpleMessage("Open Settings"),
    "addr_permission_denied": MessageLookupByLibrary.simpleMessage(
      "Location permission denied",
    ),
    "addr_pickup": MessageLookupByLibrary.simpleMessage("Store Pickup"),
    "addr_recipient_name": MessageLookupByLibrary.simpleMessage(
      "Recipient Name",
    ),
    "addr_recipient_phone": MessageLookupByLibrary.simpleMessage(
      "Recipient Phone",
    ),
    "addr_recipient_section": MessageLookupByLibrary.simpleMessage(
      "Recipient Information",
    ),
    "addr_required": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "addr_saved_success": MessageLookupByLibrary.simpleMessage(
      "Address saved successfully",
    ),
    "addr_searching": MessageLookupByLibrary.simpleMessage(
      "Locating address...",
    ),
    "addr_select_address": MessageLookupByLibrary.simpleMessage(
      "Select Delivery Address",
    ),
    "addr_select_branch": MessageLookupByLibrary.simpleMessage(
      "Select Store Branch",
    ),
    "addr_select_delivery_type": MessageLookupByLibrary.simpleMessage(
      "Delivery Option",
    ),
    "addr_set_default": MessageLookupByLibrary.simpleMessage("Set as Default"),
    "addr_set_default_hint": MessageLookupByLibrary.simpleMessage(
      "Use this address as default delivery address",
    ),
    "addr_street": MessageLookupByLibrary.simpleMessage("Street / Road"),
    "addr_title": MessageLookupByLibrary.simpleMessage("Set Delivery Location"),
    "addr_updated_success": MessageLookupByLibrary.simpleMessage(
      "Address updated successfully",
    ),
    "addr_use_current": MessageLookupByLibrary.simpleMessage(
      "Current Location",
    ),
    "already_have_account": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "app_language": MessageLookupByLibrary.simpleMessage("App Language"),
    "app_name": MessageLookupByLibrary.simpleMessage("Dhabayih Lmamlaka"),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "apply_filters": MessageLookupByLibrary.simpleMessage("Apply Filters"),
    "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "available_points": m2,
    "badge_delivery_subtitle": MessageLookupByLibrary.simpleMessage("Same Day"),
    "badge_delivery_title": MessageLookupByLibrary.simpleMessage(
      "Fast Express",
    ),
    "badge_fresh_subtitle": MessageLookupByLibrary.simpleMessage("Farm Direct"),
    "badge_fresh_title": MessageLookupByLibrary.simpleMessage("100% Fresh"),
    "badge_hygienic_subtitle": MessageLookupByLibrary.simpleMessage(
      "Certified",
    ),
    "badge_hygienic_title": MessageLookupByLibrary.simpleMessage("Hygienic"),
    "best_sellers": MessageLookupByLibrary.simpleMessage("Best Sellers"),
    "branch_pickup": MessageLookupByLibrary.simpleMessage("Branch Pickup"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancel_order": MessageLookupByLibrary.simpleMessage("Cancel Order"),
    "cancel_order_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel this order?",
    ),
    "cancel_order_error": MessageLookupByLibrary.simpleMessage(
      "Failed to cancel order",
    ),
    "cancel_order_success": MessageLookupByLibrary.simpleMessage(
      "Order cancelled successfully",
    ),
    "cancelled_orders": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "cart_add_error": MessageLookupByLibrary.simpleMessage(
      "Failed to add product to cart",
    ),
    "cart_add_success": MessageLookupByLibrary.simpleMessage(
      "Product added to cart",
    ),
    "cart_empty": MessageLookupByLibrary.simpleMessage("Your cart is empty"),
    "cart_item_removed": MessageLookupByLibrary.simpleMessage(
      "Item removed from cart",
    ),
    "cart_semantics_count": m3,
    "cart_semantics_empty": MessageLookupByLibrary.simpleMessage("Empty Cart"),
    "cart_updated": MessageLookupByLibrary.simpleMessage(
      "Cart updated successfully",
    ),
    "cash_on_delivery": MessageLookupByLibrary.simpleMessage(
      "Cash on Delivery",
    ),
    "categories_title": MessageLookupByLibrary.simpleMessage("Categories"),
    "checkout": MessageLookupByLibrary.simpleMessage("Checkout"),
    "checkout_success": MessageLookupByLibrary.simpleMessage(
      "Order Placed Successfully",
    ),
    "checkout_title": MessageLookupByLibrary.simpleMessage("Checkout"),
    "confirm_order": MessageLookupByLibrary.simpleMessage("Confirm Order"),
    "continue_as_guest": MessageLookupByLibrary.simpleMessage(
      "Continue as Guest",
    ),
    "continue_shopping": MessageLookupByLibrary.simpleMessage(
      "Continue Shopping",
    ),
    "country_egypt": MessageLookupByLibrary.simpleMessage("Egypt 🇪🇬"),
    "coupon_applied": MessageLookupByLibrary.simpleMessage(
      "Coupon applied successfully",
    ),
    "coupon_code": MessageLookupByLibrary.simpleMessage("Coupon Code"),
    "coupon_hint": MessageLookupByLibrary.simpleMessage("Enter coupon code"),
    "coupon_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid coupon code",
    ),
    "crafted_by": MessageLookupByLibrary.simpleMessage(
      "Crafted with Luxury & Quality",
    ),
    "created_by": MessageLookupByLibrary.simpleMessage("Dhabayih Lmamlaka"),
    "current_location": MessageLookupByLibrary.simpleMessage(
      "Current Location",
    ),
    "custom_date": MessageLookupByLibrary.simpleMessage("Choose Date"),
    "cutting_halves": MessageLookupByLibrary.simpleMessage("Halves"),
    "cutting_options": MessageLookupByLibrary.simpleMessage("Cutting Options"),
    "cutting_quarters": MessageLookupByLibrary.simpleMessage("Quarters"),
    "cutting_small_pieces": MessageLookupByLibrary.simpleMessage(
      "Small Pieces",
    ),
    "cutting_whole": MessageLookupByLibrary.simpleMessage("Whole"),
    "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "default_location_mock": MessageLookupByLibrary.simpleMessage(
      "Riyadh, KSA",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delivery_fee": MessageLookupByLibrary.simpleMessage("Delivery Fee"),
    "delivery_schedule": MessageLookupByLibrary.simpleMessage(
      "Delivery Schedule",
    ),
    "delivery_to": MessageLookupByLibrary.simpleMessage("DELIVERY TO"),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "discount": MessageLookupByLibrary.simpleMessage("Discount"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "edit_profile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "email_hint": MessageLookupByLibrary.simpleMessage("hello@dhabayih.com"),
    "email_label": MessageLookupByLibrary.simpleMessage("Email"),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "english": MessageLookupByLibrary.simpleMessage("ENGLISH"),
    "error_retry": MessageLookupByLibrary.simpleMessage(
      "An error occurred. Tap to retry.",
    ),
    "excluded_parts": MessageLookupByLibrary.simpleMessage("Excluded Parts"),
    "explore_catalog": MessageLookupByLibrary.simpleMessage(
      "Explore our catalog and add items.",
    ),
    "fast_service": MessageLookupByLibrary.simpleMessage("Fast Service"),
    "featured_products": MessageLookupByLibrary.simpleMessage(
      "Featured Products",
    ),
    "filters": MessageLookupByLibrary.simpleMessage("Filters"),
    "fresh_daily": MessageLookupByLibrary.simpleMessage("Fresh Daily"),
    "fresh_harvest": MessageLookupByLibrary.simpleMessage(
      "Fresh Harvest -\nFrom Farm to Your Table",
    ),
    "general_settings": MessageLookupByLibrary.simpleMessage(
      "General Settings",
    ),
    "get_started": MessageLookupByLibrary.simpleMessage("Get Started"),
    "guest_subtitle": MessageLookupByLibrary.simpleMessage(
      "Login to access all features",
    ),
    "guest_user": MessageLookupByLibrary.simpleMessage("Guest User"),
    "halal_compliance": MessageLookupByLibrary.simpleMessage("100% Halal"),
    "hello_label": MessageLookupByLibrary.simpleMessage("Hello! "),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "home_address_mock": MessageLookupByLibrary.simpleMessage(
      "Home - Riyadh, KSA",
    ),
    "home_cta_subtitle": MessageLookupByLibrary.simpleMessage(
      "Enjoy premium quality, certified slaughtering, and refrigerated transport.",
    ),
    "home_cta_title": MessageLookupByLibrary.simpleMessage(
      "Premium Livestock Selection",
    ),
    "home_intro_subtitle": MessageLookupByLibrary.simpleMessage(
      "Explore premium fresh meats & groceries",
    ),
    "home_subtitle": MessageLookupByLibrary.simpleMessage(
      "Select your fresh livestock, custom cuts, and express delivery.",
    ),
    "home_title": MessageLookupByLibrary.simpleMessage("Dhabayih Lmamlaka"),
    "hot_tag": MessageLookupByLibrary.simpleMessage("HOT"),
    "in_stock": MessageLookupByLibrary.simpleMessage("In Stock"),
    "items_count": m4,
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "loading_product": MessageLookupByLibrary.simpleMessage(
      "Loading product...",
    ),
    "login_back": MessageLookupByLibrary.simpleMessage("Back"),
    "login_register": MessageLookupByLibrary.simpleMessage("Login / Register"),
    "login_required": MessageLookupByLibrary.simpleMessage("Login Required"),
    "login_required_desc": MessageLookupByLibrary.simpleMessage(
      "Please login to access this feature.",
    ),
    "login_subtitle": MessageLookupByLibrary.simpleMessage(
      "Enter your credentials to access your luxury shopping experience.",
    ),
    "login_welcome": MessageLookupByLibrary.simpleMessage("Welcome"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logout_confirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout?",
    ),
    "loyalty_discount": MessageLookupByLibrary.simpleMessage(
      "Loyalty Discount",
    ),
    "loyalty_points": MessageLookupByLibrary.simpleMessage("Loyalty Points"),
    "made_with_love": MessageLookupByLibrary.simpleMessage(
      "Made for Dhabayih Lmamlaka",
    ),
    "my_cart": MessageLookupByLibrary.simpleMessage("My Cart"),
    "name_label": MessageLookupByLibrary.simpleMessage("Name"),
    "new_season": MessageLookupByLibrary.simpleMessage("New Season"),
    "newest_arrivals": MessageLookupByLibrary.simpleMessage("Newest Arrivals"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "no_categories": MessageLookupByLibrary.simpleMessage(
      "No categories found.",
    ),
    "no_cutting_options": MessageLookupByLibrary.simpleMessage(
      "No cutting options available",
    ),
    "no_excluded_parts": MessageLookupByLibrary.simpleMessage(
      "No parts to exclude",
    ),
    "no_media_available": MessageLookupByLibrary.simpleMessage(
      "No media available",
    ),
    "no_orders": MessageLookupByLibrary.simpleMessage("No orders found"),
    "no_packaging_options": MessageLookupByLibrary.simpleMessage(
      "No packaging options available",
    ),
    "no_products_in_category": MessageLookupByLibrary.simpleMessage(
      "No products in this category",
    ),
    "no_results_for": m5,
    "notes_hint": MessageLookupByLibrary.simpleMessage(
      "Example: no fat, special cut...",
    ),
    "notes_label": MessageLookupByLibrary.simpleMessage("Additional Notes"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "offer_price_label": MessageLookupByLibrary.simpleMessage("Offer Price"),
    "onboarding_desc_1": MessageLookupByLibrary.simpleMessage(
      "Choose from carefully selected premium sheep, goats, and calves.",
    ),
    "onboarding_desc_2": MessageLookupByLibrary.simpleMessage(
      "Tailored butchery options, vacuum sealing, and custom packaging.",
    ),
    "onboarding_desc_3": MessageLookupByLibrary.simpleMessage(
      "Direct delivery to your doorstep in specialized cold transport.",
    ),
    "onboarding_feature_1": MessageLookupByLibrary.simpleMessage(
      "Guaranteed Fresh Livestock",
    ),
    "onboarding_feature_2": MessageLookupByLibrary.simpleMessage(
      "Custom Cutting & Vacuum Packaging",
    ),
    "onboarding_feature_3": MessageLookupByLibrary.simpleMessage(
      "100% Halal Sharia-Compliant",
    ),
    "onboarding_title_1": MessageLookupByLibrary.simpleMessage(
      "Fresh Livestock",
    ),
    "onboarding_title_2": MessageLookupByLibrary.simpleMessage(
      "Custom Cutting & Packing",
    ),
    "onboarding_title_3": MessageLookupByLibrary.simpleMessage(
      "Refrigerated Express Delivery",
    ),
    "open_now": MessageLookupByLibrary.simpleMessage("Open Now"),
    "optional_field": MessageLookupByLibrary.simpleMessage("Optional"),
    "order_date": MessageLookupByLibrary.simpleMessage("Order Date"),
    "order_details": MessageLookupByLibrary.simpleMessage("Order Details"),
    "order_history": MessageLookupByLibrary.simpleMessage("Order History"),
    "order_number": MessageLookupByLibrary.simpleMessage("Order Number"),
    "order_online_price": m6,
    "order_status": MessageLookupByLibrary.simpleMessage("Status"),
    "order_status_cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "order_status_confirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
    "order_status_delivered": MessageLookupByLibrary.simpleMessage("Delivered"),
    "order_status_draft": MessageLookupByLibrary.simpleMessage("Draft"),
    "order_status_out": MessageLookupByLibrary.simpleMessage(
      "Out for Delivery",
    ),
    "order_status_pending": MessageLookupByLibrary.simpleMessage(
      "Pending Payment",
    ),
    "order_status_preparing": MessageLookupByLibrary.simpleMessage("Preparing"),
    "order_status_ready": MessageLookupByLibrary.simpleMessage(
      "Ready for Pickup",
    ),
    "order_status_refunded": MessageLookupByLibrary.simpleMessage("Refunded"),
    "order_summary": MessageLookupByLibrary.simpleMessage("Order Summary"),
    "order_total": MessageLookupByLibrary.simpleMessage("Total"),
    "orders": MessageLookupByLibrary.simpleMessage("Orders"),
    "orders_title": MessageLookupByLibrary.simpleMessage("My Orders"),
    "original_price_label": MessageLookupByLibrary.simpleMessage(
      "Original Price",
    ),
    "out_of_stock": MessageLookupByLibrary.simpleMessage("Out of Stock"),
    "packaging_options": MessageLookupByLibrary.simpleMessage(
      "Packaging Options",
    ),
    "payment_method": MessageLookupByLibrary.simpleMessage("Payment Method"),
    "phone_label": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "pkg_gift_box": MessageLookupByLibrary.simpleMessage("Gift Box"),
    "pkg_standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "pkg_vacuum": MessageLookupByLibrary.simpleMessage("Vacuum"),
    "points_count": m7,
    "popular_searches": MessageLookupByLibrary.simpleMessage(
      "Popular Searches",
    ),
    "previous_orders": MessageLookupByLibrary.simpleMessage("Previous"),
    "price_high_to_low": MessageLookupByLibrary.simpleMessage(
      "Price: High to Low",
    ),
    "price_low_to_high": MessageLookupByLibrary.simpleMessage(
      "Price: Low to High",
    ),
    "price_range": MessageLookupByLibrary.simpleMessage("Price Range"),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "proceed_checkout": MessageLookupByLibrary.simpleMessage(
      "Proceed to Checkout",
    ),
    "product_description": MessageLookupByLibrary.simpleMessage(
      "Discover the finest handcrafted, farm-fresh meat and gourmet cuts! Expertly processed under strict hygienic standards for the ultimate dining experience.",
    ),
    "product_details": MessageLookupByLibrary.simpleMessage("Product Details"),
    "product_not_found": MessageLookupByLibrary.simpleMessage(
      "Product not found",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "quantity_label": MessageLookupByLibrary.simpleMessage("Quantity"),
    "recent_searches": MessageLookupByLibrary.simpleMessage("Recent Searches"),
    "recommended_products": MessageLookupByLibrary.simpleMessage(
      "Recommended Products",
    ),
    "redeem_points": MessageLookupByLibrary.simpleMessage(
      "Redeem Loyalty Points",
    ),
    "relevance": MessageLookupByLibrary.simpleMessage("Relevance"),
    "remove_from_cart": MessageLookupByLibrary.simpleMessage(
      "Remove from Cart",
    ),
    "required_field": MessageLookupByLibrary.simpleMessage("Required"),
    "retry_button": MessageLookupByLibrary.simpleMessage("Retry"),
    "reviews_rating": m8,
    "sale_tag": MessageLookupByLibrary.simpleMessage("Sale"),
    "sar": MessageLookupByLibrary.simpleMessage("SAR"),
    "sar_value": m9,
    "save_changes": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "saved_addresses": MessageLookupByLibrary.simpleMessage("Saved Addresses"),
    "saving_label": m10,
    "search_hint": MessageLookupByLibrary.simpleMessage(
      "Search for fresh meat, fruits...",
    ),
    "search_placeholder": MessageLookupByLibrary.simpleMessage(
      "Search here...",
    ),
    "select_delivery_date": MessageLookupByLibrary.simpleMessage(
      "Select Delivery Date",
    ),
    "select_delivery_time": MessageLookupByLibrary.simpleMessage(
      "Select Time Slot",
    ),
    "select_option": MessageLookupByLibrary.simpleMessage("Select"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shipping_address": MessageLookupByLibrary.simpleMessage(
      "Shipping Address",
    ),
    "sign_in": MessageLookupByLibrary.simpleMessage("Sign In"),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "sort_by": MessageLookupByLibrary.simpleMessage("Sort By"),
    "splash_tagline": MessageLookupByLibrary.simpleMessage("DHABAYIH LMAMLAKA"),
    "splash_title": MessageLookupByLibrary.simpleMessage("ذبائح المملكة"),
    "start_building": MessageLookupByLibrary.simpleMessage("Order Now"),
    "subtotal": MessageLookupByLibrary.simpleMessage("Subtotal"),
    "tab_fresh_cut": m11,
    "tab_popular": m12,
    "tab_special": m13,
    "tax": MessageLookupByLibrary.simpleMessage("Tax"),
    "terms_of_service": MessageLookupByLibrary.simpleMessage(
      "Terms of Service",
    ),
    "time_slot_afternoon": MessageLookupByLibrary.simpleMessage(
      "Afternoon (12:00 PM - 5:00 PM)",
    ),
    "time_slot_evening": MessageLookupByLibrary.simpleMessage(
      "Evening (5:00 PM - 10:00 PM)",
    ),
    "time_slot_morning": MessageLookupByLibrary.simpleMessage(
      "Morning (8:00 AM - 12:00 PM)",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "todays_offers": MessageLookupByLibrary.simpleMessage("Today\'s Offers"),
    "tomorrow": MessageLookupByLibrary.simpleMessage("Tomorrow"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "track_order": MessageLookupByLibrary.simpleMessage("Track Order"),
    "tracking_timeline": MessageLookupByLibrary.simpleMessage(
      "Tracking Timeline",
    ),
    "unable_load_highlight": MessageLookupByLibrary.simpleMessage(
      "Unable to load highlight",
    ),
    "unable_play_video": MessageLookupByLibrary.simpleMessage(
      "Unable to play video",
    ),
    "update_cart": MessageLookupByLibrary.simpleMessage("Update Cart"),
    "view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "view_more": MessageLookupByLibrary.simpleMessage("View More"),
    "wallet_balance": MessageLookupByLibrary.simpleMessage("Wallet Balance"),
    "weight_half": MessageLookupByLibrary.simpleMessage("Half"),
    "weight_kg": m14,
    "weight_options": MessageLookupByLibrary.simpleMessage("Weight Options"),
    "weight_whole": MessageLookupByLibrary.simpleMessage("Whole"),
    "welcome": MessageLookupByLibrary.simpleMessage(
      "Welcome to Dhabayih Lmamlaka",
    ),
    "welcome_comma": MessageLookupByLibrary.simpleMessage("Welcome,"),
    "welcome_headline": MessageLookupByLibrary.simpleMessage(
      "Premium Fresh Sacrifices at Your Fingertips.",
    ),
    "welcome_sub_1": MessageLookupByLibrary.simpleMessage(
      "Select fresh livestock with custom cutting & packaging",
    ),
    "welcome_sub_2": MessageLookupByLibrary.simpleMessage(
      "Fast refrigerated delivery directly to your doorstep",
    ),
    "welcome_sub_3": MessageLookupByLibrary.simpleMessage(
      "Guaranteed top quality & 100% Halal Sharia-compliant",
    ),
    "your_selection": MessageLookupByLibrary.simpleMessage(
      "Your Selection Summary",
    ),
  };
}
