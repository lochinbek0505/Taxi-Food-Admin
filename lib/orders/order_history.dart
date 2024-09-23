import 'package:flutter/material.dart';
import 'package:taxi_food_admin/orders/OrderService.dart';
import 'OrderCard.dart';
import 'Orders.dart';
import 'package:intl/intl.dart'; // For formatting dates

class OrderHistory extends StatelessWidget {
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
            return Center(child: Text('No orders available.'));
          }

          final orders = snapshot.data!;

          // Separate unconfirmed and confirmed orders
          final unconfirmedOrders = orders
              .where((order) => !order.confirmed)
              .toList()
            ..sort((a, b) => a.orderId.compareTo(b.orderId));

          final confirmedOrders = orders
              .where((order) => order.confirmed)
              .toList()
            ..sort((a, b) => a.orderId.compareTo(b.orderId));

          // Group confirmed orders by date
          Map<String, List<Order>> groupedOrdersByDate = {};
          for (var order in confirmedOrders) {
            // Assuming orderTime is in the format 'yyyy-MM-dd HH:mm:ss' (adjust this based on your actual format)
            String date = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(order.orderTime));

            if (!groupedOrdersByDate.containsKey(date)) {
              groupedOrdersByDate[date] = [];
            }
            groupedOrdersByDate[date]!.add(order);
          }

          return ListView(
            children: [
              // Unconfirmed Orders Section
              if (unconfirmedOrders.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Unconfirmed Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...unconfirmedOrders.map((order) => OrderCard(order: order)),
              ],

              // Confirmed Orders Section (History)
              if (confirmedOrders.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Order History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...groupedOrdersByDate.entries.map((entry) {
                  String date = entry.key;
                  List<Order> ordersForDate = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Date: $date',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...ordersForDate.map((order) => OrderCard(order: order)),
                    ],
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}
