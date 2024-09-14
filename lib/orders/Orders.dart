import 'FoodItem.dart';

class Order {
  final String customerName;
  final String location;
  final String orderId;
  final String phone;
  final String orderTime;
  final double price;
  final List<FoodItem> orderedFood;
  late final bool isConfirmed;

  Order(
    this.orderId, {
    required this.customerName,
    required this.location,
    required this.phone,
    required this.orderTime,
    required this.price,
    required this.orderedFood,
    required this.isConfirmed,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var foodsFromJson = json['orderedFood'] as List<dynamic>;
    List<FoodItem> foodList = foodsFromJson
        .map(
            (item) => FoodItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return Order(
      json['orderId'],
      customerName: json['customerName'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String,
      orderTime: json['orderTime'] as String,
      price: (json['price'] as num).toDouble(),
      orderedFood: foodList,
      isConfirmed: json['isConfirmed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'location': location,
      'phone': phone,
      'orderTime': orderTime,
      'price': price,
      'orderedFood': orderedFood.map((food) => food.toJson()).toList(),
      'isConfirmed': isConfirmed,
    };
  }
}
