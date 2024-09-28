import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

import 'exsist_cateogry.dart';
import 'food_page2.dart';

class MainMenuPage extends StatefulWidget {
  // MainMenuPage({required this.restaurantId});

  @override
  _FoodTypePageState createState() => _FoodTypePageState();
}

class _FoodTypePageState extends State<MainMenuPage> {
  final TextEditingController foodTypeController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  String? selectedRestaurantId;
  String? selectedRestaurantName =
      "Select Restaurant"; // Store selected restaurant name

  File? _bannerImage;
  Uint8List? _webImage; // To hold the image in web format (Uint8List)
  String? _bannerImageUrl = "";

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
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('main_restaurant_banners/$fileName');
    UploadTask uploadTask = storageRef.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    _bannerImageUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      gbImg = _bannerImageUrl!;
    });
    setState(() {});
  }

  Future<void> createMainDocument() async {
    print(_bannerImageUrl);
    try {
      await firestore
          .collection("main_restaurants")
          .doc(foodTypeController.text)
          .set({
        'banner': _bannerImageUrl,
        'type': foodTypeController.text,
      });

      foodTypeController.clear();

      _bannerImageUrl = "";
    } catch (e) {
      print('Error creating main document: $e');
    }
  }

  void addExistingFood(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Existing Foods"),
          content: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 50),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection('restaurants').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      List<DropdownMenuItem<String>> restaurantItems =
                          snapshot.data!.docs
                              .map((doc) => DropdownMenuItem(
                                    value: doc.id,
                                    child: Text(doc['name']),
                                  ))
                              .toList();

                      return DropdownButton<String>(
                        value: selectedRestaurantId,
                        hint: Text(
                          selectedRestaurantName!,
                          style: TextStyle(color: Colors.grey),
                        ),
                        // Dynamic hint
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: snapshot.data!.docs
                            .map((doc) => DropdownMenuItem(
                                  value: doc.id,
                                  child: Text(doc['name']),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedRestaurantId = value;
                            selectedRestaurantName = snapshot.data!.docs
                                    .firstWhere((doc) => doc.id == value)[
                                'name']; // Update selected restaurant name
                          });
                        },

                        isExpanded: true,
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 50),
                  child: TextField(
                    controller: newCategoryController,
                    decoration: InputDecoration(
                      labelText: 'Enter Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.symmetric(
                    horizontal: 50,
                  ),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        backgroundColor: Colors.indigoAccent,
                        iconColor: Colors.white),
                    onPressed: () {
                      if (selectedRestaurantId != null &&
                          newCategoryController.text.isNotEmpty) {
                        try {
                          addCategoryToExsistRestaurant(
                              selectedRestaurantId.toString());
                          print("CHECK ID IN CODE $selectedRestaurantId");
                        } catch (e) {
                          print(e);
                        }
                        Navigator.pop(context);
                        openAddFoodWindow();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please select a restaurant and enter a category')),
                        );
                      }
                    },
                    iconAlignment: IconAlignment.start,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 15),
                      child: Text(
                        "Add Menu",
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
        );
      },
    );
  }

  Future<void> addCategoryToRestaurant() async {
    await firestore
        .collection('main_restaurants')
        .doc(selectedRestaurantId)
        .collection('type_foods')
        .doc(newCategoryController.text)
        .set({
      'category_name': newCategoryController.text,
    });
  }

  Future<void> addCategoryToExsistRestaurant(String restoruanId) async {
    await firestore
        .collection("restaurants")
        .doc(selectedRestaurantId)
        .collection('types_of_food')
        .doc(newCategoryController.text)
        .set({
      'type': newCategoryController.text,
    });
  }

  void openAddFoodWindow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExsistCateogry(
          restoruanId: selectedRestaurantId!,
          foodTypeId: newCategoryController.text,
        ),
      ),
    );
  }

  // Future<void> addFoodType() async {
  //   await firestore
  //       .collection('restaurants')
  //       .doc(foodTypeController.text)
  //       .collection('types_of_food')
  //       .doc(foodTypeController.text)
  //       .set({
  //     'type': foodTypeController.text,
  //   });
  //   foodTypeController.clear();
  // }

  void addRestouran(context) {
    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text("Add Menu"),
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 100),
            content: Center(
              child: SingleChildScrollView(
                child: Column(children: [
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
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: TextField(
                      controller: foodTypeController,
                      decoration: InputDecoration(
                        labelText: 'Food menu *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    margin: EdgeInsets.symmetric(vertical: 15),
                    padding: EdgeInsets.symmetric(
                      horizontal: 50,
                    ),
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
                        if (foodTypeController.text.isNotEmpty &&
                            _bannerImageUrl != "") {
                          createMainDocument();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill in all fields!'),
                            ),
                          );
                        }
                      },
                      iconAlignment: IconAlignment.start,
                      label: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 15),
                        child: Text(
                          "Add  menu",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        });
      },
    );
  }

  void _editFoodType(String id, String type, img) {
    _webImage = null;
    _bannerImageUrl = img;
    foodTypeController.text = type;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            title: Text("Edit  Menu"),
            content: Container(
              height: 330,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      img = _bannerImageUrl;
                      setState(() {});
                    },
                    child: _webImage == null
                        ? Image.network(
                            img,
                            width: 150,
                          )
                        : Image.memory(
                            _webImage!, // Display the selected image
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25.0, horizontal: 15),
                    child: TextField(
                        controller: foodTypeController,
                        decoration: InputDecoration(
                          labelText: 'Edit food  menu *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        )),
                  ),
                  Container(
                    width: 300,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "Save",
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
                        if (_bannerImageUrl != "" &&
                            foodTypeController.text.isNotEmpty) {
                          firestore
                              .collection('main_restaurants')
                              .doc(
                                id,
                              )
                              .update({
                            'banner': _bannerImageUrl,
                            'type': foodTypeController.text,
                          });
                          foodTypeController.clear();
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
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _deleteFoodType(String id) {
    firestore.collection('main_restaurants').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Menus",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.grey[180],
      body: Column(
        children: [
          SizedBox(
            height: 35,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  backgroundColor: Colors.indigoAccent,
                  iconColor: Colors.white),
              onPressed: () {
                addRestouran(context);
              },
              iconAlignment: IconAlignment.start,
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  "Add Category",
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
              stream: firestore.collection('main_restaurants').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text('Loading...');
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var foodType = snapshot.data!.docs[index];
                    return Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      height: 80,
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                          horizontal: 50,
                        ),
                        child: Center(
                          child: ListTile(
                            leading: Image.network(
                              foodType['banner'],
                            ),
                            title: Text(foodType['type']),
                            onTap: () {
                              print("OnClick");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FoodPage2(
                                          foodTypeId: foodType.id,
                                          name: foodType['type'],
                                        )),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editFoodType(foodType.id,
                                      foodType['type'], foodType['banner']),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteFoodType(foodType.id),
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
