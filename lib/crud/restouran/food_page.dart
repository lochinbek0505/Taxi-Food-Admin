import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class FoodPage extends StatefulWidget {
  final String restaurantId;
  final String foodTypeId;

  FoodPage({required this.restaurantId, required this.foodTypeId});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
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
        FirebaseStorage.instance.ref().child('restaurant_banners/$fileName');
    UploadTask uploadTask = storageRef.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    _bannerImageUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      gbImg = _bannerImageUrl!;
    });
    setState(() {});
  }

  Future<void> addFood(
      String name, String price, String description, bool isVeg2) async {
    // if (_bannerImage != null) {
    //   _bannerUrl = await uploadBanner(_webImage!);
    // }

    print(
        "${widget.restaurantId}-----${widget.foodTypeId}---${name}____${_bannerImageUrl}");

    await firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('types_of_food')
        .doc(widget.foodTypeId)
        .collection('foods')
        .doc(name)
        .set({
      'banner': _bannerImageUrl ?? '', // Save the banner URL
      'name': name.toString(),
      'price': price.toString(),
      'description': description.toString(),
      'rate': '0.0',
      'rate_count': 0,
      'is_veg': isVeg2,
    });

    setState(() {
      _bannerImage = null;
      _bannerImageUrl = null;
      isVeg = false;
    });
  }

  void addRestouran(context) {
    final TextEditingController foodNameController = TextEditingController();
    final TextEditingController foodPriceController = TextEditingController();
    final TextEditingController foodDescriptionController =
        TextEditingController();

    bool isVeg = false;
    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Restaurant"),
          insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
          content: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: size.width,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.image),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          backgroundColor: Colors.indigoAccent,
                          iconColor: Colors.white),
                      onPressed: _pickImage,
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "Banner image",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: TextField(
                      controller: foodNameController,
                      decoration: InputDecoration(
                        labelText: 'Food Name',
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
                      controller: foodPriceController,
                      decoration: InputDecoration(
                        labelText: 'Food Price',
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
                      controller: foodDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Food Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: StatefulBuilder(builder: (context, setState) {
                      return SwitchListTile(
                        title: Text('For Veg'),
                        value: isVeg,
                        onChanged: (bool value) {
                          setState(() {
                            isVeg = value;
                          });
                        },
                      );
                    }),
                  ),
                  Container(
                    width: size.width,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
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
                            foodDescriptionController.text.isNotEmpty &&
                            foodPriceController.text.isNotEmpty &&
                            _bannerImageUrl!.isNotEmpty) {
                          print(_bannerImageUrl);

                          addFood(
                              foodNameController.text,
                              foodPriceController.text,
                              foodDescriptionController.text,
                              isVeg);

                          foodNameController.clear();
                          foodDescriptionController.clear();
                          foodPriceController.clear();
                          _bannerImageUrl = "";
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
                          "ADD FOOD",
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
      },
    );
  }

  /// Add Food Document to Firestore

  /// Edit Food Document
  void _editFood(String id, String name, String price, String description,
      bool isVeg, String banner, String rate, String rate_count) {
    final TextEditingController foodNameController = TextEditingController();
    final TextEditingController foodPriceController = TextEditingController();
    final TextEditingController foodDescriptionController =
        TextEditingController();

    // bool isVeg = false;
    var size = MediaQuery.of(context).size;
    foodNameController.text = name;
    foodPriceController.text = price.toString();
    foodDescriptionController.text = description;
    _bannerImageUrl = banner;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Food"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: Image.network(
                    banner,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 50),
                  child: TextField(
                    controller: foodNameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
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
                    controller: foodPriceController,
                    decoration: InputDecoration(
                      labelText: 'Food Price',
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
                    controller: foodDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Food Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 50),
                  child: StatefulBuilder(builder: (context, setState) {
                    return SwitchListTile(
                      title: Text('For Veg'),
                      value: isVeg,
                      onChanged: (bool value) {
                        setState(() {
                          isVeg = value;
                        });
                      },
                    );
                  }),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: Container(
                    width: size.width,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
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
                      onPressed: () {
                        // 'banner': _bannerImageUrl,
                        // 'lenght': lenght,
                        // 'desctiption': description,
                        if (foodNameController.text.isNotEmpty &&
                            foodDescriptionController.text.isNotEmpty &&
                            foodPriceController.text.isNotEmpty &&
                            _bannerImageUrl!.isNotEmpty) {
                          firestore
                              .collection('restaurants')
                              .doc(widget.restaurantId)
                              .collection('types_of_food')
                              .doc(widget.foodTypeId)
                              .collection('foods')
                              .doc(id)
                              .update({
                            'banner': _bannerImageUrl,
                            'name': foodNameController.text,
                            'price': foodPriceController.text,
                            'description': foodDescriptionController.text,
                            'rate': rate,
                            'rate_count': rate_count,
                            'is_veg': isVeg,
                          });
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
      },
    );
  }

  /// Delete Food Document
  void _deleteFood(String id) {
    firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('types_of_food')
        .doc(widget.foodTypeId)
        .collection('foods')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[180],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Foods",
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
                  "ADD FOOD",
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
              stream: firestore
                  .collection('restaurants')
                  .doc(widget.restaurantId)
                  .collection('types_of_food')
                  .doc(widget.foodTypeId)
                  .collection('foods')
                  .snapshots(),
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
                                  onPressed: () => _editFood(
                                      food.id,
                                      food['name'],
                                      food['price'],
                                      food['description'],
                                      food['is_veg'],
                                      food['banner'],
                                      food['rate'].toString(),
                                      food['rate_count'].toString()),
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
