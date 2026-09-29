// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(count) => "تم إضافة ${count} عنصر إلى السلة";

  static String m1(label) =>
      "هل تريد حذف \"${label}\"؟ لا يمكن التراجع عن هذا.";

  static String m2(points) => "النقاط المتاحة: ${points}";

  static String m3(count) => "سلة التسوق بها ${count} عناصر";

  static String m4(count) => "${count} منتج";

  static String m5(query) => "لم يتم العثور على نتائج لـ \"${query}\"";

  static String m6(price) => "طلب أونلاين  •  ${price} ر.س";

  static String m7(count) => "${count} نقطة";

  static String m8(count) => "4.7 نجوم (${count} تقييم)";

  static String m9(value) => "${value} ر.س";

  static String m10(amount) => "توفير ${amount} ر.س";

  static String m11(count) => "قطع طازجة (${count})";

  static String m12(count) => "الأكثر مبيعاً (${count})";

  static String m13(count) => "خاص (${count})";

  static String m14(count) => "${count} كجم";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "active_orders": MessageLookupByLibrary.simpleMessage("النشطة"),
    "add_to_cart": MessageLookupByLibrary.simpleMessage("إضافة للسلة"),
    "added_to_cart": m0,
    "addr_add_new": MessageLookupByLibrary.simpleMessage("إضافة عنوان"),
    "addr_add_new_short": MessageLookupByLibrary.simpleMessage(
      "إضافة عنوان جديد",
    ),
    "addr_additional_section": MessageLookupByLibrary.simpleMessage(
      "معلومات إضافية",
    ),
    "addr_apartment": MessageLookupByLibrary.simpleMessage("الشقة"),
    "addr_branch_hours": MessageLookupByLibrary.simpleMessage(
      "يومياً: ٨:٠٠ ص - ١١:٠٠ م",
    ),
    "addr_branch_main": MessageLookupByLibrary.simpleMessage(
      "الفرع الرئيسي - الرياض",
    ),
    "addr_branch_rawdah": MessageLookupByLibrary.simpleMessage(
      "فرع الروضة - الرياض",
    ),
    "addr_branch_sahafa": MessageLookupByLibrary.simpleMessage(
      "فرع الصحافة - الرياض",
    ),
    "addr_building": MessageLookupByLibrary.simpleMessage("المبنى"),
    "addr_building_section": MessageLookupByLibrary.simpleMessage(
      "تفاصيل المبنى",
    ),
    "addr_city": MessageLookupByLibrary.simpleMessage("المدينة"),
    "addr_confirm_location": MessageLookupByLibrary.simpleMessage(
      "تأكيد الموقع",
    ),
    "addr_confirm_selection": MessageLookupByLibrary.simpleMessage(
      "تأكيد الاختيار",
    ),
    "addr_default_set": MessageLookupByLibrary.simpleMessage(
      "تم تحديث العنوان الافتراضي",
    ),
    "addr_delete_confirm": m1,
    "addr_delete_title": MessageLookupByLibrary.simpleMessage("حذف العنوان"),
    "addr_deleted_success": MessageLookupByLibrary.simpleMessage(
      "تم حذف العنوان",
    ),
    "addr_delivery": MessageLookupByLibrary.simpleMessage("توصيل للمنزل"),
    "addr_edit_address": MessageLookupByLibrary.simpleMessage("تعديل العنوان"),
    "addr_empty_subtitle": MessageLookupByLibrary.simpleMessage(
      "أضف عنوان توصيلك الأول للبدء.",
    ),
    "addr_empty_title": MessageLookupByLibrary.simpleMessage(
      "لا توجد عناوين محفوظة",
    ),
    "addr_enable_gps": MessageLookupByLibrary.simpleMessage("تفعيل GPS"),
    "addr_floor": MessageLookupByLibrary.simpleMessage("الطابق"),
    "addr_full_address": MessageLookupByLibrary.simpleMessage("الموقع المحدد"),
    "addr_geocoding_failed": MessageLookupByLibrary.simpleMessage(
      "تعذّر تحديد العنوان",
    ),
    "addr_gps_disabled": MessageLookupByLibrary.simpleMessage("نظام GPS معطّل"),
    "addr_is_default": MessageLookupByLibrary.simpleMessage("افتراضي"),
    "addr_label_home": MessageLookupByLibrary.simpleMessage("المنزل"),
    "addr_label_other": MessageLookupByLibrary.simpleMessage("أخرى"),
    "addr_label_other_hint": MessageLookupByLibrary.simpleMessage(
      "اسم التصنيف",
    ),
    "addr_label_title": MessageLookupByLibrary.simpleMessage("تصنيف العنوان"),
    "addr_label_work": MessageLookupByLibrary.simpleMessage("العمل"),
    "addr_landmark": MessageLookupByLibrary.simpleMessage("معلم قريب"),
    "addr_my_addresses": MessageLookupByLibrary.simpleMessage("عناويني"),
    "addr_network_error": MessageLookupByLibrary.simpleMessage(
      "خطأ في الشبكة. يرجى المحاولة مرة أخرى.",
    ),
    "addr_notes": MessageLookupByLibrary.simpleMessage("ملاحظات التوصيل"),
    "addr_open_settings": MessageLookupByLibrary.simpleMessage("فتح الإعدادات"),
    "addr_permission_denied": MessageLookupByLibrary.simpleMessage(
      "تم رفض إذن الموقع",
    ),
    "addr_pickup": MessageLookupByLibrary.simpleMessage("الاستلام من الفرع"),
    "addr_recipient_name": MessageLookupByLibrary.simpleMessage("اسم المستلم"),
    "addr_recipient_phone": MessageLookupByLibrary.simpleMessage(
      "هاتف المستلم",
    ),
    "addr_recipient_section": MessageLookupByLibrary.simpleMessage(
      "بيانات المستلم",
    ),
    "addr_required": MessageLookupByLibrary.simpleMessage("هذا الحقل مطلوب"),
    "addr_saved_success": MessageLookupByLibrary.simpleMessage(
      "تم حفظ العنوان بنجاح",
    ),
    "addr_searching": MessageLookupByLibrary.simpleMessage(
      "جاري تحديد العنوان...",
    ),
    "addr_select_address": MessageLookupByLibrary.simpleMessage(
      "اختر عنوان التوصيل",
    ),
    "addr_select_branch": MessageLookupByLibrary.simpleMessage(
      "اختر فرع الاستلام",
    ),
    "addr_select_delivery_type": MessageLookupByLibrary.simpleMessage(
      "نوع التوصيل",
    ),
    "addr_set_default": MessageLookupByLibrary.simpleMessage("تعيين كافتراضي"),
    "addr_set_default_hint": MessageLookupByLibrary.simpleMessage(
      "استخدم هذا العنوان كعنوان توصيل افتراضي",
    ),
    "addr_street": MessageLookupByLibrary.simpleMessage("الشارع / الطريق"),
    "addr_title": MessageLookupByLibrary.simpleMessage("تحديد موقع التوصيل"),
    "addr_updated_success": MessageLookupByLibrary.simpleMessage(
      "تم تحديث العنوان بنجاح",
    ),
    "addr_use_current": MessageLookupByLibrary.simpleMessage("موقعي الحالي"),
    "already_have_account": MessageLookupByLibrary.simpleMessage(
      "لديك حساب بالفعل؟",
    ),
    "app_language": MessageLookupByLibrary.simpleMessage("لغة التطبيق"),
    "app_name": MessageLookupByLibrary.simpleMessage("ذبائح المملكة"),
    "apply": MessageLookupByLibrary.simpleMessage("تطبيق"),
    "apply_filters": MessageLookupByLibrary.simpleMessage("تطبيق الفلاتر"),
    "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "available_points": m2,
    "badge_delivery_subtitle": MessageLookupByLibrary.simpleMessage(
      "في نفس اليوم",
    ),
    "badge_delivery_title": MessageLookupByLibrary.simpleMessage("توصيل سريع"),
    "badge_fresh_subtitle": MessageLookupByLibrary.simpleMessage(
      "من المزرعة مباشرة",
    ),
    "badge_fresh_title": MessageLookupByLibrary.simpleMessage("طازج 100%"),
    "badge_hygienic_subtitle": MessageLookupByLibrary.simpleMessage(
      "معتمد وموثق",
    ),
    "badge_hygienic_title": MessageLookupByLibrary.simpleMessage("ذبح صحي"),
    "best_sellers": MessageLookupByLibrary.simpleMessage("الأكثر مبيعاً"),
    "branch_pickup": MessageLookupByLibrary.simpleMessage("الاستلام من الفرع"),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "cancel_order": MessageLookupByLibrary.simpleMessage("إلغاء الطلب"),
    "cancel_order_confirm": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من إلغاء هذا الطلب؟",
    ),
    "cancel_order_error": MessageLookupByLibrary.simpleMessage(
      "فشل إلغاء الطلب",
    ),
    "cancel_order_success": MessageLookupByLibrary.simpleMessage(
      "تم إلغاء الطلب بنجاح",
    ),
    "cancelled_orders": MessageLookupByLibrary.simpleMessage("الملغاة"),
    "cart_add_error": MessageLookupByLibrary.simpleMessage(
      "فشل إضافة المنتج للسلة",
    ),
    "cart_add_success": MessageLookupByLibrary.simpleMessage(
      "تم إضافة المنتج للسلة",
    ),
    "cart_empty": MessageLookupByLibrary.simpleMessage("عربة التسوق فارغة"),
    "cart_item_removed": MessageLookupByLibrary.simpleMessage(
      "تم حذف المنتج من السلة",
    ),
    "cart_semantics_count": m3,
    "cart_semantics_empty": MessageLookupByLibrary.simpleMessage(
      "سلة التسوق فارغة",
    ),
    "cart_updated": MessageLookupByLibrary.simpleMessage(
      "تم تحديث السلة بنجاح",
    ),
    "cash_on_delivery": MessageLookupByLibrary.simpleMessage(
      "الدفع عند الاستلام",
    ),
    "categories_title": MessageLookupByLibrary.simpleMessage("التصنيفات"),
    "checkout": MessageLookupByLibrary.simpleMessage("إتمام الطلب"),
    "checkout_success": MessageLookupByLibrary.simpleMessage(
      "تم تقديم الطلب بنجاح",
    ),
    "checkout_title": MessageLookupByLibrary.simpleMessage("إتمام الطلب"),
    "confirm_order": MessageLookupByLibrary.simpleMessage("تأكيد الطلب"),
    "continue_as_guest": MessageLookupByLibrary.simpleMessage("المتابعة كزائر"),
    "continue_shopping": MessageLookupByLibrary.simpleMessage("مواصلة التسوق"),
    "country_egypt": MessageLookupByLibrary.simpleMessage("مصر 🇪🇬"),
    "coupon_applied": MessageLookupByLibrary.simpleMessage(
      "تم تطبيق كود الخصم بنجاح",
    ),
    "coupon_code": MessageLookupByLibrary.simpleMessage("كود الخصم"),
    "coupon_hint": MessageLookupByLibrary.simpleMessage("أدخل كود الخصم"),
    "coupon_invalid": MessageLookupByLibrary.simpleMessage(
      "كود الخصم غير صحيح",
    ),
    "crafted_by": MessageLookupByLibrary.simpleMessage(
      "صُنع بأعلى معايير الجودة",
    ),
    "created_by": MessageLookupByLibrary.simpleMessage("تطبيق ذبائح المملكة"),
    "current_location": MessageLookupByLibrary.simpleMessage("الموقع الحالي"),
    "custom_date": MessageLookupByLibrary.simpleMessage("تحديد تاريخ"),
    "cutting_halves": MessageLookupByLibrary.simpleMessage("أنصاف"),
    "cutting_options": MessageLookupByLibrary.simpleMessage("خيارات التتقطيع"),
    "cutting_quarters": MessageLookupByLibrary.simpleMessage("أرباع"),
    "cutting_small_pieces": MessageLookupByLibrary.simpleMessage("قطع صغيرة"),
    "cutting_whole": MessageLookupByLibrary.simpleMessage("كامل"),
    "dark_mode": MessageLookupByLibrary.simpleMessage("المظهر الداكن"),
    "default_location_mock": MessageLookupByLibrary.simpleMessage(
      "الرياض، السعودية",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "delivery_fee": MessageLookupByLibrary.simpleMessage("رسوم التوصيل"),
    "delivery_schedule": MessageLookupByLibrary.simpleMessage("موعد التوصيل"),
    "delivery_to": MessageLookupByLibrary.simpleMessage("التوصيل إلى"),
    "disabled": MessageLookupByLibrary.simpleMessage("ملغى"),
    "discount": MessageLookupByLibrary.simpleMessage("الخصم"),
    "done": MessageLookupByLibrary.simpleMessage("تم"),
    "edit": MessageLookupByLibrary.simpleMessage("تعديل"),
    "edit_profile": MessageLookupByLibrary.simpleMessage("تعديل الملف الشخصي"),
    "email_hint": MessageLookupByLibrary.simpleMessage("hello@dhabayih.com"),
    "email_label": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "enabled": MessageLookupByLibrary.simpleMessage("مفعّل"),
    "english": MessageLookupByLibrary.simpleMessage("ENGLISH"),
    "error_retry": MessageLookupByLibrary.simpleMessage(
      "حدث خطأ. اضغط للمحاولة مرة أخرى.",
    ),
    "excluded_parts": MessageLookupByLibrary.simpleMessage("الأجزاء المستثناة"),
    "explore_catalog": MessageLookupByLibrary.simpleMessage(
      "تصفح قائمة منتجاتنا وأضف بعض العناصر.",
    ),
    "fast_service": MessageLookupByLibrary.simpleMessage("خدمة سريعة"),
    "featured_products": MessageLookupByLibrary.simpleMessage(
      "المنتجات المميزة",
    ),
    "filters": MessageLookupByLibrary.simpleMessage("الفلاتر"),
    "fresh_daily": MessageLookupByLibrary.simpleMessage("طازج يومياً"),
    "fresh_harvest": MessageLookupByLibrary.simpleMessage(
      "حصاد طازج -\nمن المزرعة إلى مائدتك",
    ),
    "general_settings": MessageLookupByLibrary.simpleMessage(
      "الإعدادات العامة",
    ),
    "get_started": MessageLookupByLibrary.simpleMessage("البدء الآن"),
    "guest_subtitle": MessageLookupByLibrary.simpleMessage(
      "سجل الدخول للاستفادة من كافة الميزات",
    ),
    "guest_user": MessageLookupByLibrary.simpleMessage("مستخدم زائر"),
    "halal_compliance": MessageLookupByLibrary.simpleMessage("ذبح حلال 100%"),
    "hello_label": MessageLookupByLibrary.simpleMessage("مرحباً! "),
    "home": MessageLookupByLibrary.simpleMessage("الرئيسية"),
    "home_address_mock": MessageLookupByLibrary.simpleMessage(
      "المنزل - الرياض، السعودية",
    ),
    "home_cta_subtitle": MessageLookupByLibrary.simpleMessage(
      "استمتع بأعلى جودة مع الذبح الإسلامي المعتمد والنقل المبرد.",
    ),
    "home_cta_title": MessageLookupByLibrary.simpleMessage(
      "تشكيلة الذبائح الطازجة",
    ),
    "home_intro_subtitle": MessageLookupByLibrary.simpleMessage(
      "اكتشف اللحوم الطازجة والمنتجات الفاخرة",
    ),
    "home_subtitle": MessageLookupByLibrary.simpleMessage(
      "اختر ذبيحتك الطازجة وتفاصيل التقطيع والتوصيل السريع بسهولة.",
    ),
    "home_title": MessageLookupByLibrary.simpleMessage("ذبائح المملكة"),
    "hot_tag": MessageLookupByLibrary.simpleMessage("مميز"),
    "in_stock": MessageLookupByLibrary.simpleMessage("متوفر"),
    "items_count": m4,
    "loading": MessageLookupByLibrary.simpleMessage("جاري التحميل..."),
    "loading_product": MessageLookupByLibrary.simpleMessage(
      "جاري تحميل المنتج...",
    ),
    "login_back": MessageLookupByLibrary.simpleMessage("مجدداً"),
    "login_register": MessageLookupByLibrary.simpleMessage(
      "تسجيل الدخول / التسجيل",
    ),
    "login_required": MessageLookupByLibrary.simpleMessage(
      "تسجيل الدخول مطلوب",
    ),
    "login_required_desc": MessageLookupByLibrary.simpleMessage(
      "يرجى تسجيل الدخول للاستفادة من هذه الميزة.",
    ),
    "login_subtitle": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال بياناتك للاستمتاع بتجربة تسوق فاخرة.",
    ),
    "login_welcome": MessageLookupByLibrary.simpleMessage("مرحباً بك"),
    "logout": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "logout_confirmation": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من أنك تريد تسجيل الخروج؟",
    ),
    "loyalty_discount": MessageLookupByLibrary.simpleMessage("خصم نقاط الولاء"),
    "loyalty_points": MessageLookupByLibrary.simpleMessage("نقاط الولاء"),
    "made_with_love": MessageLookupByLibrary.simpleMessage(
      "صُنع لتطبيق ذبائح المملكة",
    ),
    "my_cart": MessageLookupByLibrary.simpleMessage("عربة التسوق"),
    "name_label": MessageLookupByLibrary.simpleMessage("الاسم"),
    "new_season": MessageLookupByLibrary.simpleMessage("موسم جديد"),
    "newest_arrivals": MessageLookupByLibrary.simpleMessage("أحدث المنتجات"),
    "next": MessageLookupByLibrary.simpleMessage("التالي"),
    "no_categories": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على تصنيفات.",
    ),
    "no_cutting_options": MessageLookupByLibrary.simpleMessage(
      "لا توجد خيارات تقطيع",
    ),
    "no_excluded_parts": MessageLookupByLibrary.simpleMessage(
      "لا توجد أجزاء للاستثناء",
    ),
    "no_media_available": MessageLookupByLibrary.simpleMessage(
      "لا توجد وسائط متاحة",
    ),
    "no_orders": MessageLookupByLibrary.simpleMessage("لا توجد طلبات"),
    "no_packaging_options": MessageLookupByLibrary.simpleMessage(
      "لا توجد خيارات تغليف",
    ),
    "no_products_in_category": MessageLookupByLibrary.simpleMessage(
      "لا توجد منتجات في هذا التصنيف",
    ),
    "no_results_for": m5,
    "notes_hint": MessageLookupByLibrary.simpleMessage(
      "مثال: بدون دهون، تقطيع خاص...",
    ),
    "notes_label": MessageLookupByLibrary.simpleMessage("ملاحظات إضافية"),
    "notifications": MessageLookupByLibrary.simpleMessage("الإشعارات"),
    "offer_price_label": MessageLookupByLibrary.simpleMessage("سعر العرض"),
    "onboarding_desc_1": MessageLookupByLibrary.simpleMessage(
      "اختر من بين أجود أنواع الأغنام والعجول المختارة بعناية فائقة.",
    ),
    "onboarding_desc_2": MessageLookupByLibrary.simpleMessage(
      "خيارات تقطيع متعددة وتغليف سحب هواء مفرغ للحفاظ على الطازج.",
    ),
    "onboarding_desc_3": MessageLookupByLibrary.simpleMessage(
      "نصلك إلى باب منزلك في سيارات مجهزة ومبردة خصيصاً للحفاظ على السلامة.",
    ),
    "onboarding_feature_1": MessageLookupByLibrary.simpleMessage(
      "ذبائح طازجة ومضمونة الجودة",
    ),
    "onboarding_feature_2": MessageLookupByLibrary.simpleMessage(
      "تجهيز وتقطيع حسب طلبك الخاطف",
    ),
    "onboarding_feature_3": MessageLookupByLibrary.simpleMessage(
      "ذبح حلال 100% وفق الشريعة الإسلامية",
    ),
    "onboarding_title_1": MessageLookupByLibrary.simpleMessage(
      "ذبائح بلدية طازجة",
    ),
    "onboarding_title_2": MessageLookupByLibrary.simpleMessage(
      "تقطيع وتغليف حسب طلبك",
    ),
    "onboarding_title_3": MessageLookupByLibrary.simpleMessage(
      "توصيل مبرد ومباشر",
    ),
    "open_now": MessageLookupByLibrary.simpleMessage("مفتوح الآن"),
    "optional_field": MessageLookupByLibrary.simpleMessage("اختياري"),
    "order_date": MessageLookupByLibrary.simpleMessage("تاريخ الطلب"),
    "order_details": MessageLookupByLibrary.simpleMessage("تفاصيل الطلب"),
    "order_history": MessageLookupByLibrary.simpleMessage("تاريخ الطلبات"),
    "order_number": MessageLookupByLibrary.simpleMessage("رقم الطلب"),
    "order_online_price": m6,
    "order_status": MessageLookupByLibrary.simpleMessage("حالة الطلب"),
    "order_status_cancelled": MessageLookupByLibrary.simpleMessage("ملغي"),
    "order_status_confirmed": MessageLookupByLibrary.simpleMessage("مؤكد"),
    "order_status_delivered": MessageLookupByLibrary.simpleMessage(
      "تم التوصيل",
    ),
    "order_status_draft": MessageLookupByLibrary.simpleMessage("مسودة"),
    "order_status_out": MessageLookupByLibrary.simpleMessage("خارج للتوصيل"),
    "order_status_pending": MessageLookupByLibrary.simpleMessage(
      "في انتظار الدفع",
    ),
    "order_status_preparing": MessageLookupByLibrary.simpleMessage(
      "جاري التجهيز",
    ),
    "order_status_ready": MessageLookupByLibrary.simpleMessage("جاهز للاستلام"),
    "order_status_refunded": MessageLookupByLibrary.simpleMessage("مسترجع"),
    "order_summary": MessageLookupByLibrary.simpleMessage("ملخص الطلب"),
    "order_total": MessageLookupByLibrary.simpleMessage("الإجمالي"),
    "orders": MessageLookupByLibrary.simpleMessage("الطلبات"),
    "orders_title": MessageLookupByLibrary.simpleMessage("طلباتي"),
    "original_price_label": MessageLookupByLibrary.simpleMessage(
      "السعر الأصلي",
    ),
    "out_of_stock": MessageLookupByLibrary.simpleMessage("نفذ المخزون"),
    "packaging_options": MessageLookupByLibrary.simpleMessage("خيارات التغليف"),
    "payment_method": MessageLookupByLibrary.simpleMessage("طريقة الدفع"),
    "phone_label": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
    "pkg_gift_box": MessageLookupByLibrary.simpleMessage("صندوق هدايا"),
    "pkg_standard": MessageLookupByLibrary.simpleMessage("عادي"),
    "pkg_vacuum": MessageLookupByLibrary.simpleMessage("سحب هواء (مفرغ)"),
    "points_count": m7,
    "popular_searches": MessageLookupByLibrary.simpleMessage(
      "عمليات البحث الشائعة",
    ),
    "previous_orders": MessageLookupByLibrary.simpleMessage("السابقة"),
    "price_high_to_low": MessageLookupByLibrary.simpleMessage(
      "السعر: من الأعلى للأقل",
    ),
    "price_low_to_high": MessageLookupByLibrary.simpleMessage(
      "السعر: من الأقل للأعلى",
    ),
    "price_range": MessageLookupByLibrary.simpleMessage("نطاق السعر"),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("سياسة الخصوصية"),
    "proceed_checkout": MessageLookupByLibrary.simpleMessage(
      "المتابعة لإتمام الطلب",
    ),
    "product_description": MessageLookupByLibrary.simpleMessage(
      "اكتشف أفضل قطع اللحوم الطازجة والبلدية المنتقاة بعناية فائقة والمجهزة وفق أعلى معايير النظافة والجودة.",
    ),
    "product_details": MessageLookupByLibrary.simpleMessage("تفاصيل المنتج"),
    "product_not_found": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على المنتج",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
    "quantity_label": MessageLookupByLibrary.simpleMessage("الكمية"),
    "recent_searches": MessageLookupByLibrary.simpleMessage(
      "عمليات البحث الأخيرة",
    ),
    "recommended_products": MessageLookupByLibrary.simpleMessage(
      "المنتجات الموصى بها",
    ),
    "redeem_points": MessageLookupByLibrary.simpleMessage(
      "استبدال نقاط الولاء",
    ),
    "relevance": MessageLookupByLibrary.simpleMessage("الأكثر صلة"),
    "remove_from_cart": MessageLookupByLibrary.simpleMessage("حذف من السلة"),
    "required_field": MessageLookupByLibrary.simpleMessage("مطلوب"),
    "retry_button": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "reviews_rating": m8,
    "sale_tag": MessageLookupByLibrary.simpleMessage("عرض"),
    "sar": MessageLookupByLibrary.simpleMessage("ر.س"),
    "sar_value": m9,
    "save_changes": MessageLookupByLibrary.simpleMessage("حفظ التغييرات"),
    "saved_addresses": MessageLookupByLibrary.simpleMessage(
      "العناوين المحفوظة",
    ),
    "saving_label": m10,
    "search_hint": MessageLookupByLibrary.simpleMessage(
      "ابحث عن اللحوم الطازجة والفواكه...",
    ),
    "search_placeholder": MessageLookupByLibrary.simpleMessage("ابحث هنا..."),
    "select_delivery_date": MessageLookupByLibrary.simpleMessage(
      "اختر تاريخ التوصيل",
    ),
    "select_delivery_time": MessageLookupByLibrary.simpleMessage(
      "اختر وقت التوصيل",
    ),
    "select_option": MessageLookupByLibrary.simpleMessage("اختر"),
    "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "shipping_address": MessageLookupByLibrary.simpleMessage("عنوان الشحن"),
    "sign_in": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "skip": MessageLookupByLibrary.simpleMessage("تخطي"),
    "sort_by": MessageLookupByLibrary.simpleMessage("ترتيب حسب"),
    "splash_tagline": MessageLookupByLibrary.simpleMessage(
      "فخامة وأصالة الذبائح",
    ),
    "splash_title": MessageLookupByLibrary.simpleMessage("ذبائح المملكة"),
    "start_building": MessageLookupByLibrary.simpleMessage("اطلب الآن"),
    "subtotal": MessageLookupByLibrary.simpleMessage("المجموع الفرعي"),
    "tab_fresh_cut": m11,
    "tab_popular": m12,
    "tab_special": m13,
    "tax": MessageLookupByLibrary.simpleMessage("الضريبة"),
    "terms_of_service": MessageLookupByLibrary.simpleMessage("شروط الخدمة"),
    "time_slot_afternoon": MessageLookupByLibrary.simpleMessage(
      "مسائي (١٢:٠٠ م - ٥:٠٠ م)",
    ),
    "time_slot_evening": MessageLookupByLibrary.simpleMessage(
      "ليلي (٥:٠٠ م - ١٠:٠٠ م)",
    ),
    "time_slot_morning": MessageLookupByLibrary.simpleMessage(
      "صباحي (٨:٠٠ ص - ١٢:٠٠ م)",
    ),
    "today": MessageLookupByLibrary.simpleMessage("اليوم"),
    "todays_offers": MessageLookupByLibrary.simpleMessage("عروض اليوم"),
    "tomorrow": MessageLookupByLibrary.simpleMessage("غداً"),
    "total": MessageLookupByLibrary.simpleMessage("الإجمالي"),
    "track_order": MessageLookupByLibrary.simpleMessage("تتبع الطلب"),
    "tracking_timeline": MessageLookupByLibrary.simpleMessage("خط سير الطلب"),
    "unable_load_highlight": MessageLookupByLibrary.simpleMessage(
      "فشل تحميل القصة",
    ),
    "unable_play_video": MessageLookupByLibrary.simpleMessage(
      "فشل تشغيل الفيديو",
    ),
    "update_cart": MessageLookupByLibrary.simpleMessage("تحديث السلة"),
    "view_all": MessageLookupByLibrary.simpleMessage("عرض الكل"),
    "view_more": MessageLookupByLibrary.simpleMessage("عرض المزيد"),
    "wallet_balance": MessageLookupByLibrary.simpleMessage("رصيد المحفظة"),
    "weight_half": MessageLookupByLibrary.simpleMessage("نصف"),
    "weight_kg": m14,
    "weight_options": MessageLookupByLibrary.simpleMessage("خيارات الوزن"),
    "weight_whole": MessageLookupByLibrary.simpleMessage("كامل"),
    "welcome": MessageLookupByLibrary.simpleMessage(
      "أهلاً بك في ذبائح المملكة",
    ),
    "welcome_comma": MessageLookupByLibrary.simpleMessage("مرحباً،"),
    "welcome_headline": MessageLookupByLibrary.simpleMessage(
      "أجود أنواع الذبائح الطازجة بين يديك.",
    ),
    "welcome_sub_1": MessageLookupByLibrary.simpleMessage(
      "اختيار الذبيحة وتحديد خيارات التقطيع والتغليف",
    ),
    "welcome_sub_2": MessageLookupByLibrary.simpleMessage(
      "توصيل مبرد وسريع مباشر حتى باب منزلك",
    ),
    "welcome_sub_3": MessageLookupByLibrary.simpleMessage(
      "ضمان الجودة وذبح إسلامي 100% وفق الشريعة",
    ),
    "your_selection": MessageLookupByLibrary.simpleMessage("ملخص اختياراتك"),
  };
}
