import '../../../../core/utils/json_parsers.dart';

class OrderDetails {
  final int id;
  final String? orderDate;
  final double totalAmount;
  final String? orderComment;
  final String status;
  final DeliveryInfo delivery;
  final String paymentType;
  final DeliveryAddress address;
  final List<OrderDetailItem> items;
  final List<OrderStatusHistoryItem> history;

  const OrderDetails({
    required this.id,
    this.orderDate,
    required this.totalAmount,
    this.orderComment,
    required this.status,
    required this.delivery,
    required this.paymentType,
    required this.address,
    required this.items,
    required this.history,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: JsonParsers.toInt(json['id']),
      orderDate: JsonParsers.toNullableString(json['orderDate']),
      totalAmount: JsonParsers.toDouble(json['totalAmount']),
      orderComment: JsonParsers.toNullableString(json['orderComment']),
      status: JsonParsers.toStringValue(json['status']),
      delivery: DeliveryInfo.fromJson(json['delivery'] as Map<String, dynamic>),
      paymentType: JsonParsers.toStringValue(json['paymentType']),
      address:
          DeliveryAddress.fromJson(json['address'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderDetailItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                OrderStatusHistoryItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class DeliveryInfo {
  final String type;
  final double cost;
  final String estimatedTime;

  const DeliveryInfo({
    required this.type,
    required this.cost,
    required this.estimatedTime,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      type: JsonParsers.toStringValue(json['type']),
      cost: JsonParsers.toDouble(json['cost']),
      estimatedTime: JsonParsers.toStringValue(json['estimatedTime']),
    );
  }
}

class DeliveryAddress {
  final int id;
  final String country;
  final String city;
  final String street;
  final String house;
  final String? apartment;
  final String postalCode;

  const DeliveryAddress({
    required this.id,
    required this.country,
    required this.city,
    required this.street,
    required this.house,
    this.apartment,
    required this.postalCode,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: JsonParsers.toInt(json['id']),
      country: JsonParsers.toStringValue(json['country']),
      city: JsonParsers.toStringValue(json['city']),
      street: JsonParsers.toStringValue(json['street']),
      house: JsonParsers.toStringValue(json['house']),
      apartment: JsonParsers.toNullableString(json['apartment']),
      postalCode: JsonParsers.toStringValue(json['postalCode']),
    );
  }

  String get fullAddress =>
      '$country, $city, $street $house${apartment?.isNotEmpty == true ? ', кв. $apartment' : ''}, $postalCode';
}

class OrderDetailItem {
  final int orderDetailId;
  final int quantity;
  final double price;
  final double itemTotal;
  final OrderDetailProduct product;

  const OrderDetailItem({
    required this.orderDetailId,
    required this.quantity,
    required this.price,
    required this.itemTotal,
    required this.product,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      orderDetailId: JsonParsers.toInt(json['orderDetailId']),
      quantity: JsonParsers.toInt(json['quantity']),
      price: JsonParsers.toDouble(json['price']),
      itemTotal: JsonParsers.toDouble(json['itemTotal']),
      product:
          OrderDetailProduct.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}

class OrderDetailProduct {
  final int id;
  final String name;
  final String model;
  final String? imageUrl;
  final String brandName;

  const OrderDetailProduct({
    required this.id,
    required this.name,
    required this.model,
    this.imageUrl,
    required this.brandName,
  });

  factory OrderDetailProduct.fromJson(Map<String, dynamic> json) {
    return OrderDetailProduct(
      id: JsonParsers.toInt(json['id']),
      name: JsonParsers.toStringValue(json['name']),
      model: JsonParsers.toStringValue(json['model']),
      imageUrl: JsonParsers.toNullableString(json['imageUrl']),
      brandName: JsonParsers.toStringValue(json['brandName']),
    );
  }
}

class OrderStatusHistoryItem {
  final int id;
  final String status;
  final String? date;

  const OrderStatusHistoryItem({
    required this.id,
    required this.status,
    this.date,
  });

  factory OrderStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryItem(
      id: JsonParsers.toInt(json['id']),
      status: JsonParsers.toStringValue(json['status']),
      date: JsonParsers.toNullableString(json['date']),
    );
  }
}