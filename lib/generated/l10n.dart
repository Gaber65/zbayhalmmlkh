// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Dhabayih Lmamlaka`
  String get app_name {
    return Intl.message(
      'Dhabayih Lmamlaka',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `ذبائح المملكة`
  String get splash_title {
    return Intl.message(
      'ذبائح المملكة',
      name: 'splash_title',
      desc: '',
      args: [],
    );
  }

  /// `DHABAYIH LMAMLAKA`
  String get splash_tagline {
    return Intl.message(
      'DHABAYIH LMAMLAKA',
      name: 'splash_tagline',
      desc: '',
      args: [],
    );
  }

  /// `Crafted with Luxury & Quality`
  String get crafted_by {
    return Intl.message(
      'Crafted with Luxury & Quality',
      name: 'crafted_by',
      desc: '',
      args: [],
    );
  }

  /// `Egypt 🇪🇬`
  String get country_egypt {
    return Intl.message(
      'Egypt 🇪🇬',
      name: 'country_egypt',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Dhabayih Lmamlaka`
  String get welcome {
    return Intl.message(
      'Welcome to Dhabayih Lmamlaka',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Premium Fresh Sacrifices at Your Fingertips.`
  String get welcome_headline {
    return Intl.message(
      'Premium Fresh Sacrifices at Your Fingertips.',
      name: 'welcome_headline',
      desc: '',
      args: [],
    );
  }

  /// `Select fresh livestock with custom cutting & packaging`
  String get welcome_sub_1 {
    return Intl.message(
      'Select fresh livestock with custom cutting & packaging',
      name: 'welcome_sub_1',
      desc: '',
      args: [],
    );
  }

  /// `Fast refrigerated delivery directly to your doorstep`
  String get welcome_sub_2 {
    return Intl.message(
      'Fast refrigerated delivery directly to your doorstep',
      name: 'welcome_sub_2',
      desc: '',
      args: [],
    );
  }

  /// `Guaranteed top quality & 100% Halal Sharia-compliant`
  String get welcome_sub_3 {
    return Intl.message(
      'Guaranteed top quality & 100% Halal Sharia-compliant',
      name: 'welcome_sub_3',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get get_started {
    return Intl.message('Get Started', name: 'get_started', desc: '', args: []);
  }

  /// `Already have an account?`
  String get already_have_account {
    return Intl.message(
      'Already have an account?',
      name: 'already_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in {
    return Intl.message('Sign In', name: 'sign_in', desc: '', args: []);
  }

  /// `ENGLISH`
  String get english {
    return Intl.message('ENGLISH', name: 'english', desc: '', args: []);
  }

  /// `العربية`
  String get arabic {
    return Intl.message('العربية', name: 'arabic', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Dhabayih Lmamlaka`
  String get home_title {
    return Intl.message(
      'Dhabayih Lmamlaka',
      name: 'home_title',
      desc: '',
      args: [],
    );
  }

  /// `Select your fresh livestock, custom cuts, and express delivery.`
  String get home_subtitle {
    return Intl.message(
      'Select your fresh livestock, custom cuts, and express delivery.',
      name: 'home_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Premium Livestock Selection`
  String get home_cta_title {
    return Intl.message(
      'Premium Livestock Selection',
      name: 'home_cta_title',
      desc: '',
      args: [],
    );
  }

  /// `Enjoy premium quality, certified slaughtering, and refrigerated transport.`
  String get home_cta_subtitle {
    return Intl.message(
      'Enjoy premium quality, certified slaughtering, and refrigerated transport.',
      name: 'home_cta_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Order Now`
  String get start_building {
    return Intl.message(
      'Order Now',
      name: 'start_building',
      desc: '',
      args: [],
    );
  }

  /// `Made for Dhabayih Lmamlaka`
  String get made_with_love {
    return Intl.message(
      'Made for Dhabayih Lmamlaka',
      name: 'made_with_love',
      desc: '',
      args: [],
    );
  }

  /// `Dhabayih Lmamlaka`
  String get created_by {
    return Intl.message(
      'Dhabayih Lmamlaka',
      name: 'created_by',
      desc: '',
      args: [],
    );
  }

  /// `Fresh Livestock`
  String get onboarding_title_1 {
    return Intl.message(
      'Fresh Livestock',
      name: 'onboarding_title_1',
      desc: '',
      args: [],
    );
  }

  /// `Choose from carefully selected premium sheep, goats, and calves.`
  String get onboarding_desc_1 {
    return Intl.message(
      'Choose from carefully selected premium sheep, goats, and calves.',
      name: 'onboarding_desc_1',
      desc: '',
      args: [],
    );
  }

  /// `Custom Cutting & Packing`
  String get onboarding_title_2 {
    return Intl.message(
      'Custom Cutting & Packing',
      name: 'onboarding_title_2',
      desc: '',
      args: [],
    );
  }

  /// `Tailored butchery options, vacuum sealing, and custom packaging.`
  String get onboarding_desc_2 {
    return Intl.message(
      'Tailored butchery options, vacuum sealing, and custom packaging.',
      name: 'onboarding_desc_2',
      desc: '',
      args: [],
    );
  }

  /// `Refrigerated Express Delivery`
  String get onboarding_title_3 {
    return Intl.message(
      'Refrigerated Express Delivery',
      name: 'onboarding_title_3',
      desc: '',
      args: [],
    );
  }

  /// `Direct delivery to your doorstep in specialized cold transport.`
  String get onboarding_desc_3 {
    return Intl.message(
      'Direct delivery to your doorstep in specialized cold transport.',
      name: 'onboarding_desc_3',
      desc: '',
      args: [],
    );
  }

  /// `Guaranteed Fresh Livestock`
  String get onboarding_feature_1 {
    return Intl.message(
      'Guaranteed Fresh Livestock',
      name: 'onboarding_feature_1',
      desc: '',
      args: [],
    );
  }

  /// `Custom Cutting & Vacuum Packaging`
  String get onboarding_feature_2 {
    return Intl.message(
      'Custom Cutting & Vacuum Packaging',
      name: 'onboarding_feature_2',
      desc: '',
      args: [],
    );
  }

  /// `100% Halal Sharia-Compliant`
  String get onboarding_feature_3 {
    return Intl.message(
      '100% Halal Sharia-Compliant',
      name: 'onboarding_feature_3',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get login_welcome {
    return Intl.message('Welcome', name: 'login_welcome', desc: '', args: []);
  }

  /// `Back`
  String get login_back {
    return Intl.message('Back', name: 'login_back', desc: '', args: []);
  }

  /// `Enter your credentials to access your luxury shopping experience.`
  String get login_subtitle {
    return Intl.message(
      'Enter your credentials to access your luxury shopping experience.',
      name: 'login_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email_label {
    return Intl.message('Email', name: 'email_label', desc: '', args: []);
  }

  /// `hello@dhabayih.com`
  String get email_hint {
    return Intl.message(
      'hello@dhabayih.com',
      name: 'email_hint',
      desc: '',
      args: [],
    );
  }

  /// `Continue as Guest`
  String get continue_as_guest {
    return Intl.message(
      'Continue as Guest',
      name: 'continue_as_guest',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get terms_of_service {
    return Intl.message(
      'Terms of Service',
      name: 'terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `DELIVERY TO`
  String get delivery_to {
    return Intl.message('DELIVERY TO', name: 'delivery_to', desc: '', args: []);
  }

  /// `Home - Riyadh, KSA`
  String get home_address_mock {
    return Intl.message(
      'Home - Riyadh, KSA',
      name: 'home_address_mock',
      desc: '',
      args: [],
    );
  }

  /// `Search for fresh meat, fruits...`
  String get search_hint {
    return Intl.message(
      'Search for fresh meat, fruits...',
      name: 'search_hint',
      desc: '',
      args: [],
    );
  }

  /// `New Season`
  String get new_season {
    return Intl.message('New Season', name: 'new_season', desc: '', args: []);
  }

  /// `Fresh Harvest -\nFrom Farm to Your Table`
  String get fresh_harvest {
    return Intl.message(
      'Fresh Harvest -\nFrom Farm to Your Table',
      name: 'fresh_harvest',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories_title {
    return Intl.message(
      'Categories',
      name: 'categories_title',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get view_all {
    return Intl.message('View All', name: 'view_all', desc: '', args: []);
  }

  /// `Today's Offers`
  String get todays_offers {
    return Intl.message(
      'Today\'s Offers',
      name: 'todays_offers',
      desc: '',
      args: [],
    );
  }

  /// `HOT`
  String get hot_tag {
    return Intl.message('HOT', name: 'hot_tag', desc: '', args: []);
  }

  /// `Best Sellers`
  String get best_sellers {
    return Intl.message(
      'Best Sellers',
      name: 'best_sellers',
      desc: '',
      args: [],
    );
  }

  /// `View More`
  String get view_more {
    return Intl.message('View More', name: 'view_more', desc: '', args: []);
  }

  /// `Retry`
  String get retry_button {
    return Intl.message('Retry', name: 'retry_button', desc: '', args: []);
  }

  /// `Welcome,`
  String get welcome_comma {
    return Intl.message('Welcome,', name: 'welcome_comma', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Featured Products`
  String get featured_products {
    return Intl.message(
      'Featured Products',
      name: 'featured_products',
      desc: '',
      args: [],
    );
  }

  /// `Recommended Products`
  String get recommended_products {
    return Intl.message(
      'Recommended Products',
      name: 'recommended_products',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Balance`
  String get wallet_balance {
    return Intl.message(
      'Wallet Balance',
      name: 'wallet_balance',
      desc: '',
      args: [],
    );
  }

  /// `General Settings`
  String get general_settings {
    return Intl.message(
      'General Settings',
      name: 'general_settings',
      desc: '',
      args: [],
    );
  }

  /// `App Language`
  String get app_language {
    return Intl.message(
      'App Language',
      name: 'app_language',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message('Dark Mode', name: 'dark_mode', desc: '', args: []);
  }

  /// `Enabled`
  String get enabled {
    return Intl.message('Enabled', name: 'enabled', desc: '', args: []);
  }

  /// `Disabled`
  String get disabled {
    return Intl.message('Disabled', name: 'disabled', desc: '', args: []);
  }

  /// `Order History`
  String get order_history {
    return Intl.message(
      'Order History',
      name: 'order_history',
      desc: '',
      args: [],
    );
  }

  /// `Saved Addresses`
  String get saved_addresses {
    return Intl.message(
      'Saved Addresses',
      name: 'saved_addresses',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get logout_confirmation {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logout_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Name`
  String get name_label {
    return Intl.message('Name', name: 'name_label', desc: '', args: []);
  }

  /// `Phone Number`
  String get phone_label {
    return Intl.message(
      'Phone Number',
      name: 'phone_label',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save_changes {
    return Intl.message(
      'Save Changes',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }

  /// `Guest User`
  String get guest_user {
    return Intl.message('Guest User', name: 'guest_user', desc: '', args: []);
  }

  /// `Login to access all features`
  String get guest_subtitle {
    return Intl.message(
      'Login to access all features',
      name: 'guest_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Login / Register`
  String get login_register {
    return Intl.message(
      'Login / Register',
      name: 'login_register',
      desc: '',
      args: [],
    );
  }

  /// `Login Required`
  String get login_required {
    return Intl.message(
      'Login Required',
      name: 'login_required',
      desc: '',
      args: [],
    );
  }

  /// `Please login to access this feature.`
  String get login_required_desc {
    return Intl.message(
      'Please login to access this feature.',
      name: 'login_required_desc',
      desc: '',
      args: [],
    );
  }

  /// `Loyalty Points`
  String get loyalty_points {
    return Intl.message(
      'Loyalty Points',
      name: 'loyalty_points',
      desc: '',
      args: [],
    );
  }

  /// `{count} Points`
  String points_count(Object count) {
    return Intl.message(
      '$count Points',
      name: 'points_count',
      desc: '',
      args: [count],
    );
  }

  /// `No categories found.`
  String get no_categories {
    return Intl.message(
      'No categories found.',
      name: 'no_categories',
      desc: '',
      args: [],
    );
  }

  /// `No products in this category`
  String get no_products_in_category {
    return Intl.message(
      'No products in this category',
      name: 'no_products_in_category',
      desc: '',
      args: [],
    );
  }

  /// `Recent Searches`
  String get recent_searches {
    return Intl.message(
      'Recent Searches',
      name: 'recent_searches',
      desc: '',
      args: [],
    );
  }

  /// `Popular Searches`
  String get popular_searches {
    return Intl.message(
      'Popular Searches',
      name: 'popular_searches',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get filters {
    return Intl.message('Filters', name: 'filters', desc: '', args: []);
  }

  /// `Sort By`
  String get sort_by {
    return Intl.message('Sort By', name: 'sort_by', desc: '', args: []);
  }

  /// `Relevance`
  String get relevance {
    return Intl.message('Relevance', name: 'relevance', desc: '', args: []);
  }

  /// `Price: Low to High`
  String get price_low_to_high {
    return Intl.message(
      'Price: Low to High',
      name: 'price_low_to_high',
      desc: '',
      args: [],
    );
  }

  /// `Price: High to Low`
  String get price_high_to_low {
    return Intl.message(
      'Price: High to Low',
      name: 'price_high_to_low',
      desc: '',
      args: [],
    );
  }

  /// `Newest Arrivals`
  String get newest_arrivals {
    return Intl.message(
      'Newest Arrivals',
      name: 'newest_arrivals',
      desc: '',
      args: [],
    );
  }

  /// `Price Range`
  String get price_range {
    return Intl.message('Price Range', name: 'price_range', desc: '', args: []);
  }

  /// `{value} SAR`
  String sar_value(Object value) {
    return Intl.message(
      '$value SAR',
      name: 'sar_value',
      desc: '',
      args: [value],
    );
  }

  /// `Apply Filters`
  String get apply_filters {
    return Intl.message(
      'Apply Filters',
      name: 'apply_filters',
      desc: '',
      args: [],
    );
  }

  /// `No results found for "{query}"`
  String no_results_for(Object query) {
    return Intl.message(
      'No results found for "$query"',
      name: 'no_results_for',
      desc: '',
      args: [query],
    );
  }

  /// `My Cart`
  String get my_cart {
    return Intl.message('My Cart', name: 'my_cart', desc: '', args: []);
  }

  /// `Your cart is empty`
  String get cart_empty {
    return Intl.message(
      'Your cart is empty',
      name: 'cart_empty',
      desc: '',
      args: [],
    );
  }

  /// `Explore our catalog and add items.`
  String get explore_catalog {
    return Intl.message(
      'Explore our catalog and add items.',
      name: 'explore_catalog',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message('Subtotal', name: 'subtotal', desc: '', args: []);
  }

  /// `Delivery Fee`
  String get delivery_fee {
    return Intl.message(
      'Delivery Fee',
      name: 'delivery_fee',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Proceed to Checkout`
  String get proceed_checkout {
    return Intl.message(
      'Proceed to Checkout',
      name: 'proceed_checkout',
      desc: '',
      args: [],
    );
  }

  /// `Open Now`
  String get open_now {
    return Intl.message('Open Now', name: 'open_now', desc: '', args: []);
  }

  /// `Fast Service`
  String get fast_service {
    return Intl.message(
      'Fast Service',
      name: 'fast_service',
      desc: '',
      args: [],
    );
  }

  /// `Fresh Daily`
  String get fresh_daily {
    return Intl.message('Fresh Daily', name: 'fresh_daily', desc: '', args: []);
  }

  /// `100% Halal`
  String get halal_compliance {
    return Intl.message(
      '100% Halal',
      name: 'halal_compliance',
      desc: '',
      args: [],
    );
  }

  /// `4.7 stars ({count} reviews)`
  String reviews_rating(Object count) {
    return Intl.message(
      '4.7 stars ($count reviews)',
      name: 'reviews_rating',
      desc: '',
      args: [count],
    );
  }

  /// `Discover the finest handcrafted, farm-fresh meat and gourmet cuts! Expertly processed under strict hygienic standards for the ultimate dining experience.`
  String get product_description {
    return Intl.message(
      'Discover the finest handcrafted, farm-fresh meat and gourmet cuts! Expertly processed under strict hygienic standards for the ultimate dining experience.',
      name: 'product_description',
      desc: '',
      args: [],
    );
  }

  /// `Popular ({count})`
  String tab_popular(Object count) {
    return Intl.message(
      'Popular ($count)',
      name: 'tab_popular',
      desc: '',
      args: [count],
    );
  }

  /// `Fresh Cut ({count})`
  String tab_fresh_cut(Object count) {
    return Intl.message(
      'Fresh Cut ($count)',
      name: 'tab_fresh_cut',
      desc: '',
      args: [count],
    );
  }

  /// `Special ({count})`
  String tab_special(Object count) {
    return Intl.message(
      'Special ($count)',
      name: 'tab_special',
      desc: '',
      args: [count],
    );
  }

  /// `Weight Options`
  String get weight_options {
    return Intl.message(
      'Weight Options',
      name: 'weight_options',
      desc: '',
      args: [],
    );
  }

  /// `{count} Kg`
  String weight_kg(Object count) {
    return Intl.message(
      '$count Kg',
      name: 'weight_kg',
      desc: '',
      args: [count],
    );
  }

  /// `Half`
  String get weight_half {
    return Intl.message('Half', name: 'weight_half', desc: '', args: []);
  }

  /// `Whole`
  String get weight_whole {
    return Intl.message('Whole', name: 'weight_whole', desc: '', args: []);
  }

  /// `Cutting Options`
  String get cutting_options {
    return Intl.message(
      'Cutting Options',
      name: 'cutting_options',
      desc: '',
      args: [],
    );
  }

  /// `Whole`
  String get cutting_whole {
    return Intl.message('Whole', name: 'cutting_whole', desc: '', args: []);
  }

  /// `Halves`
  String get cutting_halves {
    return Intl.message('Halves', name: 'cutting_halves', desc: '', args: []);
  }

  /// `Quarters`
  String get cutting_quarters {
    return Intl.message(
      'Quarters',
      name: 'cutting_quarters',
      desc: '',
      args: [],
    );
  }

  /// `Small Pieces`
  String get cutting_small_pieces {
    return Intl.message(
      'Small Pieces',
      name: 'cutting_small_pieces',
      desc: '',
      args: [],
    );
  }

  /// `Packaging Options`
  String get packaging_options {
    return Intl.message(
      'Packaging Options',
      name: 'packaging_options',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get pkg_standard {
    return Intl.message('Standard', name: 'pkg_standard', desc: '', args: []);
  }

  /// `Vacuum`
  String get pkg_vacuum {
    return Intl.message('Vacuum', name: 'pkg_vacuum', desc: '', args: []);
  }

  /// `Gift Box`
  String get pkg_gift_box {
    return Intl.message('Gift Box', name: 'pkg_gift_box', desc: '', args: []);
  }

  /// `Added {count} item(s) to cart`
  String added_to_cart(Object count) {
    return Intl.message(
      'Added $count item(s) to cart',
      name: 'added_to_cart',
      desc: '',
      args: [count],
    );
  }

  /// `Order Online  •  {price} SAR`
  String order_online_price(Object price) {
    return Intl.message(
      'Order Online  •  $price SAR',
      name: 'order_online_price',
      desc: '',
      args: [price],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `100% Fresh`
  String get badge_fresh_title {
    return Intl.message(
      '100% Fresh',
      name: 'badge_fresh_title',
      desc: '',
      args: [],
    );
  }

  /// `Farm Direct`
  String get badge_fresh_subtitle {
    return Intl.message(
      'Farm Direct',
      name: 'badge_fresh_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Fast Express`
  String get badge_delivery_title {
    return Intl.message(
      'Fast Express',
      name: 'badge_delivery_title',
      desc: '',
      args: [],
    );
  }

  /// `Same Day`
  String get badge_delivery_subtitle {
    return Intl.message(
      'Same Day',
      name: 'badge_delivery_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Hygienic`
  String get badge_hygienic_title {
    return Intl.message(
      'Hygienic',
      name: 'badge_hygienic_title',
      desc: '',
      args: [],
    );
  }

  /// `Certified`
  String get badge_hygienic_subtitle {
    return Intl.message(
      'Certified',
      name: 'badge_hygienic_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Current Location`
  String get current_location {
    return Intl.message(
      'Current Location',
      name: 'current_location',
      desc: '',
      args: [],
    );
  }

  /// `Riyadh, KSA`
  String get default_location_mock {
    return Intl.message(
      'Riyadh, KSA',
      name: 'default_location_mock',
      desc: '',
      args: [],
    );
  }

  /// `No media available`
  String get no_media_available {
    return Intl.message(
      'No media available',
      name: 'no_media_available',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load highlight`
  String get unable_load_highlight {
    return Intl.message(
      'Unable to load highlight',
      name: 'unable_load_highlight',
      desc: '',
      args: [],
    );
  }

  /// `Unable to play video`
  String get unable_play_video {
    return Intl.message(
      'Unable to play video',
      name: 'unable_play_video',
      desc: '',
      args: [],
    );
  }

  /// `Cart with {count} items`
  String cart_semantics_count(Object count) {
    return Intl.message(
      'Cart with $count items',
      name: 'cart_semantics_count',
      desc: '',
      args: [count],
    );
  }

  /// `Empty Cart`
  String get cart_semantics_empty {
    return Intl.message(
      'Empty Cart',
      name: 'cart_semantics_empty',
      desc: '',
      args: [],
    );
  }

  /// `Hello! `
  String get hello_label {
    return Intl.message('Hello! ', name: 'hello_label', desc: '', args: []);
  }

  /// `Explore premium fresh meats & groceries`
  String get home_intro_subtitle {
    return Intl.message(
      'Explore premium fresh meats & groceries',
      name: 'home_intro_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Search here...`
  String get search_placeholder {
    return Intl.message(
      'Search here...',
      name: 'search_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Sale`
  String get sale_tag {
    return Intl.message('Sale', name: 'sale_tag', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Set Delivery Location`
  String get addr_title {
    return Intl.message(
      'Set Delivery Location',
      name: 'addr_title',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get addr_city {
    return Intl.message('City', name: 'addr_city', desc: '', args: []);
  }

  /// `Street / Road`
  String get addr_street {
    return Intl.message(
      'Street / Road',
      name: 'addr_street',
      desc: '',
      args: [],
    );
  }

  /// `My Addresses`
  String get addr_my_addresses {
    return Intl.message(
      'My Addresses',
      name: 'addr_my_addresses',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get addr_add_new {
    return Intl.message(
      'Add Address',
      name: 'addr_add_new',
      desc: '',
      args: [],
    );
  }

  /// `Edit Address`
  String get addr_edit_address {
    return Intl.message(
      'Edit Address',
      name: 'addr_edit_address',
      desc: '',
      args: [],
    );
  }

  /// `No Saved Addresses`
  String get addr_empty_title {
    return Intl.message(
      'No Saved Addresses',
      name: 'addr_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Add your first delivery address to get started.`
  String get addr_empty_subtitle {
    return Intl.message(
      'Add your first delivery address to get started.',
      name: 'addr_empty_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Address Label`
  String get addr_label_title {
    return Intl.message(
      'Address Label',
      name: 'addr_label_title',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get addr_label_home {
    return Intl.message('Home', name: 'addr_label_home', desc: '', args: []);
  }

  /// `Work`
  String get addr_label_work {
    return Intl.message('Work', name: 'addr_label_work', desc: '', args: []);
  }

  /// `Other`
  String get addr_label_other {
    return Intl.message('Other', name: 'addr_label_other', desc: '', args: []);
  }

  /// `Label name`
  String get addr_label_other_hint {
    return Intl.message(
      'Label name',
      name: 'addr_label_other_hint',
      desc: '',
      args: [],
    );
  }

  /// `Recipient Information`
  String get addr_recipient_section {
    return Intl.message(
      'Recipient Information',
      name: 'addr_recipient_section',
      desc: '',
      args: [],
    );
  }

  /// `Recipient Name`
  String get addr_recipient_name {
    return Intl.message(
      'Recipient Name',
      name: 'addr_recipient_name',
      desc: '',
      args: [],
    );
  }

  /// `Recipient Phone`
  String get addr_recipient_phone {
    return Intl.message(
      'Recipient Phone',
      name: 'addr_recipient_phone',
      desc: '',
      args: [],
    );
  }

  /// `Building Details`
  String get addr_building_section {
    return Intl.message(
      'Building Details',
      name: 'addr_building_section',
      desc: '',
      args: [],
    );
  }

  /// `Additional Information`
  String get addr_additional_section {
    return Intl.message(
      'Additional Information',
      name: 'addr_additional_section',
      desc: '',
      args: [],
    );
  }

  /// `Selected Location`
  String get addr_full_address {
    return Intl.message(
      'Selected Location',
      name: 'addr_full_address',
      desc: '',
      args: [],
    );
  }

  /// `Building`
  String get addr_building {
    return Intl.message('Building', name: 'addr_building', desc: '', args: []);
  }

  /// `Floor`
  String get addr_floor {
    return Intl.message('Floor', name: 'addr_floor', desc: '', args: []);
  }

  /// `Apartment`
  String get addr_apartment {
    return Intl.message(
      'Apartment',
      name: 'addr_apartment',
      desc: '',
      args: [],
    );
  }

  /// `Nearby Landmark`
  String get addr_landmark {
    return Intl.message(
      'Nearby Landmark',
      name: 'addr_landmark',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Notes`
  String get addr_notes {
    return Intl.message(
      'Delivery Notes',
      name: 'addr_notes',
      desc: '',
      args: [],
    );
  }

  /// `Set as Default`
  String get addr_set_default {
    return Intl.message(
      'Set as Default',
      name: 'addr_set_default',
      desc: '',
      args: [],
    );
  }

  /// `Use this address as default delivery address`
  String get addr_set_default_hint {
    return Intl.message(
      'Use this address as default delivery address',
      name: 'addr_set_default_hint',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get addr_is_default {
    return Intl.message('Default', name: 'addr_is_default', desc: '', args: []);
  }

  /// `Confirm Location`
  String get addr_confirm_location {
    return Intl.message(
      'Confirm Location',
      name: 'addr_confirm_location',
      desc: '',
      args: [],
    );
  }

  /// `Current Location`
  String get addr_use_current {
    return Intl.message(
      'Current Location',
      name: 'addr_use_current',
      desc: '',
      args: [],
    );
  }

  /// `Locating address...`
  String get addr_searching {
    return Intl.message(
      'Locating address...',
      name: 'addr_searching',
      desc: '',
      args: [],
    );
  }

  /// `Location permission denied`
  String get addr_permission_denied {
    return Intl.message(
      'Location permission denied',
      name: 'addr_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Open Settings`
  String get addr_open_settings {
    return Intl.message(
      'Open Settings',
      name: 'addr_open_settings',
      desc: '',
      args: [],
    );
  }

  /// `GPS is disabled`
  String get addr_gps_disabled {
    return Intl.message(
      'GPS is disabled',
      name: 'addr_gps_disabled',
      desc: '',
      args: [],
    );
  }

  /// `Enable GPS`
  String get addr_enable_gps {
    return Intl.message(
      'Enable GPS',
      name: 'addr_enable_gps',
      desc: '',
      args: [],
    );
  }

  /// `Could not detect address`
  String get addr_geocoding_failed {
    return Intl.message(
      'Could not detect address',
      name: 'addr_geocoding_failed',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get addr_required {
    return Intl.message(
      'This field is required',
      name: 'addr_required',
      desc: '',
      args: [],
    );
  }

  /// `Delete Address`
  String get addr_delete_title {
    return Intl.message(
      'Delete Address',
      name: 'addr_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Delete "{label}"? This cannot be undone.`
  String addr_delete_confirm(String label) {
    return Intl.message(
      'Delete "$label"? This cannot be undone.',
      name: 'addr_delete_confirm',
      desc: '',
      args: [label],
    );
  }

  /// `Address saved successfully`
  String get addr_saved_success {
    return Intl.message(
      'Address saved successfully',
      name: 'addr_saved_success',
      desc: '',
      args: [],
    );
  }

  /// `Address updated successfully`
  String get addr_updated_success {
    return Intl.message(
      'Address updated successfully',
      name: 'addr_updated_success',
      desc: '',
      args: [],
    );
  }

  /// `Address deleted`
  String get addr_deleted_success {
    return Intl.message(
      'Address deleted',
      name: 'addr_deleted_success',
      desc: '',
      args: [],
    );
  }

  /// `Default address updated`
  String get addr_default_set {
    return Intl.message(
      'Default address updated',
      name: 'addr_default_set',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Please try again.`
  String get addr_network_error {
    return Intl.message(
      'Network error. Please try again.',
      name: 'addr_network_error',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Option`
  String get addr_select_delivery_type {
    return Intl.message(
      'Delivery Option',
      name: 'addr_select_delivery_type',
      desc: '',
      args: [],
    );
  }

  /// `Home Delivery`
  String get addr_delivery {
    return Intl.message(
      'Home Delivery',
      name: 'addr_delivery',
      desc: '',
      args: [],
    );
  }

  /// `Store Pickup`
  String get addr_pickup {
    return Intl.message(
      'Store Pickup',
      name: 'addr_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Select Store Branch`
  String get addr_select_branch {
    return Intl.message(
      'Select Store Branch',
      name: 'addr_select_branch',
      desc: '',
      args: [],
    );
  }

  /// `Select Delivery Address`
  String get addr_select_address {
    return Intl.message(
      'Select Delivery Address',
      name: 'addr_select_address',
      desc: '',
      args: [],
    );
  }

  /// `Add New Address`
  String get addr_add_new_short {
    return Intl.message(
      'Add New Address',
      name: 'addr_add_new_short',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Selection`
  String get addr_confirm_selection {
    return Intl.message(
      'Confirm Selection',
      name: 'addr_confirm_selection',
      desc: '',
      args: [],
    );
  }

  /// `Main Branch - Riyadh`
  String get addr_branch_main {
    return Intl.message(
      'Main Branch - Riyadh',
      name: 'addr_branch_main',
      desc: '',
      args: [],
    );
  }

  /// `Al Sahafa Branch - Riyadh`
  String get addr_branch_sahafa {
    return Intl.message(
      'Al Sahafa Branch - Riyadh',
      name: 'addr_branch_sahafa',
      desc: '',
      args: [],
    );
  }

  /// `Al Rawdah Branch - Riyadh`
  String get addr_branch_rawdah {
    return Intl.message(
      'Al Rawdah Branch - Riyadh',
      name: 'addr_branch_rawdah',
      desc: '',
      args: [],
    );
  }

  /// `Open daily: 8:00 AM - 11:00 PM`
  String get addr_branch_hours {
    return Intl.message(
      'Open daily: 8:00 AM - 11:00 PM',
      name: 'addr_branch_hours',
      desc: '',
      args: [],
    );
  }

  /// `Excluded Parts`
  String get excluded_parts {
    return Intl.message(
      'Excluded Parts',
      name: 'excluded_parts',
      desc: '',
      args: [],
    );
  }

  /// `Additional Notes`
  String get notes_label {
    return Intl.message(
      'Additional Notes',
      name: 'notes_label',
      desc: '',
      args: [],
    );
  }

  /// `Example: no fat, special cut...`
  String get notes_hint {
    return Intl.message(
      'Example: no fat, special cut...',
      name: 'notes_hint',
      desc: '',
      args: [],
    );
  }

  /// `Add to Cart`
  String get add_to_cart {
    return Intl.message('Add to Cart', name: 'add_to_cart', desc: '', args: []);
  }

  /// `Update Cart`
  String get update_cart {
    return Intl.message('Update Cart', name: 'update_cart', desc: '', args: []);
  }

  /// `Loading product...`
  String get loading_product {
    return Intl.message(
      'Loading product...',
      name: 'loading_product',
      desc: '',
      args: [],
    );
  }

  /// `Product not found`
  String get product_not_found {
    return Intl.message(
      'Product not found',
      name: 'product_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Your Selection Summary`
  String get your_selection {
    return Intl.message(
      'Your Selection Summary',
      name: 'your_selection',
      desc: '',
      args: [],
    );
  }

  /// `No cutting options available`
  String get no_cutting_options {
    return Intl.message(
      'No cutting options available',
      name: 'no_cutting_options',
      desc: '',
      args: [],
    );
  }

  /// `No packaging options available`
  String get no_packaging_options {
    return Intl.message(
      'No packaging options available',
      name: 'no_packaging_options',
      desc: '',
      args: [],
    );
  }

  /// `No parts to exclude`
  String get no_excluded_parts {
    return Intl.message(
      'No parts to exclude',
      name: 'no_excluded_parts',
      desc: '',
      args: [],
    );
  }

  /// `Out of Stock`
  String get out_of_stock {
    return Intl.message(
      'Out of Stock',
      name: 'out_of_stock',
      desc: '',
      args: [],
    );
  }

  /// `In Stock`
  String get in_stock {
    return Intl.message('In Stock', name: 'in_stock', desc: '', args: []);
  }

  /// `Offer Price`
  String get offer_price_label {
    return Intl.message(
      'Offer Price',
      name: 'offer_price_label',
      desc: '',
      args: [],
    );
  }

  /// `Original Price`
  String get original_price_label {
    return Intl.message(
      'Original Price',
      name: 'original_price_label',
      desc: '',
      args: [],
    );
  }

  /// `Save {amount} SAR`
  String saving_label(Object amount) {
    return Intl.message(
      'Save $amount SAR',
      name: 'saving_label',
      desc: '',
      args: [amount],
    );
  }

  /// `Quantity`
  String get quantity_label {
    return Intl.message('Quantity', name: 'quantity_label', desc: '', args: []);
  }

  /// `Cart updated successfully`
  String get cart_updated {
    return Intl.message(
      'Cart updated successfully',
      name: 'cart_updated',
      desc: '',
      args: [],
    );
  }

  /// `Product added to cart`
  String get cart_add_success {
    return Intl.message(
      'Product added to cart',
      name: 'cart_add_success',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add product to cart`
  String get cart_add_error {
    return Intl.message(
      'Failed to add product to cart',
      name: 'cart_add_error',
      desc: '',
      args: [],
    );
  }

  /// `Remove from Cart`
  String get remove_from_cart {
    return Intl.message(
      'Remove from Cart',
      name: 'remove_from_cart',
      desc: '',
      args: [],
    );
  }

  /// `Item removed from cart`
  String get cart_item_removed {
    return Intl.message(
      'Item removed from cart',
      name: 'cart_item_removed',
      desc: '',
      args: [],
    );
  }

  /// `Checkout`
  String get checkout {
    return Intl.message('Checkout', name: 'checkout', desc: '', args: []);
  }

  /// `Select`
  String get select_option {
    return Intl.message('Select', name: 'select_option', desc: '', args: []);
  }

  /// `Required`
  String get required_field {
    return Intl.message('Required', name: 'required_field', desc: '', args: []);
  }

  /// `Optional`
  String get optional_field {
    return Intl.message('Optional', name: 'optional_field', desc: '', args: []);
  }

  /// `Product Details`
  String get product_details {
    return Intl.message(
      'Product Details',
      name: 'product_details',
      desc: '',
      args: [],
    );
  }

  /// `SAR`
  String get sar {
    return Intl.message('SAR', name: 'sar', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `An error occurred. Tap to retry.`
  String get error_retry {
    return Intl.message(
      'An error occurred. Tap to retry.',
      name: 'error_retry',
      desc: '',
      args: [],
    );
  }

  /// `Checkout`
  String get checkout_title {
    return Intl.message('Checkout', name: 'checkout_title', desc: '', args: []);
  }

  /// `Order Summary`
  String get order_summary {
    return Intl.message(
      'Order Summary',
      name: 'order_summary',
      desc: '',
      args: [],
    );
  }

  /// `Coupon Code`
  String get coupon_code {
    return Intl.message('Coupon Code', name: 'coupon_code', desc: '', args: []);
  }

  /// `Enter coupon code`
  String get coupon_hint {
    return Intl.message(
      'Enter coupon code',
      name: 'coupon_hint',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Coupon applied successfully`
  String get coupon_applied {
    return Intl.message(
      'Coupon applied successfully',
      name: 'coupon_applied',
      desc: '',
      args: [],
    );
  }

  /// `Invalid coupon code`
  String get coupon_invalid {
    return Intl.message(
      'Invalid coupon code',
      name: 'coupon_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Redeem Loyalty Points`
  String get redeem_points {
    return Intl.message(
      'Redeem Loyalty Points',
      name: 'redeem_points',
      desc: '',
      args: [],
    );
  }

  /// `Available points: {points}`
  String available_points(Object points) {
    return Intl.message(
      'Available points: $points',
      name: 'available_points',
      desc: '',
      args: [points],
    );
  }

  /// `Payment Method`
  String get payment_method {
    return Intl.message(
      'Payment Method',
      name: 'payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Cash on Delivery`
  String get cash_on_delivery {
    return Intl.message(
      'Cash on Delivery',
      name: 'cash_on_delivery',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Order`
  String get confirm_order {
    return Intl.message(
      'Confirm Order',
      name: 'confirm_order',
      desc: '',
      args: [],
    );
  }

  /// `Order Placed Successfully`
  String get checkout_success {
    return Intl.message(
      'Order Placed Successfully',
      name: 'checkout_success',
      desc: '',
      args: [],
    );
  }

  /// `Order Number`
  String get order_number {
    return Intl.message(
      'Order Number',
      name: 'order_number',
      desc: '',
      args: [],
    );
  }

  /// `Track Order`
  String get track_order {
    return Intl.message('Track Order', name: 'track_order', desc: '', args: []);
  }

  /// `Continue Shopping`
  String get continue_shopping {
    return Intl.message(
      'Continue Shopping',
      name: 'continue_shopping',
      desc: '',
      args: [],
    );
  }

  /// `My Orders`
  String get orders_title {
    return Intl.message('My Orders', name: 'orders_title', desc: '', args: []);
  }

  /// `Active`
  String get active_orders {
    return Intl.message('Active', name: 'active_orders', desc: '', args: []);
  }

  /// `Previous`
  String get previous_orders {
    return Intl.message(
      'Previous',
      name: 'previous_orders',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled_orders {
    return Intl.message(
      'Cancelled',
      name: 'cancelled_orders',
      desc: '',
      args: [],
    );
  }

  /// `No orders found`
  String get no_orders {
    return Intl.message(
      'No orders found',
      name: 'no_orders',
      desc: '',
      args: [],
    );
  }

  /// `Order Date`
  String get order_date {
    return Intl.message('Order Date', name: 'order_date', desc: '', args: []);
  }

  /// `Status`
  String get order_status {
    return Intl.message('Status', name: 'order_status', desc: '', args: []);
  }

  /// `Total`
  String get order_total {
    return Intl.message('Total', name: 'order_total', desc: '', args: []);
  }

  /// `{count} items`
  String items_count(Object count) {
    return Intl.message(
      '$count items',
      name: 'items_count',
      desc: '',
      args: [count],
    );
  }

  /// `Order Details`
  String get order_details {
    return Intl.message(
      'Order Details',
      name: 'order_details',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Order`
  String get cancel_order {
    return Intl.message(
      'Cancel Order',
      name: 'cancel_order',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this order?`
  String get cancel_order_confirm {
    return Intl.message(
      'Are you sure you want to cancel this order?',
      name: 'cancel_order_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Order cancelled successfully`
  String get cancel_order_success {
    return Intl.message(
      'Order cancelled successfully',
      name: 'cancel_order_success',
      desc: '',
      args: [],
    );
  }

  /// `Failed to cancel order`
  String get cancel_order_error {
    return Intl.message(
      'Failed to cancel order',
      name: 'cancel_order_error',
      desc: '',
      args: [],
    );
  }

  /// `Shipping Address`
  String get shipping_address {
    return Intl.message(
      'Shipping Address',
      name: 'shipping_address',
      desc: '',
      args: [],
    );
  }

  /// `Branch Pickup`
  String get branch_pickup {
    return Intl.message(
      'Branch Pickup',
      name: 'branch_pickup',
      desc: '',
      args: [],
    );
  }

  /// `Tracking Timeline`
  String get tracking_timeline {
    return Intl.message(
      'Tracking Timeline',
      name: 'tracking_timeline',
      desc: '',
      args: [],
    );
  }

  /// `Tax`
  String get tax {
    return Intl.message('Tax', name: 'tax', desc: '', args: []);
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Loyalty Discount`
  String get loyalty_discount {
    return Intl.message(
      'Loyalty Discount',
      name: 'loyalty_discount',
      desc: '',
      args: [],
    );
  }

  /// `Draft`
  String get order_status_draft {
    return Intl.message(
      'Draft',
      name: 'order_status_draft',
      desc: '',
      args: [],
    );
  }

  /// `Pending Payment`
  String get order_status_pending {
    return Intl.message(
      'Pending Payment',
      name: 'order_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get order_status_confirmed {
    return Intl.message(
      'Confirmed',
      name: 'order_status_confirmed',
      desc: '',
      args: [],
    );
  }

  /// `Preparing`
  String get order_status_preparing {
    return Intl.message(
      'Preparing',
      name: 'order_status_preparing',
      desc: '',
      args: [],
    );
  }

  /// `Ready for Pickup`
  String get order_status_ready {
    return Intl.message(
      'Ready for Pickup',
      name: 'order_status_ready',
      desc: '',
      args: [],
    );
  }

  /// `Out for Delivery`
  String get order_status_out {
    return Intl.message(
      'Out for Delivery',
      name: 'order_status_out',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get order_status_delivered {
    return Intl.message(
      'Delivered',
      name: 'order_status_delivered',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get order_status_cancelled {
    return Intl.message(
      'Cancelled',
      name: 'order_status_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Refunded`
  String get order_status_refunded {
    return Intl.message(
      'Refunded',
      name: 'order_status_refunded',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Schedule`
  String get delivery_schedule {
    return Intl.message(
      'Delivery Schedule',
      name: 'delivery_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Select Delivery Date`
  String get select_delivery_date {
    return Intl.message(
      'Select Delivery Date',
      name: 'select_delivery_date',
      desc: '',
      args: [],
    );
  }

  /// `Select Time Slot`
  String get select_delivery_time {
    return Intl.message(
      'Select Time Slot',
      name: 'select_delivery_time',
      desc: '',
      args: [],
    );
  }

  /// `Morning (8:00 AM - 12:00 PM)`
  String get time_slot_morning {
    return Intl.message(
      'Morning (8:00 AM - 12:00 PM)',
      name: 'time_slot_morning',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon (12:00 PM - 5:00 PM)`
  String get time_slot_afternoon {
    return Intl.message(
      'Afternoon (12:00 PM - 5:00 PM)',
      name: 'time_slot_afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Evening (5:00 PM - 10:00 PM)`
  String get time_slot_evening {
    return Intl.message(
      'Evening (5:00 PM - 10:00 PM)',
      name: 'time_slot_evening',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Tomorrow`
  String get tomorrow {
    return Intl.message('Tomorrow', name: 'tomorrow', desc: '', args: []);
  }

  /// `Choose Date`
  String get custom_date {
    return Intl.message('Choose Date', name: 'custom_date', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
