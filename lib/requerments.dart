import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Requerments extends StatefulWidget {
  const Requerments({super.key});

  @override
  State<Requerments> createState() => _RequermentsState();
}

class _RequermentsState extends State<Requerments> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController x1 = TextEditingController();
  final TextEditingController x2 = TextEditingController();

  final TextEditingController y1 = TextEditingController();
  final TextEditingController y2 = TextEditingController();
  final TextEditingController texee = TextEditingController();

  final TextEditingController delivery = TextEditingController();
  final TextEditingController lat = TextEditingController();
  final TextEditingController lon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: StreamBuilder(
              stream: firestore.collection('MAIN').snapshots(),
              builder: (context, snapshot) {
                var restaurant = snapshot.data!.docs[0];

                // 'lat': lat,
                // 'lon': long,
                // 'x1': x1,
                // 'x2': x2,
                // 'del': del,
                // 'tax': tax,

                x1.text = restaurant['x1'];
                x2.text = restaurant['x2'];
                y1.text = restaurant['y1'];
                y2.text = restaurant['y2'];
                lat.text = restaurant['lat'];
                lon.text = restaurant['lon'];
                delivery.text = restaurant['del'];
                texee.text = restaurant['tax'];

                var size = MediaQuery.of(context).size;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size.width / 2.4,
                            child: TextField(
                              controller: x1,
                              decoration: InputDecoration(
                                labelText: 'Menu row size (only number)*',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width / 2.4,
                            child: TextField(
                              controller: y1,
                              decoration: InputDecoration(
                                labelText: 'Menu column (only number) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size.width / 2.4,
                            child: TextField(
                              controller: x2,
                              decoration: InputDecoration(
                                labelText: 'Restouran row size (only number)*',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width / 2.4,
                            child: TextField(
                              controller: y2,
                              decoration: InputDecoration(
                                labelText: 'Restouran column (only number) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 50),
                      child: TextField(
                        controller: texee,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText: 'Taxee %',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 50),
                      child: TextField(
                        controller: delivery,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText: 'Delivery per km',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 50),
                      child: TextField(
                        controller: lat,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 50),
                      child: TextField(
                        controller: lon,
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            backgroundColor: Colors.indigoAccent,
                            iconColor: Colors.white),
                        onPressed: () {
                          if (lat.text.isNotEmpty &&
                              lon.text.isNotEmpty &&
                              x1.text.isNotEmpty &&
                              y1.text.isNotEmpty &&
                              x2!.text.isNotEmpty &&
                              y2.text.isNotEmpty &&
                              delivery.text.isNotEmpty &&
                              texee.text.isNotEmpty) {
                            addFood(lat.text, lon.text, x1.text, y1.text,
                                x2!.text, y2.text, delivery.text, texee.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill in all fields!'),
                              ),
                            );
                          }
                        },
                        label: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "ADD PRODUCT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  // void _editFood(String lat, String long, String x1, String x2,
  //     String del, String tax) {
  //   final TextEditingController foodNameController = TextEditingController();
  //   final TextEditingController foodPriceController = TextEditingController();
  //   final TextEditingController foodDescriptionController =
  //   TextEditingController();
  //
  //   // bool isVeg = false;
  //   var size = MediaQuery.of(context).size;
  //   foodNameController.text = name;
  //   foodPriceController.text = price.toString();
  //   foodDescriptionController.text = description;
  //   _bannerImageUrl = banner;
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Edit Product"),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               GestureDetector(
  //                 onTap: () {
  //                   _pickImage();
  //                 },
  //                 child: Image.network(
  //                   banner,
  //                   height: 150,
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     vertical: 15.0, horizontal: 50),
  //                 child: TextField(
  //                   controller: foodNameController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Product Name',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     vertical: 15.0, horizontal: 50),
  //                 child: TextField(
  //                   controller: foodPriceController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Product Price',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     vertical: 15.0, horizontal: 50),
  //                 child: TextField(
  //                   controller: foodDescriptionController,
  //                   decoration: InputDecoration(
  //                     labelText: 'Product Description',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     vertical: 15.0, horizontal: 50),
  //                 child: StatefulBuilder(builder: (context, setState) {
  //                   return SwitchListTile(
  //                     title: Text('For Veg'),
  //                     value: isVeg,
  //                     onChanged: (bool value) {
  //                       setState(() {
  //                         isVeg = value;
  //                       });
  //                     },
  //                   );
  //                 }),
  //               ),
  //               Padding(
  //                 padding: EdgeInsets.symmetric(
  //                   vertical: 15,
  //                 ),
  //                 child: Container(
  //                   width: size.width,
  //                   height: 50,
  //                   padding: EdgeInsets.symmetric(horizontal: 50),
  //                   decoration:
  //                   BoxDecoration(borderRadius: BorderRadius.circular(15)),
  //                   child: ElevatedButton.icon(
  //                     icon: Icon(Icons.edit),
  //                     label: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 15.0),
  //                       child: Text(
  //                         "Edit",
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 19,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                     style: ElevatedButton.styleFrom(
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(18.0),
  //                         ),
  //                         backgroundColor: Colors.indigoAccent,
  //                         iconColor: Colors.white),
  //                     onPressed: () {
  //                       // 'banner': _bannerImageUrl,
  //                       // 'lenght': lenght,
  //                       // 'desctiption': description,
  //                       if (foodNameController.text.isNotEmpty &&
  //                           foodDescriptionController.text.isNotEmpty &&
  //                           foodPriceController.text.isNotEmpty &&
  //                           _bannerImageUrl!.isNotEmpty) {
  //                         firestore.collection('grossary').doc(id).update({
  //                           'banner': _bannerImageUrl,
  //                           'name': foodNameController.text,
  //                           'price': foodPriceController.text,
  //                           'description': foodDescriptionController.text,
  //                           'rate': rate,
  //                           'rate_count': rate_count,
  //                           'veg': isVeg,
  //                         });
  //                         Navigator.pop(context);
  //                       } else {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(
  //                             content: Text('Please fill in all fields !'),
  //                           ),
  //                         );
  //                       }
  //                     },
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  //

  Future<void> addFood(String lat, String long, String x1, String y1, String x2,
      String y2, String del, String tax) async {
    // if (_bannerImage != null) {
    //   _bannerUrl = await uploadBanner(_webImage!);
    // }

    // print(
    //     "${widget.restaurantId}-----${widget.foodTypeId}---${name}____${_bannerImageUrl}");

    try {
      await firestore.collection('MAIN').doc("REQ").update({
        'lat': lat,
        'lon': long,
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
        'del': del,
        'tax': tax,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfull saved!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error $e!'),
        ),
      );
      print("XATOLIK XATOLIK XATOLIK $e");
    }
  }
}
//
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker_web/image_picker_web.dart';
