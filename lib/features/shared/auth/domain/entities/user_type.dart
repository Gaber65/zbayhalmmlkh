enum UserType {
  individual,
  business,
  admin,
  customer,
  unknown;

  static UserType fromString(String? type) {
    switch (type) {
      case 'individual':
        return UserType.individual;
      case 'business':
        return UserType.business;
      case 'admin':
        return UserType.admin;
      case 'customer':
        return UserType.customer;
      default:
        return UserType.unknown;
    }
  }

  String toJson() => name;
}
