import 'package:equatable/equatable.dart';

/// Dashboard statistics & analytics summary
class AdminDashboardStats extends Equatable {
  final int totalOrders;
  final int pendingOrders;
  final int preparingOrders;
  final int deliveringOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double todaySales;
  final double monthlySales;
  final int totalProducts;
  final int lowStockCount;
  final int totalCustomers;
  final int ordersProgress;
  final int revenueProgress;
  final int customersProgress;
  final int pendingProgress;
  final int lowStockProgress;
  final double currentMonthRevenue;
  final int currentMonthOrders;
  final int currentMonthCustomers;
  final List<Map<String, dynamic>> recentOrders;
  final List<Map<String, dynamic>> topProducts;
  final Map<String, dynamic> salesData;
  final Map<String, dynamic> inventoryData;

  const AdminDashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.preparingOrders,
    required this.deliveringOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.todaySales,
    required this.monthlySales,
    required this.totalProducts,
    required this.lowStockCount,
    required this.totalCustomers,
    this.ordersProgress = 0,
    this.revenueProgress = 0,
    this.customersProgress = 0,
    this.pendingProgress = 0,
    this.lowStockProgress = 0,
    this.currentMonthRevenue = 0.0,
    this.currentMonthOrders = 0,
    this.currentMonthCustomers = 0,
    this.recentOrders = const [],
    this.topProducts = const [],
    this.salesData = const {},
    this.inventoryData = const {},
  });

  factory AdminDashboardStats.initial() {
    return const AdminDashboardStats(
      totalOrders: 0,
      pendingOrders: 0,
      preparingOrders: 0,
      deliveringOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      todaySales: 0.0,
      monthlySales: 0.0,
      totalProducts: 0,
      lowStockCount: 0,
      totalCustomers: 0,
      ordersProgress: 0,
      revenueProgress: 0,
      customersProgress: 0,
      pendingProgress: 0,
      lowStockProgress: 0,
      currentMonthRevenue: 0.0,
      currentMonthOrders: 0,
      currentMonthCustomers: 0,
      recentOrders: [],
      topProducts: [],
      salesData: {},
      inventoryData: {},
    );
  }

  @override
  List<Object?> get props => [
        totalOrders,
        pendingOrders,
        preparingOrders,
        deliveringOrders,
        completedOrders,
        cancelledOrders,
        todaySales,
        monthlySales,
        totalProducts,
        lowStockCount,
        totalCustomers,
        ordersProgress,
        revenueProgress,
        customersProgress,
        pendingProgress,
        lowStockProgress,
        currentMonthRevenue,
        currentMonthOrders,
        currentMonthCustomers,
        recentOrders,
        topProducts,
        salesData,
        inventoryData,
      ];
}

/// Admin Coupon model
class AdminCouponEntity extends Equatable {
  final int id;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscount;
  final int? maxUses;
  final int currentUses;
  final String expiryDate;
  final bool isActive;

  const AdminCouponEntity({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscount,
    this.maxUses,
    this.currentUses = 0,
    required this.expiryDate,
    required this.isActive,
  });

  AdminCouponEntity copyWith({
    int? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minOrderValue,
    double? maxDiscount,
    int? maxUses,
    int? currentUses,
    String? expiryDate,
    bool? isActive,
  }) {
    return AdminCouponEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        discountType,
        discountValue,
        minOrderValue,
        maxDiscount,
        maxUses,
        currentUses,
        expiryDate,
        isActive,
      ];
}

/// Admin Banner model
class AdminBannerEntity extends Equatable {
  final int id;
  final String title;
  final String imageUrl;
  final String? link;
  final bool isActive;
  final int displayOrder;

  const AdminBannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.link,
    this.isActive = true,
    this.displayOrder = 0,
  });

  AdminBannerEntity copyWith({
    int? id,
    String? title,
    String? imageUrl,
    String? link,
    bool? isActive,
    int? displayOrder,
  }) {
    return AdminBannerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, link, isActive, displayOrder];
}

/// Admin Product Customization Option (Cutting, Packaging, Excluded Parts)
class AdminOptionEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double extraPrice;
  final String type; // 'cutting', 'packaging', 'excluded_part'
  final bool isActive;

  const AdminOptionEntity({
    required this.id,
    required this.name,
    this.description,
    this.extraPrice = 0.0,
    required this.type,
    this.isActive = true,
  });

  AdminOptionEntity copyWith({
    int? id,
    String? name,
    String? description,
    double? extraPrice,
    String? type,
    bool? isActive,
  }) {
    return AdminOptionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      extraPrice: extraPrice ?? this.extraPrice,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, extraPrice, type, isActive];
}

/// Admin Notification model
class AdminNotificationEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final String notificationType;
  final String priority;
  final String? deepLink;
  final String status;
  final String? sentAt;
  final String? readAt;
  final int? orderId;

  const AdminNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.notificationType = 'system',
    this.priority = 'normal',
    this.deepLink,
    this.status = 'sent',
    this.sentAt,
    this.readAt,
    this.orderId,
  });

  static String? _parseString(dynamic val) {
    if (val == null || val == false) return null;
    return val.toString();
  }

  static int _parseInt(dynamic val) {
    if (val == null || val == false) return 0;
    return (val as num).toInt();
  }

  factory AdminNotificationEntity.fromJson(Map<String, dynamic> json) {
    return AdminNotificationEntity(
      id: _parseInt(json['id']),
      title: _parseString(json['title']) ?? '',
      body: _parseString(json['body']) ?? '',
      imageUrl: _parseString(json['image_url']),
      notificationType: _parseString(json['notification_type']) ?? 'system',
      priority: _parseString(json['priority']) ?? 'normal',
      deepLink: _parseString(json['deep_link']),
      status: _parseString(json['status']) ?? 'sent',
      sentAt: _parseString(json['sent_at']),
      readAt: _parseString(json['read_at']),
      orderId: json['order_id'] != null && json['order_id'] != false
          ? _parseInt(json['order_id'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        imageUrl,
        notificationType,
        priority,
        deepLink,
        status,
        sentAt,
        readAt,
        orderId,
      ];
}

/// Admin User/Customer CRM Entity
class AdminUserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String status;
  final String userType;
  final int totalOrdersCount;
  final double totalSpending;
  final double totalRefunds;
  final int loyaltyPoints;
  final String? createDate;
  final List<Map<String, dynamic>> addresses;
  final double averageOrderValue;
  final int totalEarnedPoints;
  final int totalRedeemedPoints;
  final String? lastLogin;
  final String? lastActivityDate;
  final String? verifiedAt;
  final bool profileCompleted;
  final double balance;
  final String currency;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> loyaltyTransactions;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.userType,
    this.totalOrdersCount = 0,
    this.totalSpending = 0.0,
    this.totalRefunds = 0.0,
    this.loyaltyPoints = 0,
    this.createDate,
    this.addresses = const [],
    this.averageOrderValue = 0.0,
    this.totalEarnedPoints = 0,
    this.totalRedeemedPoints = 0,
    this.lastLogin,
    this.lastActivityDate,
    this.verifiedAt,
    this.profileCompleted = false,
    this.balance = 0.0,
    this.currency = 'SAR',
    this.orders = const [],
    this.loyaltyTransactions = const [],
  });

  AdminUserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? status,
    String? userType,
    int? totalOrdersCount,
    double? totalSpending,
    double? totalRefunds,
    int? loyaltyPoints,
    String? createDate,
    List<Map<String, dynamic>>? addresses,
    double? averageOrderValue,
    int? totalEarnedPoints,
    int? totalRedeemedPoints,
    String? lastLogin,
    String? lastActivityDate,
    String? verifiedAt,
    bool? profileCompleted,
    double? balance,
    String? currency,
    List<Map<String, dynamic>>? orders,
    List<Map<String, dynamic>>? loyaltyTransactions,
  }) {
    return AdminUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      userType: userType ?? this.userType,
      totalOrdersCount: totalOrdersCount ?? this.totalOrdersCount,
      totalSpending: totalSpending ?? this.totalSpending,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createDate: createDate ?? this.createDate,
      addresses: addresses ?? this.addresses,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      totalEarnedPoints: totalEarnedPoints ?? this.totalEarnedPoints,
      totalRedeemedPoints: totalRedeemedPoints ?? this.totalRedeemedPoints,
      lastLogin: lastLogin ?? this.lastLogin,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      orders: orders ?? this.orders,
      loyaltyTransactions: loyaltyTransactions ?? this.loyaltyTransactions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        status,
        userType,
        totalOrdersCount,
        totalSpending,
        totalRefunds,
        loyaltyPoints,
        createDate,
        addresses,
        averageOrderValue,
        totalEarnedPoints,
        totalRedeemedPoints,
        lastLogin,
        lastActivityDate,
        verifiedAt,
        profileCompleted,
        balance,
        currency,
        orders,
        loyaltyTransactions,
      ];
}

/// Admin Highlight/Story Entity
class AdminHighlightEntity extends Equatable {
  final int id;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String? title;
  final String? createdAt;
  final bool isViewed;

  const AdminHighlightEntity({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    this.title,
    this.createdAt,
    this.isViewed = false,
  });

  @override
  List<Object?> get props => [id, mediaUrl, mediaType, title, createdAt, isViewed];
}

/// Admin Payment Transaction Entity
class AdminPaymentTransactionEntity extends Equatable {
  final int id;
  final String orderName;
  final String customerName;
  final String paymentMethod;
  final double amount;
  final String status;
  final String? transactionReference;
  final String? paidDate;
  final bool isInstallment;
  final String? installmentProvider;

  const AdminPaymentTransactionEntity({
    required this.id,
    required this.orderName,
    required this.customerName,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    this.transactionReference,
    this.paidDate,
    this.isInstallment = false,
    this.installmentProvider,
  });

  @override
  List<Object?> get props => [
        id,
        orderName,
        customerName,
        paymentMethod,
        amount,
        status,
        transactionReference,
        paidDate,
        isInstallment,
        installmentProvider,
      ];
}

/// Admin Loyalty Transaction Entity
class AdminLoyaltyTransactionEntity extends Equatable {
  final int id;
  final String date;
  final String customerName;
  final String transactionType; // 'earn', 'redeem', 'manual_add', 'manual_deduct', 'refund'
  final int points;
  final int balanceAfter;
  final String? orderName;
  final String description;
  final String createdBy;

  const AdminLoyaltyTransactionEntity({
    required this.id,
    required this.date,
    required this.customerName,
    required this.transactionType,
    required this.points,
    required this.balanceAfter,
    this.orderName,
    required this.description,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        customerName,
        transactionType,
        points,
        balanceAfter,
        orderName,
        description,
        createdBy,
      ];
}

/// Admin Loyalty Settings Entity
class AdminLoyaltySettingsEntity extends Equatable {
  final double earningRate;
  final double redemptionRate;
  final int minRedemption;

  const AdminLoyaltySettingsEntity({
    required this.earningRate,
    required this.redemptionRate,
    required this.minRedemption,
  });

  @override
  List<Object?> get props => [earningRate, redemptionRate, minRedemption];
}

/// Admin Contact & WhatsApp Settings Entity
class AdminContactSettingsEntity extends Equatable {
  final String whatsappNumber;
  final String whatsappDefaultMessage;
  final bool whatsappEnabled;
  final String supportPhone;
  final double deliveryFee;

  const AdminContactSettingsEntity({
    required this.whatsappNumber,
    required this.whatsappDefaultMessage,
    required this.whatsappEnabled,
    required this.supportPhone,
    this.deliveryFee = 31.95,
  });

  factory AdminContactSettingsEntity.fromJson(Map<String, dynamic> json) {
    final wa = json['whatsapp'] is Map<String, dynamic>
        ? json['whatsapp'] as Map<String, dynamic>
        : <String, dynamic>{};
    return AdminContactSettingsEntity(
      whatsappNumber: (wa['number'] ?? wa['phone'] ?? json['whatsapp_number'] ?? '+966500000000').toString(),
      whatsappDefaultMessage: (wa['default_message'] ?? json['whatsapp_default_message'] ?? 'مرحباً، أود الاستفسار عن ذبائح المملكة').toString(),
      whatsappEnabled: wa['enabled'] == true || json['whatsapp_enabled'] == true || wa['enabled'] == 'True',
      supportPhone: (json['support_phone'] ?? '920000000').toString(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 31.95,
    );
  }

  AdminContactSettingsEntity copyWith({
    String? whatsappNumber,
    String? whatsappDefaultMessage,
    bool? whatsappEnabled,
    String? supportPhone,
    double? deliveryFee,
  }) {
    return AdminContactSettingsEntity(
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      whatsappDefaultMessage: whatsappDefaultMessage ?? this.whatsappDefaultMessage,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      supportPhone: supportPhone ?? this.supportPhone,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }

  @override
  List<Object?> get props => [
        whatsappNumber,
        whatsappDefaultMessage,
        whatsappEnabled,
        supportPhone,
        deliveryFee,
      ];
}

/// Admin Product Carcass Size Entity (jabin.product.size)
class AdminSizeEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final String name;
  final String? subTitle;
  final double price;
  final int calories;
  final int loyaltyPoints;
  final int pointsPrice;
  final int sequence;
  final bool isDefault;
  final bool isActive;

  const AdminSizeEntity({
    required this.id,
    required this.productId,
    this.productName = '',
    required this.name,
    this.subTitle,
    required this.price,
    this.calories = 243,
    this.loyaltyPoints = 0,
    this.pointsPrice = 0,
    this.sequence = 10,
    this.isDefault = false,
    this.isActive = true,
  });

  AdminSizeEntity copyWith({
    int? id,
    int? productId,
    String? productName,
    String? name,
    String? subTitle,
    double? price,
    int? calories,
    int? loyaltyPoints,
    int? pointsPrice,
    int? sequence,
    bool? isDefault,
    bool? isActive,
  }) {
    return AdminSizeEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      name: name ?? this.name,
      subTitle: subTitle ?? this.subTitle,
      price: price ?? this.price,
      calories: calories ?? this.calories,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      pointsPrice: pointsPrice ?? this.pointsPrice,
      sequence: sequence ?? this.sequence,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
    );
  }

  factory AdminSizeEntity.fromMap(Map<String, dynamic> map) {
    return AdminSizeEntity(
      id: (map['id'] as num?)?.toInt() ?? 0,
      productId: (map['product_id'] as num?)?.toInt() ?? 0,
      productName: map['product_name'] as String? ?? '',
      name: map['name'] as String? ?? '',
      subTitle: map['sub_title'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      calories: (map['calories'] as num?)?.toInt() ?? 243,
      loyaltyPoints: (map['loyalty_points'] as num?)?.toInt() ?? 0,
      pointsPrice: (map['points_price'] as num?)?.toInt() ?? 0,
      sequence: (map['sequence'] as num?)?.toInt() ?? 10,
      isDefault: map['is_default'] as bool? ?? false,
      isActive: map['active'] as bool? ?? map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'product_id': productId,
    'name': name,
    if (subTitle != null && subTitle!.isNotEmpty) 'sub_title': subTitle,
    'price': price,
    'calories': calories,
    'sequence': sequence,
    'is_default': isDefault,
    'active': isActive,
    'is_active': isActive,
  };

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        name,
        subTitle,
        price,
        calories,
        loyaltyPoints,
        pointsPrice,
        sequence,
        isDefault,
        isActive,
      ];
}



