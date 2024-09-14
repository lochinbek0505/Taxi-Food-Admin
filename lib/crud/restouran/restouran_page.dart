import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

import 'menu_page.dart';
// import 'food_type_page.dart'; // Import the food type page

class RestaurantPage extends StatefulWidget {
  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  File? _bannerImage;
  Uint8List? _webImage; // To hold the image in web format (Uint8List)
  String? _bannerImageUrl;

  String gbImg = '';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  Future<void> addRestaurant(
    String name,
    String description,
    String lenght,
    String location,
  ) async {
    await firestore.collection('restaurants').doc(name).set({
      'name': name,
      'location': location,
      'banner': _bannerImageUrl,
      'lenght': lenght,
      'description': description,
      'rate': '0.0',
      'rate_count': '0',
    });
    _bannerImageUrl = "";
  }

  void addRestouran(context) {
    final TextEditingController restaurantNameController =
        TextEditingController();
    final TextEditingController restaurantLocationController =
        TextEditingController();
    final TextEditingController description = TextEditingController();
    final TextEditingController lenght = TextEditingController();
    final TextEditingController rate = TextEditingController();
    final TextEditingController rate_count = TextEditingController();

    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return AlertDialog(
          title: Text("Add Restouran"),
          insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
          content: Center(
            child: SingleChildScrollView(
              child: Column(children: [
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
                    iconAlignment: IconAlignment.start,
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
                      controller: restaurantNameController,
                      decoration: InputDecoration(
                        labelText: 'Restaurant Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 50),
                  child: TextField(
                    controller: restaurantLocationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
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
                    controller: description,
                    decoration: InputDecoration(
                      labelText: 'Description',
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
                    controller: lenght,
                    decoration: InputDecoration(
                      labelText: 'Lenght',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
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
                    onPressed: () {
                      if (restaurantLocationController.text.isNotEmpty &&
                          restaurantNameController.text.isNotEmpty &&
                          lenght.text.isNotEmpty &&
                          description.text.isNotEmpty &&
                          _bannerImageUrl!.isNotEmpty) {
                        addRestaurant(
                            restaurantNameController.text,
                            description.text,
                            lenght.text,
                            restaurantLocationController.text);

                        restaurantNameController.clear();
                        restaurantLocationController.clear();
                        description.clear();
                        lenght.clear();
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all fields !'),
                          ),
                        );
                      }
                    },
                    iconAlignment: IconAlignment.start,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        "ADD RESTOURAN",
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
      },
    );
  }

  void _editRestaurant(context, String id, String name, String location,
      String description2, String lenght2, String img) {
    final TextEditingController restaurantNameController =
        TextEditingController();
    final TextEditingController restaurantLocationController =
        TextEditingController();
    final TextEditingController description = TextEditingController();
    final TextEditingController lenght = TextEditingController();
    final TextEditingController rate = TextEditingController();
    final TextEditingController rate_count = TextEditingController();

    gbImg = img;

    restaurantNameController.text = name;
    restaurantLocationController.text = location;
    description.text = description2;
    lenght.text = lenght2;

    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Restaurant"),
          content: SingleChildScrollView(
            child: Container(
              width: size.width,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: Image.network(
                      gbImg,
                      height: 150,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: TextField(
                        controller: restaurantNameController,
                        decoration: InputDecoration(
                          labelText: 'Restaurant Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: TextField(
                      controller: restaurantLocationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
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
                      controller: description,
                      decoration: InputDecoration(
                        labelText: 'Description',
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
                      controller: lenght,
                      decoration: InputDecoration(
                        labelText: 'Lenght',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
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
                        onPressed: () {
                          // 'banner': _bannerImageUrl,
                          // 'lenght': lenght,
                          // 'desctiption': description,

                          if (restaurantNameController.text.isNotEmpty &&
                              restaurantLocationController.text.isNotEmpty &&
                              description.text.isNotEmpty &&
                              lenght.text.isNotEmpty &&
                              _bannerImageUrl!.isNotEmpty) {
                            firestore.collection('restaurants').doc(id).update({
                              'name': restaurantNameController.text,
                              'location': restaurantLocationController.text,
                              'description': description.text,
                              'lenght': lenght.text,
                              'banner': _bannerImageUrl,
                            });
                            _bannerImageUrl = "";
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
          ),
          // actions: [
          //
          // ],
        );
      },
    );
  }

  void _deleteRestaurant(String id) {
    firestore.collection('restaurants').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Restaurants",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.grey[180],
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                width: size.width,
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.restaurant_menu),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 15),
                    child: Text(
                      "ADD RESTOURAN",
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
                  stream: firestore.collection('restaurants').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('Loading...'),
                      );
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var restaurant = snapshot.data!.docs[index];
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
                                leading: Image.network(
                                  restaurant['banner'],
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Text(
                                    restaurant['name'],
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Text(restaurant['location']),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FoodTypePage(
                                            restaurantId: restaurant.id)),
                                  );
                                },

                                // 'banner': _bannerImageUrl,
                                // 'lenght': lenght,
                                // 'desctiption': description,

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _editRestaurant(
                                          context,
                                          restaurant.id,
                                          restaurant['name'],
                                          restaurant['location'],
                                          restaurant['desctiption'],
                                          restaurant['lenght'],
                                          restaurant['banner']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () =>
                                          _deleteRestaurant(restaurant.id),
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
        ),
      ),
    );
  }
}
