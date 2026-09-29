/// API Endpoint Strings for ذبائح الممكلة ERP
class ServerStrings {
  ServerStrings._();

  // 1. Authentication Endpoints
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String profile = '/api/v1/me';
  static const String updateProfile = '/api/v1/me';
  static const String refreshToken = '/api/v1/auth/refresh';

  static const String logout = '/api/v1/auth/logout';

  // 2. Categories
  static const String categories = '/api/v1/categories';
  static const String catalogCategories = '/api/v1/catalog/categories';
  static String categoryById(int id) => '/api/v1/catalog/category/$id';
  static String categoryProducts(int id) => '/api/v1/categories/$id/products';

  // 3. Products
  static const String products = '/api/v1/products';
  static const String catalogProducts = '/api/catalog/products';
  static String productById(int id) => '/api/catalog/product/$id';
  static String toggleProductActive(int id) => '/api/v1/products/$id/toggle-active';

  // 4. Cart & Checkout
  static const String cart = '/api/v1/cart';
  static const String addToCart = '/api/v1/cart/add';
  static const String updateCart = '/api/v1/cart/update';
  static String removeCartItem(int productId) => '/api/v1/cart/remove/$productId';
  static const String clearCart = '/api/v1/cart/clear';
  static const String checkout = '/api/v1/checkout';
  static const String paymentMethods = '/api/v1/payment-methods';


  // 5. Coupons & Promo Codes
  static const String coupons = '/api/v1/coupons';
  static String couponById(int id) => '/api/v1/coupons/$id';
  static String toggleCouponActive(int id) => '/api/v1/coupons/$id/toggle-active';
  static const String applyCoupon = '/api/v1/orders/apply-coupon';
  static const String removeCoupon = '/api/v1/orders/remove-coupon';

  // 6. Loyalty Points System
  static const String loyaltySummary = '/api/v1/loyalty/summary';
  static const String loyaltyTransactions = '/api/v1/loyalty/transactions';
  static const String calculateEarn = '/api/v1/loyalty/calculate-earn';
  static const String calculateRedemption = '/api/v1/loyalty/calculate-redemption';
  static const String validateRedemption = '/api/v1/loyalty/validate-redemption';
  static const String redeemPoints = '/api/v1/loyalty/redeem';

  // 7. FCM Push Devices
  static const String registerDevice = '/api/v1/device/register';
  static const String updateDeviceToken = '/api/v1/device/update-token';
  static const String logoutDevice = '/api/v1/device/logout';

  // 8. Notifications
  static const String notifications = '/api/v1/notifications';
  static String notificationById(int id) => '/api/v1/notifications/$id';
  static const String readNotification = '/api/v1/notifications/read';

  // 9. Highlights (Stories)
  static const String highlights = '/api/v1/highlights';
  static String highlightById(int id) => '/api/v1/highlights/$id';

  // 10. Banners, Cutting & Packaging Options
  static const String banners = '/api/v1/banners';
  static String bannerById(int id) => '/api/v1/banners/$id';
  static String toggleBannerActive(int id) => '/api/v1/banners/$id/toggle-active';

  static const String catalogCuttingOptions = '/api/v1/catalog/cutting-options';
  static const String cuttingOptions = '/api/v1/cutting-options';
  static String cuttingOptionById(int id) => '/api/v1/cutting-options/$id';

  static const String catalogPackagings = '/api/v1/catalog/packagings';
  static const String packagings = '/api/v1/packagings';
  static String packagingById(int id) => '/api/v1/packagings/$id';

  static const String catalogExcludedParts = '/api/v1/catalog/excluded-parts';
  static const String excludedParts = '/api/v1/excluded-parts';
  static String excludedPartById(int id) => '/api/v1/excluded-parts/$id';

  // 11. Addresses
  static const String addresses = '/api/v1/addresses';
  static String addressById(int id) => '/api/v1/addresses/$id';
  static String setDefaultAddress(int id) => '/api/v1/addresses/$id/set-default';

  // 12. Orders
  static const String orders = '/api/v1/orders';
  static String orderById(int id) => '/api/v1/orders/$id';
  static String updateOrderStatus(int id) => '/api/v1/orders/$id/status';
  static String cancelOrder(int id) => '/api/v1/orders/$id/cancel';
  static String receiveOrder(int id) => '/api/v1/orders/$id/receive';
  static String orderInvoice(int id) => '/api/v1/orders/$id/invoice';
  static String orderInvoicePdf(int id) => '/api/v1/orders/$id/invoice/pdf';

  // 13. Admin Dashboard & Notifications
  static const String dashboardStats = '/api/v1/dashboard/stats';
  static const String unreadNotificationsCount = '/api/v1/notifications/unread-count';
  static const String adminSendNotification = '/api/v1/admin/notifications/send';
  static const String adminBroadcastNotification = '/api/v1/admin/notifications/broadcast';
  static const String adminUsers = '/api/v1/admin/users';
  static String adminUserById(int id) => '/api/v1/admin/users/$id';
  static String adminUserStatus(int id) => '/api/v1/admin/users/$id/status';

  // 14. Branches & Settings
  static const String branches = '/api/v1/branches';
  static String branchById(int id) => '/api/v1/branches/$id';
  static const String publicSettings = '/api/v1/settings/public';
  static const String updateContactSettings = '/api/v1/admin/settings/contact';

  // 15. Offers / Promotions
  static const String offers = '/api/v1/offers';
  static String offerById(int id) => '/api/v1/offers/$id';
  static String toggleOfferActive(int id) => '/api/v1/offers/$id/toggle-active';

  // 16. Product Carcass Sizes
  static const String sizes = '/api/v1/sizes';
  static String sizeById(int id) => '/api/v1/sizes/$id';
}

