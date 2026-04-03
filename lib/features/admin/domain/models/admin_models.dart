import '../../../../core/utils/json_parsers.dart';

class AdminProductItem {
  final int id;
  final String name;
  final String brand;
  final String category;
  final String model;
  final double price;
  final int stockQuantity;

  const AdminProductItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.model,
    required this.price,
    required this.stockQuantity,
  });

  factory AdminProductItem.fromJson(Map<String, dynamic> json) {
    return AdminProductItem(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
      brand: JsonParsers.toStringValue(json['brand']),
      category: JsonParsers.toStringValue(json['category']),
      model: JsonParsers.toStringValue(json['model']),
      price: JsonParsers.toDouble(json['price']),
      stockQuantity: JsonParsers.toInt(json['stockQuantity']),
    );
  }
}

class AdminOrderItem {
  final int id;
  final String? orderDate;
  final String customer;
  final String status;
  final String deliveryType;
  final String paymentType;
  final String deliveryAddress;
  final double totalAmount;

  const AdminOrderItem({
    required this.id,
    this.orderDate,
    required this.customer,
    required this.status,
    required this.deliveryType,
    required this.paymentType,
    required this.deliveryAddress,
    required this.totalAmount,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: JsonParsers.toInt(json['id']),
      orderDate: JsonParsers.toNullableString(json['orderDate']),
      customer: JsonParsers.toStringValue(json['customer']),
      status: JsonParsers.toStringValue(json['status']),
      deliveryType: JsonParsers.toStringValue(json['deliveryType']),
      paymentType: JsonParsers.toStringValue(json['paymentType']),
      deliveryAddress: JsonParsers.toStringValue(json['deliveryAddress']),
      totalAmount: JsonParsers.toDouble(json['totalAmount']),
    );
  }
}

class AdminUserItem {
  final int userId;
  final String lastName;
  final String firstName;
  final String email;
  final String role;
  final bool isBlocked;

  const AdminUserItem({
    required this.userId,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.role,
    required this.isBlocked,
  });

  String get fullName => '$lastName $firstName';

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      userId: JsonParsers.toInt(json['userId']),
      lastName: JsonParsers.toStringValue(json['lastName']),
      firstName: JsonParsers.toStringValue(json['firstName']),
      email: JsonParsers.toStringValue(json['email']),
      role: JsonParsers.toStringValue(json['role']),
      isBlocked: JsonParsers.toBool(json['isBlocked']),
    );
  }
}

class AdminReviewItem {
  final int reviewId;
  final int rating;
  final String? comment;
  final String? reviewDate;
  final String productName;
  final String authorName;

  const AdminReviewItem({
    required this.reviewId,
    required this.rating,
    this.comment,
    this.reviewDate,
    required this.productName,
    required this.authorName,
  });

  factory AdminReviewItem.fromJson(Map<String, dynamic> json) {
    return AdminReviewItem(
      reviewId: JsonParsers.toInt(json['reviewId']),
      rating: JsonParsers.toInt(json['rating']),
      comment: JsonParsers.toNullableString(json['comment']),
      reviewDate: JsonParsers.toNullableString(json['reviewDate']),
      productName: JsonParsers.toStringValue(json['productName']),
      authorName: JsonParsers.toStringValue(json['authorName']),
    );
  }
}

class AdminIncomeStats {
  final int days;
  final double income;

  const AdminIncomeStats({
    required this.days,
    required this.income,
  });

  factory AdminIncomeStats.fromJson(Map<String, dynamic> json) {
    return AdminIncomeStats(
      days: JsonParsers.toInt(json['days']),
      income: JsonParsers.toDouble(json['income']),
    );
  }
}

class AdminTopProductItem {
  final int productId;
  final String productName;
  final int totalSold;

  const AdminTopProductItem({
    required this.productId,
    required this.productName,
    required this.totalSold,
  });

  factory AdminTopProductItem.fromJson(Map<String, dynamic> json) {
    return AdminTopProductItem(
      productId: JsonParsers.toInt(json['productId']),
      productName: JsonParsers.toStringValue(json['productName']),
      totalSold: JsonParsers.toInt(json['totalSold']),
    );
  }
}

class AdminTopUserItem {
  final int userId;
  final String fullName;
  final double totalSpent;

  const AdminTopUserItem({
    required this.userId,
    required this.fullName,
    required this.totalSpent,
  });

  factory AdminTopUserItem.fromJson(Map<String, dynamic> json) {
    return AdminTopUserItem(
      userId: JsonParsers.toInt(json['userId']),
      fullName: JsonParsers.toStringValue(json['fullName']),
      totalSpent: JsonParsers.toDouble(json['totalSpent']),
    );
  }
}

class AuditLogItem {
  final int auditId;
  final String actionName;
  final String entityName;
  final int entityId;
  final String? oldValue;
  final String? newValue;
  final String? actionDate;
  final String? accountEmail;

  const AuditLogItem({
    required this.auditId,
    required this.actionName,
    required this.entityName,
    required this.entityId,
    this.oldValue,
    this.newValue,
    this.actionDate,
    this.accountEmail,
  });

  factory AuditLogItem.fromJson(Map<String, dynamic> json) {
    return AuditLogItem(
      auditId: JsonParsers.toInt(json['auditId']),
      actionName: JsonParsers.toStringValue(json['actionName']),
      entityName: JsonParsers.toStringValue(json['entityName']),
      entityId: JsonParsers.toInt(json['entityId']),
      oldValue: JsonParsers.toNullableString(json['oldValue']),
      newValue: JsonParsers.toNullableString(json['newValue']),
      actionDate: JsonParsers.toNullableString(json['actionDate']),
      accountEmail: JsonParsers.toNullableString(json['accountEmail']),
    );
  }
}

class AdminRoleOption {
  final int id;
  final String name;

  const AdminRoleOption({
    required this.id,
    required this.name,
  });

  factory AdminRoleOption.fromJson(Map<String, dynamic> json) {
    return AdminRoleOption(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
    );
  }
}

class AdminOrderStatusOption {
  final int id;
  final String name;

  const AdminOrderStatusOption({
    required this.id,
    required this.name,
  });

  factory AdminOrderStatusOption.fromJson(Map<String, dynamic> json) {
    return AdminOrderStatusOption(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
    );
  }
}