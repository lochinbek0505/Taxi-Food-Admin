import 'package:flutter/material.dart';
import 'package:taxi_food_admin/orders/OrderService.dart';

import 'OrderCard.dart';
import 'Orders.dart';

class OrderScreen extends StatelessWidget {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color(0xff2A5270),
        title: Text(
          'Orders',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Order>>(
        stream: _orderService.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          }
          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return OrderCard(order: orders[index]);
            },
          );
        },
      ),
    );
  }
}
