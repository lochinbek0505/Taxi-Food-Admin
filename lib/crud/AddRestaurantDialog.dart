import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class AddRestaurantDialog extends StatefulWidget {
  final String restaurantId;
  final String foodTypeId;

  AddRestaurantDialog({required this.restaurantId, required this.foodTypeId});

  @override
  _AddRestaurantDialogState createState() => _AddRestaurantDialogState();
}

class _AddRestaurantDialogState extends State<AddRestaurantDialog> {
  // Define state variables
  bool isVeg = false;
  TextEditingController foodNameController = TextEditingController();
  TextEditingController foodPriceController = TextEditingController();
  TextEditingController foodDescriptionController = TextEditingController();
  String? _bannerImageUrl = ""; // Set this as nullable if needed
  Size size = Size(300, 300); // Sample size, modify based on your actual layout
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  File? _bannerImage;
  Uint8List? _webImage; // To hold the image in web format (Uint8List)
  // String? _bannerImageUrl;

  String gbImg = '';

  // Dummy methods for image picker and adding food

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

  Future<void> addFood(String name, String price, String description) async {
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
      'name': name,
      'price': price,
      'description': description,
      'rate': '0.0',
      'rate_count': 0,
      'is_veg': isVeg,
    });

    // Clear fields
    foodNameController.clear();
    foodPriceController.clear();
    foodDescriptionController.clear();
    setState(() {
      _bannerImage = null;
      _bannerImageUrl = null;
      isVeg = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                child: TextField(
                  controller: foodNameController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                child: TextField(
                  controller: foodPriceController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                child: TextField(
                  controller: foodDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Is Veg',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Switch(
                      value: isVeg,
                      onChanged: (bool value) {
                        setState(() {
                          isVeg = value; // Update the state
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
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

                      addFood(foodNameController.text, foodPriceController.text,
                          foodDescriptionController.text);

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
  }
}
