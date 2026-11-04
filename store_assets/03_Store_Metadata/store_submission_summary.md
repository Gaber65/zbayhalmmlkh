# 🚀 الدليل الشامل لرفع تطبيق "ذبائح المملكة" على المتاجر (App Store & Google Play)

تم تجهيز وتوليد كافة المتطلبات الرسمية والملفات الرسومية بدقة متناهية وفقاً لأحدث سياسات متجر **Apple App Store** ومتجر **Google Play Store**.

---

## 📁 هيكل مجلد الأصول الجاهز للتسليم (`store_assets/`)

```text
store_assets/
├── 01_iOS_Assets/
│   ├── AppIcon_1024x1024.png                  (أيقونة المتجر: 1024x1024 PNG - No Alpha)
│   ├── Screenshots_1290x2796/                 (لقطات شاشة آيفون 6.7" Super Retina)
│   │   ├── 01_Home_Catalog_1290x2796.png       (الرئيسية وتشكيلة الذبائح)
│   │   ├── 02_Customization_Cuts_1290x2796.png (تخصيص الذبيحة، التقطيع، والتغليف)
│   │   ├── 03_Cart_ApplePay_1290x2796.png      (سلة المشتريات والدفع بـ Apple Pay)
│   │   ├── 04_Chilled_Tracking_1290x2796.png   (تتبع مسار التوصيل المبرد ومراحل المسلخ)
│   │   └── 05_Special_Offers_1290x2796.png     (باقات الولائم ونادي المكافآت)
│   └── Screenshots_iPad_2048x2732/            (لقطات شاشة آيباد برو 13" / 12.9" Retina)
│       ├── 01_Home_Catalog_iPad_2048x2732.png
│       ├── 02_Customization_Cuts_iPad_2048x2732.png
│       ├── 03_Cart_ApplePay_iPad_2048x2732.png
│       ├── 04_Chilled_Tracking_iPad_2048x2732.png
│       └── 05_Special_Offers_iPad_2048x2732.png
│
├── 02_Android_Assets/
│   ├── AppIcon_512x512.png                    (أيقونة المتجر: 512x512 PNG - No Alpha)
│   ├── FeatureGraphic_1024x500.png            (البانر المميز الإلزامي: 1024x500 PNG)
│   └── Screenshots_1080x1920/                 (لقطات شاشة الهاتف بدقة 1080x1920)
│       ├── 01_Home_Catalog_1080x1920.png
│       ├── 02_Customization_Cuts_1080x1920.png
│       ├── 03_Cart_ApplePay_1080x1920.png
│       ├── 04_Chilled_Tracking_1080x1920.png
│       └── 05_Special_Offers_1080x1920.png
│
└── 03_Store_Metadata/
    ├── app_store_ios_metadata.md              (بيانات App Store Connect الكاملة)
    ├── google_play_metadata.md                (بيانات Google Play Console الكاملة)
    ├── store_info_quick_copy.txt              (ملف نصي سريع للنسخ واللصق المباشر)
    ├── metadata.json                          (بيانات JSON المنظمة)
    └── privacy_policy.html                    (صفحة ويب متكاملة لسياسة الخصوصية جاهزة للنشر)
```

---

## ⚡ ملخص البيانات للمطابقة الفورية

| البند | متجر Apple (iOS) | متجر Google Play (Android) | الحالة |
| :--- | :--- | :--- | :--- |
| **اسم التطبيق (App Name)** | `ذبائح المملكة \| لحوم طازجة` (26 حرفاً) | `ذبائح المملكة \| لحوم طازجة` (26 حرفاً) | ✅ مطابق (الحد: 30) |
| **الوصف القصير / Subtitle** | `أجود الذبائح واللحوم الطازجة` (28 حرفاً) | `ذبائح ولحوم بلدية طازجة ومذبوحة وفق الشريعة مع توصيل مبرد وسريع لباب بيتك` (73 حرفاً) | ✅ مطابق (الحد: 30 و 80) |
| **النص الترويجي (Promo)** | 132 حرفاً (الحد الأقصى: 170) | غير متاح | ✅ مطابق |
| **الكلمات الدلالية (Keywords)** | 79 حرفاً (الحد الأقصى: 100) | عبر العلامات (Tags) والوصف | ✅ مطابق |
| **أيقونة المتجر (App Icon)** | `1024 × 1024 px` (PNG - RGB No Alpha) | `512 × 512 px` (PNG - RGB No Alpha) | ✅ تم التوليد بنجاح |
| **الصورة المميزة (Feature Graphic)** | غير مطلوبة | `1024 × 500 px` (PNG) | ✅ تم التوليد بنجاح |
| **لقطات الشاشة (Screenshots)** | 5 لقطات آيفون (`1290 × 2796`) + 5 لقطات آيباد برو (`2048 × 2732`) | 5 لقطات بمقاس `1080 × 1920 px` | ✅ تم التوليد بنجاح |
| **رابط سياسة الخصوصية** | `https://zbayhalmmlkh.network/privacy-policy` | `https://zbayhalmmlkh.network/privacy-policy` | ✅ جاهز + ملف HTML |
| **بريد الدعم الفني** | `support@zbayhalmmlkh.network` | `support@zbayhalmmlkh.network` | ✅ جاهز |
| **حساب المراجعة التجريبي** | جوال: `0500000000` / كود: `123456` | جوال: `0500000000` / كود: `123456` | ✅ جاهز + ميزة الدخول كزائر |
| **حزمة التطبيق (App Bundle / IPA)** | `flutter build ipa --release` | `flutter build appbundle --release` | ✅ الأوامر جاهزة |


