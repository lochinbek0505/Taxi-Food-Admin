import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';

import 'Orders.dart';

// import 'order_model.dart';
class OrderService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Stream<List<Order>> fetchOrders() {
    return _dbRef.child('orders').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      // Convert the data from LinkedHashMap to Map<String, dynamic>
      final Map<String, dynamic> ordersMap = LinkedHashMap.from(data as Map);

      // Map over each entry and convert to Order
      return ordersMap.entries.map((entry) {
        final orderData = Map<String, dynamic>.from(entry.value as Map);
        return Order.fromJson(orderData);
      }).toList();
    });
  }

// Function to update an order
  Future<void> updateOrder(Order order) async {
    try {
      await _dbRef.child('orders/${order.orderId}').update({
        'customerName': order.customerName,
        'location': order.location,
        'phone': order.phone,
        'orderTime': order.orderTime,
        'price': order.price,
        'isConfirmed': order.isConfirmed,
        'orderedFood': order.orderedFood
            .map((foodItem) => {
                  'name': foodItem.name,
                  'price': foodItem.price,
                  'imageUrl': foodItem.imageUrl,
                })
            .toList(),
      });
      print("Order updated successfully!");
    } catch (e) {
      print("Failed to update order: $e");
    }
  }
  //
  // Future<void> updateOrder(String orderId, Order order) async {
  //   await _dbRef.child('orders/$orderId').update(order.toJson());
  // }

  Future<void> deleteOrder(String orderId) async {
    await _dbRef.child('orders/$orderId').remove();
  }

  // / Fetches the orders from Firebase Realtime Database as a stream.
// Stream<List<Order>> fetchOrders() {
//   return _dbRef.child('orders').onValue.map((event) {
//     final Map<dynamic, dynamic>? data =
//         event.snapshot.value as Map<dynamic, dynamic>?;
//     // print("BU DATA ERUR EY DOSI YORLAR $data");
//     try {
//       print("BU DATA ERUR EY DOSI YORLAR ${data!.values.map((orderData) {
//         return Order.fromJson(Map<String, dynamic>.from(orderData));
//       }).toList()}");
//     } catch (e) {
//       print("XATOLIK $e");
//     }
//     if (data == null) return [];
//
//     // Map the data to a list of Orders
//     return data.values.map((orderData) {
//       return Order.fromJson(Map<String, dynamic>.from(orderData));
//     }).toList();
//   });
// }

// Stream<List<Order>> fetchOrders() {
//   print(_dbRef.child('Orders').onValue);
//   return _dbRef.child('Orders').onValue.map((event) {
//     final Map<dynamic, dynamic>? data =
//         event.snapshot.value as Map<dynamic, dynamic>?;
//     if (data == null) return [];
//
//     return data.values.map((orderData) {
//       return Order.fromJson(Map<String, dynamic>.from(orderData));
//     }).toList();
//   });
// }
}
