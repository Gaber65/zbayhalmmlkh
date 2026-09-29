import 'package:flutter/material.dart';

/// Provides unified bilingual translations (Arabic & English) for the Admin Dashboard & ERP Management views.
class AdminI18n {
  final bool isArabic;

  const AdminI18n(this.isArabic);

  static AdminI18n of(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return AdminI18n(isAr);
  }

  // ── Layout & Header ──────────────────────────────────────────────────────────
  String get adminTitle => isArabic ? 'نظام إدارة المتجر ERP' : 'Store ERP Management';
  String get adminSubtitle => isArabic ? 'ذبائح المملكة • لوحة التحكم' : 'Dhabayih Al-Mamlaka • Admin Panel';
  String get customerStore => isArabic ? 'متجر العملاء' : 'Customer Store';
  String get notificationCenter => isArabic ? 'مركز الإشعارات' : 'Notifications Center';
  String get lightMode => isArabic ? 'الوضع الفاتح' : 'Light Mode';
  String get darkMode => isArabic ? 'الوضع الليلي' : 'Dark Mode';
  String get switchLang => isArabic ? 'English' : 'العربية';
  String get langBadge => isArabic ? '🇬🇧 EN' : '🇸🇦 عربي';
  String get liveServer => isArabic ? 'متصل بأودو ERP' : 'Connected to Odoo ERP';

  // ── ERP Navigation Drawer ────────────────────────────────────────────────────
  String get erpMenu => isArabic ? 'قائمة النظام (ERP)' : 'ERP Navigation Menu';
  String get menuDashboard => isArabic ? 'لوحة المعلومات والإحصائيات' : 'Dashboard & Analytics';
  String get menuOrders => isArabic ? 'إدارة الطلبات ودورة العمل' : 'Orders & Operations';
  String get menuProducts => isArabic ? 'إدارة المنتجات والمخزون' : 'Products & Inventory';
  String get menuCategories => isArabic ? 'الأقسام وخيارات التخصيص' : 'Categories & Cuts';
  String get menuUsers => isArabic ? 'إدارة العملاء (CRM)' : 'Customer CRM & Loyalty';
  String get menuPayments => isArabic ? 'المدفوعات والمعاملات' : 'Payments & Transactions';
  String get menuMarketing => isArabic ? 'التسويق والحملات الترويجية' : 'Marketing & Promotions';
  String get menuSettings => isArabic ? 'الإعدادات وبرنامج الولاء' : 'Settings & Loyalty Program';
  String get backToStore => isArabic ? 'العودة لمتجر العملاء' : 'Back to Storefront';

  // ── Navigation Tab Compatibility ─────────────────────────────────────────────
  String get tabDashboard => isArabic ? 'الرئيسية' : 'Dashboard';
  String get tabOrders => isArabic ? 'الطلبات' : 'Orders';
  String get tabProducts => isArabic ? 'المنتجات' : 'Products';
  String get tabCategories => isArabic ? 'الأقسام' : 'Categories';
  String get tabMarketing => isArabic ? 'التسويق' : 'Marketing';

  // ── Dashboard Stats & Actions ────────────────────────────────────────────────
  String get totalRevenue => isArabic ? 'إجمالي الإيرادات' : 'Total Revenue';
  String get totalOrders => isArabic ? 'إجمالي الطلبات' : 'Total Orders';
  String get activeOrders => isArabic ? 'الطلبات النشطة' : 'Active Orders';
  String get availableProducts => isArabic ? 'المنتجات المتاحة' : 'Available Products';
  String get registeredCustomers => isArabic ? 'العملاء المسجلين' : 'Registered Customers';
  String get averageOrderValue => isArabic ? 'متوسط قيمة الطلب' : 'Avg Order Value';
  String get quickActions => isArabic ? 'الإجراءات السريعة' : 'Quick Actions';
  String get viewOrders => isArabic ? 'استقبال الطلبات' : 'View Orders';
  String get broadcastPush => isArabic ? 'إشعار عام للعملاء' : 'Broadcast Push';
  String get recentOrders => isArabic ? 'أحدث الطلبات' : 'Recent Orders';
  String get viewAll => isArabic ? 'عرض الكل' : 'View All';
  String get noRecentOrders => isArabic ? 'لا توجد طلبات جديدة حالياً' : 'No recent orders available';
  String get sar => isArabic ? 'ر.س' : 'SAR';
  String get inventoryHealth => isArabic ? 'ملخص صحة المخزون' : 'Inventory Health Summary';
  String get stockCoverage => isArabic ? 'نسبة التغطية' : 'Stock Coverage';
  String get lowStock => isArabic ? 'مخزون منخفض' : 'Low Stock';
  String get outOfStock => isArabic ? 'غير متوفر' : 'Out of Stock';
  String get totalItems => isArabic ? 'إجمالي العناصر' : 'Total Items';
  String get topProducts => isArabic ? 'المنتجات الأكثر مبيعاً' : 'Top Selling Products';

  // ── Order Statuses ───────────────────────────────────────────────────────────
  String get statusDraft => isArabic ? 'مسودة' : 'Draft';
  String get statusPending => isArabic ? 'بانتظار الدفع' : 'Pending Payment';
  String get statusConfirmed => isArabic ? 'مؤكد' : 'Confirmed';
  String get statusProcessing => isArabic ? 'قيد التجهيز والذبح' : 'Preparing';
  String get statusReadyPickup => isArabic ? 'جاهز للاستلام' : 'Ready for Pickup';
  String get statusOutForDelivery => isArabic ? 'خرج للتوصيل' : 'Out for Delivery';
  String get statusDelivered => isArabic ? 'تم التوصيل' : 'Delivered';
  String get statusCancelled => isArabic ? 'ملغي' : 'Cancelled';
  String get statusRefunded => isArabic ? 'مسترجع' : 'Refunded';

  // ── Order Actions ────────────────────────────────────────────────────────────
  String get actionConfirm => isArabic ? 'تأكيد الطلب' : 'Confirm Order';
  String get actionStartPreparing => isArabic ? 'بدء التجهيز والذبح' : 'Start Preparing';
  String get actionMarkReady => isArabic ? 'جاهز للاستلام' : 'Mark Ready';
  String get actionOutForDelivery => isArabic ? 'إرسال مع السائق' : 'Out for Delivery';
  String get actionMarkDelivered => isArabic ? 'تأكيد التسليم بنجاح' : 'Mark Delivered';
  String get actionCancel => isArabic ? 'إلغاء الطلب' : 'Cancel Order';
  String get actionRefund => isArabic ? 'طلب استرجاع' : 'Request Refund';

  // ── Orders View ──────────────────────────────────────────────────────────────
  String get searchOrdersHint => isArabic ? 'ابحث برقم الطلب، اسم العميل، أو رقم الجوال...' : 'Search by order #, customer name or phone...';
  String get filterAll => isArabic ? 'الكل' : 'All';
  String get filterNew => isArabic ? 'جديد' : 'New';
  String get filterConfirmed => isArabic ? 'مؤكد' : 'Confirmed';
  String get filterProcessing => isArabic ? 'قيد التجهيز' : 'Processing';
  String get filterReadyPickup => isArabic ? 'جاهز للاستلام' : 'Ready';
  String get filterDelivering => isArabic ? 'قيد التوصيل' : 'Delivering';
  String get filterCompleted => isArabic ? 'مكتمل' : 'Completed';
  String get filterCancelled => isArabic ? 'ملغي ومسترجع' : 'Cancelled';
  String get noOrdersFound => isArabic ? 'لا توجد طلبات مطابقة' : 'No matching orders found';
  String get orderNumber => isArabic ? 'طلب رقم' : 'Order #';
  String get itemsCount => isArabic ? 'منتجات' : 'Items';
  String get deliveryAddress => isArabic ? 'عنوان التوصيل' : 'Delivery Address';
  String get changeStatus => isArabic ? 'تحديث حالة الطلب' : 'Update Order Status';
  String get orderTimeline => isArabic ? 'الخط الزمني وتاريخ الطلب' : 'Order Timeline';
  String get deliveryTypeHome => isArabic ? 'توصيل للمنزل' : 'Home Delivery';
  String get deliveryTypePickup => isArabic ? 'استلام من الفرع' : 'Store Pickup';

  // ── Products View ────────────────────────────────────────────────────────────
  String get searchProductsHint => isArabic ? 'ابحث بالاسم، رمز الصنف (SKU)، أو الباركود...' : 'Search by product name, SKU, or barcode...';
  String get allCategories => isArabic ? 'جميع الأقسام' : 'All Categories';
  String get available => isArabic ? 'متوفر' : 'Available';
  String get unavailable => isArabic ? 'غير متوفر' : 'Unavailable';
  String get onOffer => isArabic ? 'عرض خاص' : 'On Offer';
  String get bestSeller => isArabic ? 'أكثر مبيعاً' : 'Best Seller';
  String get featured => isArabic ? 'مميز' : 'Featured';
  String get stockUnlimited => isArabic ? 'كمية غير محدودة' : 'Unlimited Stock';
  String get stockUnits => isArabic ? 'وحدة' : 'units';
  String get loyaltyPoints => isArabic ? 'نقطة ولاء' : 'Loyalty Points';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get deleteConfirmTitle => isArabic ? 'حذف العنصر' : 'Delete Item';
  String get deleteConfirmMsg => isArabic ? 'هل أنت متأكد من رغبتك في حذف هذا العنصر؟' : 'Are you sure you want to delete this item?';
  String get deleteSuccess => isArabic ? 'تم الحذف بنجاح' : 'Deleted successfully';
  String get saveSuccess => isArabic ? 'تم الحفظ بنجاح' : 'Saved successfully';
  String get addProduct => isArabic ? 'إضافة منتج' : 'Add Product';
  String get skuLabel => isArabic ? 'رمز الصنف (SKU)' : 'SKU Code';
  String get barcodeLabel => isArabic ? 'الباركود' : 'Barcode';
  String get purchasePriceLabel => isArabic ? 'سعر التكلفة (الشراء)' : 'Purchase / Cost Price';
  String get profitMarginLabel => isArabic ? 'هامش الربح' : 'Profit Margin';
  String get profitPercentageLabel => isArabic ? 'نسبة الربح' : 'Profit %';
  String get minStockLabel => isArabic ? 'الحد الأدنى للتنبيه' : 'Min Stock Alert';
  String get lowStockLabel => isArabic ? 'مخزون منخفض' : 'Low Stock';
  String get weightLabel => isArabic ? 'الوزن (كجم)' : 'Weight (kg)';
  String get prepTimeLabel => isArabic ? 'وقت التجهيز (دقيقة)' : 'Prep Time (min)';
  String get quickStockUpdate => isArabic ? 'تعديل كمية المخزون' : 'Quick Stock Update';
  String get tabBasicInfo => isArabic ? 'البيانات الأساسية' : 'Basic Info';
  String get tabPricing => isArabic ? 'الأسعار والربحية' : 'Pricing & Profit';
  String get tabInventory => isArabic ? 'المخزون والخيارات' : 'Stock & Options';
  String get tabMedia => isArabic ? 'الصور والمعرض' : 'Media & Gallery';

  // ── CRM & Users View ─────────────────────────────────────────────────────────
  String get searchUsersHint => isArabic ? 'بحث بالاسم، الجوال، أو البريد الإلكتروني...' : 'Search by name, phone, or email...';
  String get activeUsers => isArabic ? 'حسابات نشطة' : 'Active Users';
  String get suspendedUsers => isArabic ? 'حسابات معلقة' : 'Suspended Users';
  String get individualUsers => isArabic ? 'أفراد' : 'Individuals';
  String get businessUsers => isArabic ? 'شركات' : 'Business';
  String get adjustPoints => isArabic ? 'تسوية النقاط' : 'Adjust Points';
  String get currentBalance => isArabic ? 'الرصيد الحالي' : 'Current Balance';
  String get addPoints => isArabic ? '+ إضافة نقاط' : '+ Add Points';
  String get deductPoints => isArabic ? '- خصم نقاط' : '- Deduct Points';
  String get pointsCount => isArabic ? 'عدد النقاط' : 'Points Count';
  String get reasonLabel => isArabic ? 'سبب التسوية' : 'Adjustment Reason';
  String get totalSpent => isArabic ? 'إجمالي المشتريات' : 'Total Spent';
  String get savedAddresses => isArabic ? 'العناوين المسجلة' : 'Saved Addresses';
  String get noAddresses => isArabic ? 'لا توجد عناوين مسجلة للعميل' : 'No saved addresses for this user';
  String get suspendAccount => isArabic ? 'تعليق الحساب' : 'Suspend Account';
  String get activateAccount => isArabic ? 'تنشيط الحساب' : 'Activate Account';
  String get statusActive => isArabic ? 'نشط' : 'Active';
  String get statusSuspended => isArabic ? 'معلق' : 'Suspended';
  String get pointsAdjustSuccess => isArabic ? 'تمت تسوية النقاط بنجاح' : 'Points adjusted successfully';
  String get accountActivated => isArabic ? 'تم تنشيط الحساب بنجاح' : 'Account activated successfully';
  String get accountSuspended => isArabic ? 'تم تعليق الحساب بنجاح' : 'Account suspended successfully';

  // ── Payments & Transactions ──────────────────────────────────────────────────
  String get paymentsTitle => isArabic ? 'المدفوعات والمعاملات' : 'Payments & Transactions';
  String get tabPaymentTransactions => isArabic ? 'معاملات الدفع' : 'Payment Transactions';
  String get tabLoyaltyHistory => isArabic ? 'سجل حركات الولاء' : 'Loyalty Points History';
  String get searchPaymentsHint => isArabic ? 'بحث برقم الطلب، العميل، أو المرجع...' : 'Search by order #, customer, or ref...';
  String get paymentMethod => isArabic ? 'طريقة الدفع' : 'Payment Method';
  String get paymentStatus => isArabic ? 'حالة المعاملة' : 'Transaction Status';
  String get amount => isArabic ? 'المبلغ' : 'Amount';
  String get transactionRef => isArabic ? 'الرقم المرجعي' : 'Transaction Ref';
  String get date => isArabic ? 'التاريخ' : 'Date';

  // ── Settings & Loyalty View ──────────────────────────────────────────────────
  String get loyaltySettingsTitle => isArabic ? 'إعدادات المتجر وبرنامج الولاء' : 'Store & Loyalty Settings';
  String get earningRate => isArabic ? 'معدل اكتساب النقاط (لكل 1 ر.س)' : 'Earning Rate (per 1 SAR)';
  String get redemptionRate => isArabic ? 'معدل الاستبدال (نقاط مقابل 1 ر.س)' : 'Redemption Rate (pts per 1 SAR)';
  String get minRedemption => isArabic ? 'الحد الأدنى لاستبدال النقاط' : 'Min Points for Redemption';
  String get saveSettings => isArabic ? 'حفظ التغييرات في النظام' : 'Save Changes to System';
  String get settingsSaved => isArabic ? 'تم حفظ إعدادات الولاء بنجاح' : 'Loyalty settings saved successfully';

  // ── Categories & Options ─────────────────────────────────────────────────────
  String get tabSubCategories => isArabic ? 'الأقسام والتصنيفات' : 'Categories';
  String get tabSubCuts => isArabic ? 'خيارات التقطيع' : 'Cutting Options';
  String get tabSubPackaging => isArabic ? 'خيارات التغليف' : 'Packaging Options';
  String get tabSubExcluded => isArabic ? 'الأجزاء المستثناة' : 'Excluded Parts';
  String get addCategory => isArabic ? 'إضافة قسم' : 'Add Category';
  String get addCutOption => isArabic ? 'إضافة خيار تقطيع' : 'Add Cutting Option';
  String get addPackagingOption => isArabic ? 'إضافة نوع تغليف' : 'Add Packaging Type';
  String get addExcludedOption => isArabic ? 'إضافة جزء مستثنى' : 'Add Excluded Part';
  String get categoryName => isArabic ? 'اسم القسم' : 'Category Name';
  String get description => isArabic ? 'الوصف' : 'Description';
  String get searchCategoriesHint => isArabic ? 'بحث في الأقسام أو خيارات التخصيص...' : 'Search categories or options...';
  String get freeOption => isArabic ? 'مجاني (بدون رسوم)' : 'Free (No Extra Fee)';
  String get extraFee => isArabic ? 'رسوم إضافية' : 'Extra Fee';
  String get productsCount => isArabic ? 'منتج' : 'products';
  String get filterWithFee => isArabic ? 'برسوم إضافية' : 'With Extra Fee';
  String get filterFree => isArabic ? 'مجاني' : 'Free';
  String get deleteCategoryConfirm => isArabic ? 'هل أنت متأكد من رغبتك في حذف هذا القسم نهائياً؟' : 'Are you sure you want to permanently delete this category?';
  String get deleteOptionConfirm => isArabic ? 'هل أنت متأكد من رغبتك في حذف هذا الخيار نهائياً؟' : 'Are you sure you want to permanently delete this option?';
  String get noCategoriesFound => isArabic ? 'لم يتم العثور على أي أقسام مطابقة' : 'No matching categories found';
  String get noOptionsFound => isArabic ? 'لم يتم العثور على أي خيارات مطابقة' : 'No matching options found';
  String get categoryDetails => isArabic ? 'بيانات وتفاصيل القسم' : 'Category Details';
  String get optionStatusActive => isArabic ? 'متاح للطلب' : 'Available for ordering';
  String get optionStatusInactive => isArabic ? 'غير متاح حالياً' : 'Currently unavailable';

  // ── Marketing View ───────────────────────────────────────────────────────────
  String get tabCoupons => isArabic ? 'أكواد الخصم والكوبونات' : 'Coupons & Promo Codes';
  String get tabBanners => isArabic ? 'البنرات الإعلانية' : 'Promotional Banners';
  String get sendInstantPush => isArabic ? 'إرسال إشعار فوري لجميع العملاء' : 'Send Instant Push Notification to All Customers';
  String get addCoupon => isArabic ? 'إضافة كود خصم' : 'Add Promo Code';
  String get addBanner => isArabic ? 'إضافة بنر إعلاني' : 'Add Banner';
  String get couponCode => isArabic ? 'كود الخصم' : 'Promo Code';
  String get discountPercentage => isArabic ? 'نسبة الخصم' : 'Discount Percentage';
  String get minOrderAmount => isArabic ? 'الحد الأدنى للطلب' : 'Min Order Amount';
  String get maxUses => isArabic ? 'أقصى عدد استخدام' : 'Max Uses';
  String get active => isArabic ? 'نشط' : 'Active';
  String get inactive => isArabic ? 'معطل' : 'Inactive';

  // ── Common Dialog & Form Fields ──────────────────────────────────────────────
  String get uploadFromDevice => isArabic ? 'رفع صورة من جهازك' : 'Upload Image from Device';
  String get tapToUpload => isArabic ? 'اضغط لاختيار صورة من جهازك' : 'Tap to select an image from your device';
  String get changeImage => isArabic ? 'تغيير الصورة' : 'Change Image';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get saveChanges => isArabic ? 'حفظ التعديلات' : 'Save Changes';
  String get saving => isArabic ? 'جاري الحفظ...' : 'Saving...';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get productName => isArabic ? 'اسم المنتج / الذبيحة *' : 'Product / Sacrifice Name *';
  String get basePrice => isArabic ? 'السعر الأساسي (ر.س) *' : 'Base Price (SAR) *';
  String get offerPrice => isArabic ? 'سعر العرض المخفض (ر.س)' : 'Discounted Offer Price (SAR)';
  String get stockQuantity => isArabic ? 'الكمية المتوفرة بالمخزون' : 'Available Stock Quantity';
  String get category => isArabic ? 'القسم *' : 'Category *';
  String get fieldRequired => isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
  String get totalProducts => isArabic ? 'إجمالي المنتجات' : 'Total Products';
  String get bannerTitle => isArabic ? 'عنوان البنر' : 'Banner Title';
  String get bannerLink => isArabic ? 'الرابط / التوجيه' : 'Link / Action Target';
  String get price => isArabic ? 'السعر' : 'Price';
  String get extraPrice => isArabic ? 'سعر إضافي' : 'Extra Price';
  String get optionName => isArabic ? 'اسم الخيار' : 'Option Name';
  String get discountAmount => isArabic ? 'مبلغ الخصم' : 'Discount Amount';
  String get imageUploadLabel => isArabic ? 'صورة العنصر (رفع من الجهاز)' : 'Item Image (Upload from device)';
  String get orderDetailsTitle => isArabic ? 'تفاصيل الطلب' : 'Order Details';
  String get pushNotificationTitle => isArabic ? 'إرسال إشعار عام للعملاء' : 'Broadcast Push Notification';
  String get pushTitleLabel => isArabic ? 'عنوان الإشعار *' : 'Notification Title *';
  String get pushBodyLabel => isArabic ? 'نص الإشعار *' : 'Notification Body *';
  String get pushSendBtn => isArabic ? 'إرسال الإشعار الآن' : 'Send Notification Now';
  String get pushSuccess => isArabic ? 'تم إرسال الإشعار بنجاح لجميع العملاء' : 'Notification broadcast sent successfully!';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
}




