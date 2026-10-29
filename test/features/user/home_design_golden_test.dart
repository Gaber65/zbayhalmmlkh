import 'package:dartz/dartz.dart';
import 'package:dhabayih_lmamlaka/core/error/failure.dart';
import 'package:dhabayih_lmamlaka/core/widgets/main_navigation_shell.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/category.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/entities/product.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/domain/repositories/catalog_repository.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/manager/catalog_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/catalog/presentation/views/widgets/mobile/categories_mobile_view.dart';
import 'package:dhabayih_lmamlaka/features/user/favorites/domain/entities/favorite_product.dart';
import 'package:dhabayih_lmamlaka/features/user/favorites/domain/repositories/favorites_repository.dart';
import 'package:dhabayih_lmamlaka/features/user/favorites/presentation/manager/favorites_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/home/data/models/home_response_model.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/entities/home_data.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/repositories/home_repository.dart';
import 'package:dhabayih_lmamlaka/features/user/home/domain/usecases/get_home_data.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/manager/home_cubit.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/home_screen.dart';
import 'package:dhabayih_lmamlaka/features/user/home/presentation/views/widgets/kingdom/kingdom_design.dart';
import 'package:dhabayih_lmamlaka/features/user/offers/domain/entities/offer_entity.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> _loadAppFonts() async {
  final loader = FontLoader(kFontFamily);
  for (final path in const [
    'assets/fonts/Plex-Regular.ttf',
    'assets/fonts/Plex-Medium.ttf',
    'assets/fonts/Plex-SemiBold.ttf',
    'assets/fonts/Plex-Bold.ttf',
  ]) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
}

class _FixtureHomeRepository implements HomeRepository {
  final HomeData data;
  _FixtureHomeRepository(this.data);

  @override
  Future<Either<Failure, HomeData>> getHomeData() async => Right(data);
}

class _FakeFavoritesRepository implements FavoritesRepository {
  final List<FavoriteProduct> _items = [];

  @override
  Future<Either<Failure, List<FavoriteProduct>>> getFavorites() async =>
      Right(List.unmodifiable(_items));

  @override
  Future<Either<Failure, bool>> addFavorite(FavoriteProduct product) async {
    _items.removeWhere((e) => e.id == product.id);
    _items.add(product);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeFavorite(int productId) async {
    _items.removeWhere((e) => e.id == productId);
    return const Right(true);
  }

  @override
  Future<bool> isFavorite(int productId) async =>
      _items.any((e) => e.id == productId);
}

class _FakeCatalogRepository implements CatalogRepository {
  final HomeData homeData;
  _FakeCatalogRepository(this.homeData);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async =>
      Right(homeData.categories);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async => Right([
        ...homeData.featuredProducts,
        ...homeData.bestSellers,
        ...homeData.recommendedProducts,
      ]);

  @override
  Future<Either<Failure, List<Product>>> getOffers() async => const Right([]);

  @override
  Future<Either<Failure, List<Product>>> getBestSellers() async =>
      Right(homeData.bestSellers);

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(
    int categoryId,
  ) async {
    final all = [
      ...homeData.featuredProducts,
      ...homeData.bestSellers,
      ...homeData.recommendedProducts,
    ];
    return Right(all.where((p) => p.categoryId == categoryId).toList());
  }

  @override
  Future<Either<Failure, Product>> getProductById(int productId) async {
    final all = [
      ...homeData.featuredProducts,
      ...homeData.bestSellers,
      ...homeData.recommendedProducts,
    ];
    return Right(all.firstWhere((p) => p.id == productId));
  }
}

HomeData buildReferenceFixtureHomeData() {
  const sizes = <ProductSize>[
    ProductSize(
      id: 101,
      name: 'كامل — وسط',
      portionType: 'full',
      weightRange: '14–16 كجم تقريبًا',
      price: 1850,
      isDefault: true,
      sequence: 0,
      loyaltyPoints: 18,
    ),
    ProductSize(
      id: 102,
      name: 'كامل — كبير',
      portionType: 'full',
      weightRange: '18–20 كجم تقريبًا',
      price: 2150,
      isDefault: false,
      sequence: 1,
      loyaltyPoints: 21,
    ),
    ProductSize(
      id: 103,
      name: 'نصف — وسط',
      portionType: 'half',
      weightRange: '7–8 كجم تقريبًا',
      price: 925,
      isDefault: true,
      sequence: 0,
      loyaltyPoints: 9,
    ),
    ProductSize(
      id: 104,
      name: 'ربع — وسط',
      portionType: 'quarter',
      weightRange: '3.5–4 كجم تقريبًا',
      price: 465,
      isDefault: true,
      sequence: 0,
      loyaltyPoints: 4,
    ),
  ];

  const cutting = <ProductOption>[
    ProductOption(id: 1, name: 'تقطيع للطبخ', extraPrice: 0),
    ProductOption(id: 2, name: 'تقطيع للمشاوي', extraPrice: 20),
    ProductOption(id: 3, name: 'بدون تقطيع', extraPrice: 0),
  ];

  const packaging = <ProductOption>[
    ProductOption(id: 1, name: 'تغليف عادي', extraPrice: 0),
    ProductOption(id: 2, name: 'أطباق منفصلة', extraPrice: 15),
  ];

  const excluded = <ProductOption>[
    ProductOption(id: 1, name: 'استبعاد الرأس', extraPrice: 0),
    ProductOption(id: 2, name: 'استبعاد الكرشة', extraPrice: 0),
  ];

  const p1 = Product(
    id: 1,
    title: 'خروف نعيمي بلدي',
    subtitle: 'اختَر الحجم والتجهيز المناسب',
    price: 1850,
    imageUrl: KAssets.sheep,
    categoryId: 1,
    categoryName: 'ذبائح غنم وماعز',
    isCarcass: true,
    hasSizes: true,
    isAvailable: true,
    active: true,
    isFeatured: true,
    isBestSeller: true,
    loyaltyPoints: 18,
    sizes: sizes,
    portions: [
      ProductPortion(
        type: 'full',
        name: 'كامل',
        title: 'ذبيحة كاملة',
        subtitle: 'اختَر الحجم',
        imageUrl: KAssets.sheep,
        startingPrice: 1850,
        sizeCount: 2,
      ),
      ProductPortion(
        type: 'half',
        name: 'نصف',
        title: 'نصف ذبيحة',
        subtitle: 'اختَر الحجم',
        imageUrl: KAssets.sheep,
        startingPrice: 925,
        sizeCount: 1,
      ),
      ProductPortion(
        type: 'quarter',
        name: 'ربع',
        title: 'ربع ذبيحة',
        subtitle: 'اختَر الحجم',
        imageUrl: KAssets.sheep,
        startingPrice: 465,
        sizeCount: 1,
      ),
    ],
    cuttingOptions: cutting,
    packagingOptions: packaging,
    excludedParts: excluded,
    galleryImages: [KAssets.sheep, KAssets.meat],
  );

  const p2 = Product(
    id: 2,
    title: 'ستيك بقري',
    subtitle: 'عبوة 1 كجم',
    price: 95,
    imageUrl: KAssets.lamb,
    categoryId: 2,
    categoryName: 'لحم بقر',
    weightKg: 1,
    isAvailable: true,
    active: true,
    isBestSeller: true,
    galleryImages: [KAssets.lamb],
  );

  const p3 = Product(
    id: 3,
    title: 'خروف حري بلدي',
    subtitle: 'اختَر الحجم والتجهيز',
    price: 1750,
    imageUrl: KAssets.sheep,
    categoryId: 1,
    categoryName: 'ذبائح غنم وماعز',
    isCarcass: true,
    hasSizes: true,
    isAvailable: true,
    active: true,
    isFeatured: true,
    sizes: [
      ProductSize(
        id: 301,
        name: 'كامل',
        portionType: 'full',
        weightRange: '11–13 كجم تقريبًا',
        price: 1750,
        isDefault: true,
        sequence: 0,
        loyaltyPoints: 17,
      ),
    ],
    portions: [
      ProductPortion(
        type: 'full',
        name: 'كامل',
        title: 'خروف حري كامل',
        subtitle: 'اختَر التجهيز',
        imageUrl: KAssets.sheep,
        startingPrice: 1750,
        sizeCount: 1,
      ),
    ],
    cuttingOptions: cutting,
    packagingOptions: packaging,
  );

  const p4 = Product(
    id: 4,
    title: 'دجاج كامل',
    subtitle: 'وزن تقريبي 1 كجم',
    price: 28,
    imageUrl: KAssets.chicken,
    categoryId: 5,
    categoryName: 'دجاج',
    weightKg: 1,
    isAvailable: true,
    active: true,
    isFeatured: true,
  );

  const p5 = Product(
    id: 5,
    title: 'مفروم غنم بلدي',
    subtitle: 'عبوة 1 كجم',
    price: 65,
    offerPrice: 59,
    isOnOffer: true,
    discountTag: 'عرض خاص',
    imageUrl: KAssets.meat,
    categoryId: 7,
    categoryName: 'لحوم بالكيلو',
    weightKg: 1,
    isAvailable: true,
    active: true,
    loyaltyPoints: 1,
  );

  const p6 = Product(
    id: 6,
    title: 'قطع لحم ضأن',
    subtitle: 'عبوة 1 كجم',
    price: 110,
    imageUrl: KAssets.lamb,
    categoryId: 3,
    categoryName: 'لحم ضأن',
    weightKg: 1,
    isAvailable: false,
    active: true,
  );

  const p7 = Product(
    id: 7,
    title: 'نصف ذبيحة',
    subtitle: 'نصف مجهّز حسب اختيارك',
    price: 925,
    imageUrl: KAssets.meat,
    categoryId: 8,
    categoryName: 'أجزاء وأنصاف',
    isAvailable: true,
    active: true,
    isCarcass: true,
    hasSizes: true,
    sizes: [
      ProductSize(
        id: 701,
        name: 'نصف — وسط',
        portionType: 'half',
        weightRange: '7–8 كجم تقريبًا',
        price: 925,
        isDefault: true,
        sequence: 0,
      ),
    ],
    portions: [
      ProductPortion(
        type: 'half',
        name: 'نصف',
        title: 'نصف ذبيحة',
        subtitle: 'مجهز حسب اختيارك',
        imageUrl: KAssets.meat,
        startingPrice: 925,
        sizeCount: 1,
      ),
    ],
    cuttingOptions: cutting,
    packagingOptions: packaging,
  );

  const p8 = Product(
    id: 8,
    title: 'باقة التوفير الكبرى',
    subtitle: 'تشكيلة للمشاوي والطبخ',
    price: 450,
    offerPrice: 380,
    isOnOffer: true,
    discountTag: 'وفر 70 ر.س',
    imageUrl: KAssets.meat,
    categoryId: 7,
    categoryName: 'باقات التوفير',
    isAvailable: true,
    active: true,
    loyaltyPoints: 3,
  );

  return const HomeData(
    deliveryLocation: 'حي الصحافة، الرياض',
    userHighlight: UserHighlight(
      id: 1,
      name: 'جابر',
      email: '',
      avatarUrl: '',
      balance: 125,
      activeCart: ActiveCart(id: 101, status: 'active', lineCount: 2),
    ),
    banners: [
      BannerEntity(
        id: 1,
        name: 'اختيارات تليق بسفرتك',
        imageUrl: KAssets.meat,
        bannerType: 'offer',
        offerId: 10,
      ),
      BannerEntity(
        id: 2,
        name: 'اختَر ذبيحتك على ذوقك',
        imageUrl: KAssets.sheep,
        bannerType: 'category',
        deepLink: '/categories/1',
      ),
    ],
    offers: [
      OfferEntity(
        id: 10,
        name: 'باقة التوفير الكبرى',
        subtitle: 'اختيارات للمشاوي والطبخ',
        description: 'تعرّف على المنتجات المشمولة بالعرض، واختَر ما يناسب طلبك.',
        bannerImageUrl: KAssets.lamb,
        discountType: 'fixed',
        discountValue: 70,
        badgeText: 'وفر 70 ر.س',
        products: [p8],
        productIds: [8],
        isActive: true,
      ),
      OfferEntity(
        id: 11,
        name: 'عرض المفروم البلدي',
        description: 'عرض على عبوة مفروم غنم بلدي.',
        bannerImageUrl: KAssets.meat,
        discountType: 'fixed',
        discountValue: 6,
        badgeText: 'وفر 6 ر.س',
        products: [p5],
        productIds: [5],
        isActive: true,
      ),
    ],
    categories: [
      Category(id: 1, name: 'ذبائح غنم وماعز', imageUrl: KAssets.sheep),
      Category(id: 2, name: 'لحم بقر', imageUrl: KAssets.lamb),
      Category(id: 3, name: 'لحم ضأن', imageUrl: KAssets.meat),
      Category(id: 4, name: 'حاشي وإبل', imageUrl: KAssets.camel),
      Category(id: 5, name: 'دجاج', imageUrl: KAssets.chicken),
      Category(id: 6, name: 'عجول وأبقار', imageUrl: KAssets.cow),
      Category(id: 7, name: 'لحوم ومفروم بالكيلو', imageUrl: KAssets.meat),
      Category(id: 8, name: 'أجزاء وأنصاف ذبائح', imageUrl: KAssets.lamb),
    ],
    featuredProducts: [p1, p4],
    bestSellers: [p2, p3, p7],
    recommendedProducts: [p5, p6, p8],
    jabinHighlight: [
      JabinHighlightEntity(
        user: HighlightUser(id: 11, name: 'ذبائح المملكة', email: '', avatarUrl: ''),
        highlights: [
          HighlightEntity(
            id: 1,
            name: 'اختيارات المملكة',
            mediaType: 'image',
            mediaUrl: KAssets.sheep,
          ),
          HighlightEntity(
            id: 2,
            name: 'منوعات لسفرتك',
            mediaType: 'image',
            mediaUrl: KAssets.meat,
          ),
        ],
      ),
      JabinHighlightEntity(
        user: HighlightUser(id: 12, name: 'التجهيز والتغليف', email: '', avatarUrl: ''),
        highlights: [
          HighlightEntity(
            id: 3,
            name: 'قطع وتجهيزات',
            mediaType: 'image',
            mediaUrl: KAssets.lamb,
          ),
          HighlightEntity(
            id: 4,
            name: 'تشكيلة الطبخ',
            mediaType: 'image',
            mediaUrl: KAssets.chicken,
          ),
        ],
      ),
      JabinHighlightEntity(
        user: HighlightUser(id: 13, name: 'عروض المملكة', email: '', avatarUrl: ''),
        highlights: [
          HighlightEntity(
            id: 5,
            name: 'تشكيلة العروض',
            mediaType: 'image',
            mediaUrl: KAssets.meat,
          ),
        ],
      ),
    ],
  );
}

Widget buildTestableHome({
  required HomeData data,
  double textScale = 1.0,
  Locale locale = const Locale('ar'),
  Brightness brightness = Brightness.light,
}) {
  final homeCubit = HomeCubit(getHomeData: GetHomeData(_FixtureHomeRepository(data)))
    ..fetchHomeData();
  final favCubit = FavoritesCubit(repository: _FakeFavoritesRepository())
    ..loadFavorites();
  final isAr = locale.languageCode == 'ar';
  final palette = brightness == Brightness.dark ? KPalette.dark : KPalette.light;

  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>.value(value: homeCubit),
        BlocProvider<FavoritesCubit>.value(value: favCubit),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: brightness,
          fontFamily: kFontFamily,
          scaffoldBackgroundColor: palette.paper,
          colorScheme: ColorScheme.fromSeed(
            seedColor: palette.red,
            brightness: brightness,
            surface: palette.paper,
          ),
        ),
        locale: locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: Directionality(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
          );
        },
        home: Scaffold(
          backgroundColor: palette.paper,
          body: const HomeScreen(),
          bottomNavigationBar: KingdomBottomNavigationBar(
            currentIndex: 0,
            cartBadgeCount: data.userHighlight?.activeCart?.lineCount ?? 0,
            onItemTapped: (_) {},
          ),
        ),
      ),
    ),
  );
}

Future<void> _precacheTestImages(WidgetTester tester) async {
  final ctx = tester.element(find.byType(HomeScreen));
  for (final asset in const [
    KAssets.meat,
    KAssets.camel,
    KAssets.sheep,
    KAssets.cow,
    KAssets.lamb,
    KAssets.chicken,
  ]) {
    await tester.runAsync(() => precacheImage(AssetImage(asset), ctx));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadAppFonts();
  });

  testWidgets('Golden + layout at 390px viewport & full scroll', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    final data = buildReferenceFixtureHomeData();
    await tester.pumpWidget(buildTestableHome(data: data));
    await _precacheTestImages(tester);
    await tester.pump(const Duration(milliseconds: 400));

    // Verify key RTL sections are present.
    expect(find.text('ذبائح المملكة'), findsWidgets);
    expect(find.text('اختيارات تليق بسفرتك'), findsOneWidget);
    expect(find.text('تجارب العملاء'), findsOneWidget);
    expect(find.text('التصنيفات'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/impl_390_844.png'),
    );

    // Tall full-page render at 390x2705 to compare against ref_390_3000.png.
    tester.view.physicalSize = const Size(390, 2705);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('الأكثر طلبًا'), findsOneWidget);
    expect(find.text('العروض الترويجية'), findsOneWidget);
    expect(find.text('تجارب العملاء'), findsOneWidget);
    expect(find.text('المنتجات المميزة'), findsOneWidget);
    expect(find.text('منتجات مقترحة لك'), findsOneWidget);
    expect(find.text('محتار وش تختار؟'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/impl_390_3000.png'),
    );
  });

  testWidgets('Golden + layout at 320px narrow width without overflow', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 2500);
    addTearDown(tester.view.reset);

    final data = buildReferenceFixtureHomeData();
    await tester.pumpWidget(buildTestableHome(data: data));
    await _precacheTestImages(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/impl_320_3000.png'),
    );
  });

  testWidgets('Larger text scale (1.3x) renders cleanly without overflow', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 2900);
    addTearDown(tester.view.reset);

    final data = buildReferenceFixtureHomeData();
    await tester.pumpWidget(buildTestableHome(data: data, textScale: 1.3));
    await _precacheTestImages(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/impl_390_text130.png'),
    );
  });

  testWidgets('All categories render immediately, stories modal, and product options sheet',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 3000);
    addTearDown(tester.view.reset);

    final data = buildReferenceFixtureHomeData();
    await tester.pumpWidget(buildTestableHome(data: data));
    await _precacheTestImages(tester);
    await tester.pump(const Duration(milliseconds: 300));

    // All 8 categories are rendered immediately without any expand/collapse button.
    expect(find.text('عرض الكل (8)'), findsNothing);
    expect(find.text('عرض أقل'), findsNothing);
    expect(find.text('ذبائح غنم وماعز'), findsWidgets);
    expect(find.text('عجول وأبقار'), findsOneWidget);
    expect(find.text('لحوم ومفروم بالكيلو'), findsOneWidget);
    expect(find.text('أجزاء وأنصاف ذبائح'), findsOneWidget);

    // Open product options bottom sheet via "اختيار الخيارات".
    await tester.tap(find.text('اختيار الخيارات').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('حجم الحصة'), findsOneWidget);
    expect(find.text('طريقة التقطيع'), findsOneWidget);
    expect(find.text('إضافة إلى السلة'), findsOneWidget);
  });

  testWidgets('Dark mode and English LTR support render cleanly without overflow',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 2800);
    addTearDown(tester.view.reset);

    final data = buildReferenceFixtureHomeData();
    await tester.pumpWidget(
      buildTestableHome(
        data: data,
        locale: const Locale('en'),
        brightness: Brightness.dark,
      ),
    );
    await _precacheTestImages(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Best Sellers'), findsOneWidget);
    expect(find.text('Promotional Offers'), findsOneWidget);
    expect(find.text('Customer Reviews'), findsOneWidget);
    expect(find.text('Featured Products'), findsOneWidget);
    expect(find.text('Not sure what to pick?'), findsOneWidget);
  });

  testWidgets('Backend loyalty_points and product points parse and display non-zero values',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    // Verify UserHighlightModel & HomeProductModel parse loyalty_points from JSON
    final parsedUser = UserHighlightModel.fromJson({
      'id': 7,
      'name': 'أحمد',
      'balance': 0.0,
      'loyalty_points': 480,
    }).toDomain();
    expect(parsedUser.loyaltyPoints, 480);
    expect(parsedUser.effectiveBalance, 480);

    final parsedProduct = HomeProductModel.fromJson({
      'id': 99,
      'name': 'خروف نعيمي',
      'list_price': 1850,
      'loyalty_points': 35,
      'is_carcass': true,
      'has_sizes': true,
      'sizes': [
        {
          'id': 1,
          'name': 'كامل',
          'portion_type': 'full',
          'price': 1850,
          'loyalty_points': 35,
        },
      ],
    }).toDomain();
    expect(parsedProduct.loyaltyPoints, 35);
    expect(parsedProduct.sizes.length, 1);

    // Render HomeScreen with parsedUser (balance=0 from /api/v1/home, loyaltyPoints=480 from backend)
    final base = buildReferenceFixtureHomeData();
    final dataWithPoints = HomeData(
      deliveryLocation: base.deliveryLocation,
      userHighlight: parsedUser,
      banners: base.banners,
      categories: base.categories,
    );

    await tester.pumpWidget(buildTestableHome(data: dataWithPoints));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('480'), findsOneWidget);
    expect(find.textContaining('480 نقطة'), findsOneWidget);
  });

  testWidgets('CategoriesMobileView matches #browseView in design_reference/index.html and MainNavigationShell shows floating WhatsApp FAB',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 1800);
    addTearDown(tester.view.reset);

    final data = buildReferenceFixtureHomeData();
    final catalogCubit = CatalogCubit(repository: _FakeCatalogRepository(data))
      ..fetchCatalog();
    final homeCubit = HomeCubit(getHomeData: GetHomeData(_FixtureHomeRepository(data)))
      ..fetchHomeData();
    final favCubit = FavoritesCubit(repository: _FakeFavoritesRepository())
      ..loadFavorites();

    final router = GoRouter(
      initialLocation: '/categories',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainNavigationShell(child: child),
          routes: [
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesMobileView(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, _) => MultiBlocProvider(
          providers: [
            BlocProvider<CatalogCubit>.value(value: catalogCubit),
            BlocProvider<HomeCubit>.value(value: homeCubit),
            BlocProvider<FavoritesCubit>.value(value: favCubit),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            locale: const Locale('ar'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    // Verify floating WhatsApp FAB is present in MainNavigationShell.
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify #browseView elements in CategoriesMobileView.
    expect(find.text('التصنيفات'), findsWidgets);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('ذبائح غنم وماعز'), findsWidgets);
    expect(find.text('العودة للرئيسية'), findsOneWidget);
  });
}
