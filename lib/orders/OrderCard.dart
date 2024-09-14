import 'package:flutter/material.dart';
import 'package:taxi_food_admin/orders/OrderService.dart';

import 'Orders.dart';
// import 'order_model.dart';

class OrderCard extends StatefulWidget {
  final Order order;

  OrderCard({required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${widget.order.customerName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 15,
            ),
            Text('Location: ${widget.order.location}'),
            SizedBox(
              height: 15,
            ),
            Text('Phone: ${widget.order.phone}'),
            SizedBox(
              height: 15,
            ),
            Text('Order Time: ${widget.order.orderTime}'),
            SizedBox(
              height: 15,
            ),
            Text('Price: \$${widget.order.price.toStringAsFixed(2)}'),
            SizedBox(height: 10),
            Text('Ordered Food:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: widget.order.orderedFood.map((foodItem) {
                return ListTile(
                  leading:
                      Image.network(foodItem.imageUrl, width: 50, height: 50),
                  title: Text(foodItem.name),
                  subtitle: Text('\$${foodItem.price.toStringAsFixed(2)}'),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(order.isConfirmed ? 'Confirmed' : 'Unconfirmed',
                //     style: TextStyle(
                //         color: order.isConfirmed ? Colors.green : Colors.red,
                //         fontWeight: FontWeight.bold)),
                !widget.order.isConfirmed
                    ? Container(
                        width: 200,
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                            ),
                            onPressed: () {
                              var service = OrderService();
                              print(
                                  "ADD DAN UPDADED DADAD ${widget.order.isConfirmed}");
                              setState(() {
                                var confirm = true;
                                var order = Order(widget.order.orderId,
                                    customerName: widget.order.customerName,
                                    location: widget.order.location,
                                    phone: widget.order.phone,
                                    orderTime: widget.order.orderTime,
                                    price: widget.order.price,
                                    orderedFood: widget.order.orderedFood,
                                    isConfirmed: confirm);
                                service.updateOrder(order);
                              });
                            },
                            // Handle accept/reject functionality her
                            child: Text(
                              'DONE',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox()
                // : Text(
                //     'Completed',
                //     style: TextStyle(
                //       color: Colors.green,
                //     ),
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
