import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class FoodPage3 extends StatefulWidget {
  // FoodPage({required this.restaurantId, required this.foodTypeId});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage3> {
  bool isVeg = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  File? _bannerImage;
  Uint8List? _webImage; // To hold the image in web format (Uint8List)
  String? _bannerImageUrl;

  String gbImg = '';

  Future<void> _pickImage() async {
    try {
      Uint8List? result = await ImagePickerWeb.getImageAsBytes();

      if (result != null) {
        setState(() {
          _webImage = result; // Get the image in bytes
        });
        await _uploadImageToFirebaseWeb(_webImage!,
            "Restouran_${DateTime.now().millisecondsSinceEpoch}"); // Upload web image
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImageToFirebaseWeb(
      Uint8List imageBytes, String fileName) async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child('fruits/$fileName');
    UploadTask uploadTask = storageRef.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    _bannerImageUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      gbImg = _bannerImageUrl!;
    });
    setState(() {});
  }

  Future<void> addFood(
    String name,
    String price,
    String quanty,
    String tag1,
    String tag2,
  ) async {
    await firestore.collection('fruits_vegetables').doc(name).set({
      'banner': _bannerImageUrl ?? '', // Save the banner URL
      'name': name.toString(),
      'quanty': quanty.toString(),
      'price': price.toString(),
      'tag1': tag1,
      'tag2': tag2,
    });

    setState(() {
      _bannerImage = null;
      _bannerImageUrl = null;
      isVeg = false;
    });
  }

  void addRestouran(context) {
    List<bool> isSelected = [
      true,
      false,
    ];

    final TextEditingController foodNameController = TextEditingController();
    final TextEditingController foodPriceController = TextEditingController();
    final TextEditingController quantyController = TextEditingController();
    final TextEditingController tag1Controller = TextEditingController();
    final TextEditingController tag2Controller = TextEditingController();

    bool isVeg = false;
    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text("Add Item"),
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            content: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _pickImage();
                        setState(
                            () {}); // Refresh the UI to show the selected image
                      },
                      child: _webImage == null
                          ? Icon(
                              Icons.image,
                              size: 150,
                            )
                          : Image.memory(
                              _webImage!, // Display the selected image
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 50),
                      child: TextField(
                        controller: foodNameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size.width / 2.8,
                            child: TextField(
                              controller: quantyController,
                              decoration: InputDecoration(
                                labelText: 'Item Quantity *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width / 2.8,
                            child: TextField(
                              controller: foodPriceController,
                              decoration: InputDecoration(
                                labelText: 'Item Price (only number) *',
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
                            width: size.width / 2.8,
                            child: TextField(
                              controller: tag1Controller,
                              decoration: InputDecoration(
                                labelText: 'Item Tag1',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width / 2.8,
                            child: TextField(
                              controller: tag2Controller,
                              decoration: InputDecoration(
                                labelText: 'Item Tag2',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Wrap ToggleButtons inside StatefulBuilder to allow state change
                    Container(
                      width: size.width,
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            backgroundColor: Colors.indigoAccent,
                            iconColor: Colors.white),
                        onPressed: () {
                          if (foodNameController.text.isNotEmpty &&
                              quantyController.text.isNotEmpty &&
                              foodPriceController.text.isNotEmpty &&
                              _bannerImageUrl!.isNotEmpty) {
                            print(_bannerImageUrl);

                            addFood(
                              foodNameController.text,
                              foodPriceController.text,
                              quantyController.text,
                              tag1Controller.text.isNotEmpty
                                  ? tag1Controller.text
                                  : "",
                              tag2Controller.text.isNotEmpty
                                  ? tag2Controller.text
                                  : "",
                              // Pass whether it is Veg or Non Veg
                            );

                            foodNameController.clear();
                            quantyController.clear();
                            foodPriceController.clear();
                            _bannerImageUrl = "";
                            _webImage = null;
                            Navigator.pop(context);
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
                            "Add Item",
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
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// Add Food Document to Firestore

  /// Edit Food Document
  void _editFood(String id, String name, String price, String quanty,
      String banner, String tag1, String tag2) {
    _webImage = null;
    final TextEditingController foodNameController = TextEditingController();
    final TextEditingController foodPriceController = TextEditingController();
    final TextEditingController quantyController = TextEditingController();
    final TextEditingController tag1Controller = TextEditingController();
    final TextEditingController tag2Controller = TextEditingController();

    // bool isVeg = false;
    var size = MediaQuery.of(context).size;
    foodNameController.text = name;
    foodPriceController.text = price.toString();
    quantyController.text = quanty;
    tag1Controller.text = tag1;
    tag2Controller.text = tag2;
    _bannerImageUrl = banner;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            title: Text("Edit Item"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      _bannerImageUrl = "";
                      await _pickImage();

                      setState(() {});
                    },
                    child: _webImage == null
                        ? Image.network(
                            banner,
                            width: 150,
                          )
                        : Image.memory(
                            _webImage!, // Display the selected image
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: TextField(
                      controller: foodNameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: size.width / 2.8,
                          child: TextField(
                            controller: quantyController,
                            decoration: InputDecoration(
                              labelText: 'Item Quantity *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: size.width / 2.8,
                          child: TextField(
                            controller: foodPriceController,
                            decoration: InputDecoration(
                              labelText: 'Item Price (only number) *',
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
                          width: size.width / 2.8,
                          child: TextField(
                            controller: tag1Controller,
                            decoration: InputDecoration(
                              labelText: 'Item Tag1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: size.width / 2.8,
                          child: TextField(
                            controller: tag2Controller,
                            decoration: InputDecoration(
                              labelText: 'Item Tag2',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Wrap ToggleButtons inside StatefulBuilder to allow state change
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: Container(
                      width: size.width,
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.edit),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "Edit",
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
                          // 'banner': _bannerImageUrl,
                          // 'lenght': lenght,
                          // 'desctiption': description,
                          if (foodNameController.text.isNotEmpty &&
                              quantyController.text.isNotEmpty &&
                              foodPriceController.text.isNotEmpty &&
                              _bannerImageUrl!.isNotEmpty) {
                            // main_foods
                            //   'banner': _bannerImageUrl ?? '', // Save the banner URL
                            // 'name': name.toString(),
                            // 'quanty': quanty.toString(),
                            // 'price': price.toString(),
                            // 'tag1': tag1,
                            // 'tag2': tag2,
                            try {
                              await firestore
                                  .collection('fruits_vegetables')
                                  .doc(id)
                                  .update({
                                'banner': _bannerImageUrl,
                                'name': foodNameController.text,
                                'price': foodPriceController.text,
                                'quanty': quantyController.text,
                                'tag1': tag1Controller.text.isNotEmpty
                                    ? tag1Controller.text
                                    : "",
                                'tag2': tag2Controller.text.isNotEmpty
                                    ? tag2Controller.text
                                    : "",
                              });
                            } catch (e) {
                              print(e);
                            }
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill in all fields !'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  /// Delete Food Document
  void _deleteFood(String id) {
    firestore.collection('fruits_vegetables').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[180],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Items",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 15),
            padding: EdgeInsets.symmetric(
              horizontal: 50,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: ElevatedButton.icon(
              icon: Icon(Icons.restaurant_outlined),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  backgroundColor: Colors.indigoAccent,
                  iconColor: Colors.white),
              onPressed: () {
                addRestouran(context);

                // addFood(foodNameController.text, foodPriceController.text,
                //     foodDescriptionController.text);
              },
              iconAlignment: IconAlignment.start,
              label: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                child: Text(
                  "Add Item",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('fruits_vegetables').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text('Loading...');
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var food = snapshot.data!.docs[index];
                    return Container(
                      height: 110,
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 50,
                        ),
                        child: Center(
                          child: ListTile(
                            title: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                food['name'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text('\$${food['price']}'),
                            ),
                            leading: Image.network(
                              food['banner'],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),

                                  //         'banner': _bannerImageUrl ?? '', // Save the banner URL
                                  //         'name': name.toString(),
                                  //       'quanty': quanty.toString(),
                                  //     'price': price.toString(),
                                  // 'tag1': tag1,
                                  // 'tag2': tag2,

                                  onPressed: () => _editFood(
                                      food.id,
                                      food['name'],
                                      food['price'],
                                      food['quanty'],
                                      food['banner'],
                                      food['tag1'].toString(),
                                      food['tag2'].toString()),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteFood(food.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
