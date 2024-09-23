import 'FoodItem.dart';

class Order {
  late final bool confirmed;
  final String customerName;
  final String deliveryPrice;
  final double latitude;
  final double longitude;
  final String location;
  final String orderId;
  final String orderTime;
  final List<FoodItem> orderedFood;
  final String phone;
  final String subTotal;
  final String taxPrice;
  final String total;

  Order({
    required this.confirmed,
    required this.customerName,
    required this.deliveryPrice,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.orderId,
    required this.orderTime,
    required this.orderedFood,
    required this.phone,
    required this.subTotal,
    required this.taxPrice,
    required this.total,
  });

  factory Order.fromMap(Map<dynamic, dynamic> map) {
    var foodList = (map['orderedFood'] as List<dynamic>? ?? [])
        .map((foodMap) => FoodItem.fromMap(foodMap as Map<dynamic, dynamic>))
        .toList();

    return Order(
      confirmed: map['confirmed'] as bool? ?? false,
      customerName: map['customerName'] as String? ?? '',
      deliveryPrice: map['deliveryPrice'] as String? ?? '',
      latitude: (map['latitute'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longtute'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] as String? ?? '',
      orderId: map['orderId'] as String? ?? '',
      orderTime: map['orderTime'] as String? ?? '',
      orderedFood: foodList,
      phone: map['phone'] as String? ?? '',
      subTotal: map['subTotal'] as String? ?? '',
      taxPrice: map['taxPrice'] as String? ?? '',
      total: map['total'] as String? ?? '',
    );
  }
}
