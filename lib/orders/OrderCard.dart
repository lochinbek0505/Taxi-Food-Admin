import 'dart:js' as js;

import 'package:flutter/material.dart';

import 'OrderService.dart';
import 'Orders.dart';

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
            SizedBox(height: 15),
            Text('Location: ${widget.order.location}'),
            SizedBox(height: 15),
            Text('Phone: ${widget.order.phone}'),
            SizedBox(height: 15),
            Text('Order Time: ${widget.order.orderTime}'),
            SizedBox(height: 15),
            Text('SubTotal Price: \$${widget.order.subTotal}'),
            SizedBox(height: 15),
            Text('Texee Price: \$${widget.order.taxPrice}'),
            SizedBox(height: 15),
            Text('Delivery Price: \$${widget.order.deliveryPrice}'),
            SizedBox(height: 15),
            Text('Total Price: \$${widget.order.total}'),
            SizedBox(height: 20),
            Container(
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.map,
                  color: Colors.white,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Goto google map",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    backgroundColor: Colors.indigoAccent,
                    iconColor: Colors.white),
                onPressed: () {
                  print(widget.order.latitude);
                  openMap(widget.order.latitude, widget.order.longitude);
                },
              ),
            ),
            SizedBox(height: 20),
            Text('Ordered Food:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Column(
              children: widget.order.orderedFood.map((foodItem) {
                return ListTile(
                  leading:
                      Image.network(foodItem.imageUrl, width: 50, height: 50),
                  title: Text(foodItem.name),
                  subtitle: Text('\$${foodItem.price}'),
                  trailing: Text('x${foodItem.count}'),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!widget.order.confirmed)
                  Center(
                    child: Container(
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.done,
                          color: Colors.white,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "Order completed",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            backgroundColor: Colors.indigoAccent,
                            iconColor: Colors.white),
                        onPressed: () async {
                          // Create a new order with the updated confirmed status
                          final updatedOrder = Order(
                            orderId: widget.order.orderId,
                            customerName: widget.order.customerName,
                            location: widget.order.location,
                            phone: widget.order.phone,
                            orderTime: widget.order.orderTime,
                            deliveryPrice: widget.order.deliveryPrice,
                            subTotal: widget.order.subTotal,
                            taxPrice: widget.order.taxPrice,
                            total: widget.order.total,
                            latitude: widget.order.latitude,
                            longitude: widget.order.longitude,
                            orderedFood: widget.order.orderedFood,
                            confirmed: true, // Set confirmed to true
                          );

                          // Update in Firebase
                          try {
                            await OrderService().updateOrder(updatedOrder);
                            // Update local UI
                            setState(() {
                              widget.order.confirmed = true;
                            });
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Order confirmed successfully!')),
                            // );
                          } catch (e) {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Failed to confirm order: $e')),
                            // );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            )

            // ElevatedButton(
            //     onPressed: () async {
            //       // Create a new order with the updated confirmed status
            //       final updatedOrder = Order(
            //         orderId: widget.order.orderId,
            //         customerName: widget.order.customerName,
            //         location: widget.order.location,
            //         phone: widget.order.phone,
            //         orderTime: widget.order.orderTime,
            //         deliveryPrice: widget.order.deliveryPrice,
            //         subTotal: widget.order.subTotal,
            //         taxPrice: widget.order.taxPrice,
            //         total: widget.order.total,
            //         latitude: widget.order.latitude,
            //         longitude: widget.order.longitude,
            //         orderedFood: widget.order.orderedFood,
            //         confirmed: true, // Set confirmed to true
            //       );
            //
            //       // Update in Firebase
            //       try {
            //         await OrderService().updateOrder(updatedOrder);
            //         // Update local UI
            //         setState(() {
            //           widget.order.confirmed = true;
            //         });
            //         // ScaffoldMessenger.of(context).showSnackBar(
            //         //   SnackBar(content: Text('Order confirmed successfully!')),
            //         // );
            //       } catch (e) {
            //         // ScaffoldMessenger.of(context).showSnackBar(
            //         //   SnackBar(content: Text('Failed to confirm order: $e')),
            //         // );
            //       }
            //     },
            //     child: Text('Order completed'),
            //   ),
          ],
        ),
      ),
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    js.context.callMethod('open', [
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude"
    ]);

    // String googleMapsUrl =
    //     "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    // if (await canLaunch(googleMapsUrl)) {
    //   await launch(googleMapsUrl);
    // } else {
    //   throw 'Could not open the map.';
    // }
  }
}
