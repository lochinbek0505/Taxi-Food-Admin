import 'dart:collection';
import 'package:firebase_database/firebase_database.dart';
import 'Orders.dart';

class OrderService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<List<Order>> fetchOrders() {
    return _dbRef.child('orders').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      // Convert the data from LinkedHashMap to List<Map<String, dynamic>>
      final ordersMap = (data as Map<dynamic, dynamic>).map((key, value) {
        return MapEntry(key, value as Map<dynamic, dynamic>);
      });

      // Map over each entry and convert to Order
      return ordersMap.entries.map((entry) {
        final orderData = entry.value;
        return Order.fromMap(orderData); // Convert to Order
      }).toList();
    });
  }

  Future<void> updateOrder(Order order) async {
    try {
      List<Map<String, dynamic>> orderedFoodList =
          order.orderedFood.map((foodItem) {
        return {
          'name': foodItem.name,
          'price': foodItem.price,
          'imageUrl': foodItem.imageUrl,
          'count': foodItem.count,
        };
      }).toList();

      await _dbRef.child('orders/${order.orderId}').update({
        'customerName': order.customerName,
        'location': order.location,
        'phone': order.phone,
        'orderTime': order.orderTime,
        'deliveryPrice': order.deliveryPrice,
        'subTotal': order.subTotal,
        'taxPrice': order.taxPrice,
        'total': order.total,
        'confirmed': order.confirmed,
        'orderedFood': orderedFoodList,
        'latitude': order.latitude,
        'longitude': order.longitude,
      });

      print("Order updated successfully!");
    } catch (e) {
      print("Failed to update order: $e");
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _dbRef.child('orders/$orderId').remove();
  }
}
