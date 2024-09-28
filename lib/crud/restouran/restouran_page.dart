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
  Uint8List? _webImage2; // To hold the image in web format (Uint8List)
  Uint8List? _webImage3; // To hold the image in web format (Uint8List)

  String? _bannerImageUrl;
  String? _bannerImageUrl2;
  String? _bannerImageUrl3;

  String gbImg = '';
  String gbImg2 = '';
  String gbImg3 = '';

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _pickImage(int count) async {
    switch (count) {
      case 1:
        {
          try {
            Uint8List? result = await ImagePickerWeb.getImageAsBytes();

            if (result != null) {
              setState(() {
                _webImage = result; // Get the image in bytes
              });
              await _uploadImageToFirebaseWeb(
                  _webImage!,
                  "Restouran_${DateTime.now().millisecondsSinceEpoch}",
                  1); // Upload web image
            }
          } catch (e) {
            print("Error picking image: $e");
          }
        }
      case 2:
        {
          try {
            Uint8List? result = await ImagePickerWeb.getImageAsBytes();

            if (result != null) {
              setState(() {
                _webImage2 = result; // Get the image in bytes
              });
              await _uploadImageToFirebaseWeb(
                  _webImage2!,
                  "Restouran_${DateTime.now().millisecondsSinceEpoch}",
                  2); // Upload web image
            }
          } catch (e) {
            print("Error picking image: $e");
          }
        }
      case 3:
        {
          try {
            Uint8List? result = await ImagePickerWeb.getImageAsBytes();

            if (result != null) {
              setState(() {
                _webImage3 = result; // Get the image in bytes
              });
              await _uploadImageToFirebaseWeb(
                  _webImage3!,
                  "Restouran_${DateTime.now().millisecondsSinceEpoch}",
                  3); // Upload web image
            }
          } catch (e) {
            print("Error picking image: $e");
          }
        }
    }
  }

  Future<void> _uploadImageToFirebaseWeb(
      Uint8List imageBytes, String fileName, int count) async {
    switch (count) {
      case 1:
        {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('restaurant_banners/$fileName');
          UploadTask uploadTask = storageRef.putData(imageBytes);
          TaskSnapshot snapshot = await uploadTask;
          _bannerImageUrl = await snapshot.ref.getDownloadURL();
          setState(() {
            gbImg = _bannerImageUrl!;
          });
          setState(() {});
        }
      case 2:
        {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('restaurant_banners/$fileName');
          UploadTask uploadTask = storageRef.putData(imageBytes);
          TaskSnapshot snapshot = await uploadTask;
          _bannerImageUrl2 = await snapshot.ref.getDownloadURL();
          setState(() {
            gbImg2 = _bannerImageUrl2!;
          });
          setState(() {});
        }
      case 3:
        {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('restaurant_banners/$fileName');
          UploadTask uploadTask = storageRef.putData(imageBytes);
          TaskSnapshot snapshot = await uploadTask;
          _bannerImageUrl3 = await snapshot.ref.getDownloadURL();
          setState(() {
            gbImg3 = _bannerImageUrl3!;
          });
          setState(() {});
        }
    }
  }

  Future<void> addRestaurant(
    String name,
    String description,
    String location,
    String latitude,
    String longtitude,
    String rate,
    String rate_count,
  ) async {
    await firestore.collection('restaurants').doc(name).set({
      'name': name,
      'location': location,
      'banner1': _bannerImageUrl,
      'banner2': _bannerImageUrl2,
      'banner3': _bannerImageUrl3,
      'latitude': latitude,
      'longtitude': longtitude,
      'description': description,
      'dictance': 0,
      'rate': rate.isNotEmpty ? rate : "0.0",
      'rate_count': rate_count.isNotEmpty ? rate_count : "0",
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
    final TextEditingController latitute = TextEditingController();
    final TextEditingController longtute = TextEditingController();
    final TextEditingController starController = TextEditingController();
    final TextEditingController noCountController = TextEditingController();

    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text("Add Restouran"),
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            content: Center(
              child: SingleChildScrollView(
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () async {
                            await _pickImage(1);
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () async {
                            await _pickImage(2);
                            setState(
                                () {}); // Refresh the UI to show the selected image
                          },
                          child: _webImage2 == null
                              ? Icon(
                                  Icons.image,
                                  size: 150,
                                )
                              : Image.memory(
                                  _webImage2!, // Display the selected image
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () async {
                            await _pickImage(3);
                            setState(
                                () {}); // Refresh the UI to show the selected image
                          },
                          child: _webImage3 == null
                              ? Icon(
                                  Icons.image,
                                  size: 150,
                                )
                              : Image.memory(
                                  _webImage3!, // Display the selected image
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: TextField(
                        controller: restaurantNameController,
                        decoration: InputDecoration(
                          labelText: 'Restaurant Name *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 50),
                    child: TextField(
                      controller: description,
                      decoration: InputDecoration(
                        labelText: 'Description *',
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
                            controller: starController,
                            decoration: InputDecoration(
                              labelText: 'Star Rating (only number)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: size.width / 2.8,
                          child: TextField(
                            controller: noCountController,
                            decoration: InputDecoration(
                              labelText: 'No. of people (only number)',
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
                      controller: restaurantLocationController,
                      decoration: InputDecoration(
                        labelText: 'Location *',
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
                            controller: latitute,
                            decoration: InputDecoration(
                              labelText: 'Latitude (only number) *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: size.width / 2.8,
                          child: TextField(
                            controller: longtute,
                            decoration: InputDecoration(
                              labelText: 'Longitude (only number) *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
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
                            latitute.text.isNotEmpty &&
                            longtute.text.isNotEmpty &&
                            description.text.isNotEmpty &&
                            _bannerImageUrl!.isNotEmpty &&
                            _bannerImageUrl2!.isNotEmpty &&
                            _bannerImageUrl3!.isNotEmpty) {
                          try {
                            addRestaurant(
                              restaurantNameController.text,
                              description.text,
                              restaurantLocationController.text,
                              latitute.text,
                              longtute.text,
                              starController.text,
                              noCountController.text,
                            );
                          } catch (e) {
                            print(e);
                          }
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
        });
      },
    );
  }

  void _editRestaurant(
      context,
      String id,
      String name,
      String location,
      String description2,
      String latitude,
      String longitude,
      String rate,
      String count,
      String img1,
      String img2,
      String img3) {
    _webImage = null;
    _webImage2 = null;
    _webImage3 = null;
    final TextEditingController restaurantNameController =
        TextEditingController();
    final TextEditingController restaurantLocationController =
        TextEditingController();
    final TextEditingController description = TextEditingController();
    final TextEditingController lenght = TextEditingController();

    final TextEditingController latitute = TextEditingController();
    final TextEditingController longtute = TextEditingController();

    final TextEditingController starController = TextEditingController();
    final TextEditingController noCountController = TextEditingController();

    gbImg = img1;
    gbImg2 = img2;
    gbImg3 = img3;
    restaurantNameController.text = name;
    restaurantLocationController.text = location;
    description.text = description2;
    latitute.text = latitude;
    longtute.text = longitude;
    starController.text = rate;
    noCountController.text = count;
    _bannerImageUrl = img1;
    _bannerImageUrl2 = img2;
    _bannerImageUrl3 = img3;
    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text("Edit Restaurant"),
            content: SingleChildScrollView(
              child: Container(
                width: size.width,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GestureDetector(
                            onTap: () async {
                              _bannerImageUrl = "";
                              await _pickImage(1);

                              setState(
                                  () {}); // Refresh the UI to show the selected image
                            },
                            child: _webImage == null
                                ? Image.network(
                                    gbImg,
                                    width: 150,
                                  )
                                : Image.memory(
                                    _webImage!, // Display the selected image
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GestureDetector(
                            onTap: () async {
                              _bannerImageUrl2 = "";

                              await _pickImage(2);
                              setState(
                                  () {}); // Refresh the UI to show the selected image
                            },
                            child: _webImage2 == null
                                ? Image.network(
                                    gbImg2,
                                    width: 150,
                                  )
                                : Image.memory(
                                    _webImage2!, // Display the selected image
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GestureDetector(
                            onTap: () async {
                              _bannerImageUrl3 = "";

                              await _pickImage(3);
                              setState(
                                  () {}); // Refresh the UI to show the selected image
                            },
                            child: _webImage3 == null
                                ? Image.network(
                                    gbImg3,
                                    width: 150,
                                  )
                                : Image.memory(
                                    _webImage3!, // Display the selected image
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 50),
                      child: TextField(
                          controller: restaurantNameController,
                          decoration: InputDecoration(
                            labelText: 'Restaurant Name *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 50),
                      child: TextField(
                        controller: description,
                        decoration: InputDecoration(
                          labelText: 'Description *',
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
                              controller: starController,
                              decoration: InputDecoration(
                                labelText: 'Star Rating (only number)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width / 2.8,
                            child: TextField(
                              controller: noCountController,
                              decoration: InputDecoration(
                                labelText: 'No. of people (only number)',
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
                        controller: restaurantLocationController,
                        decoration: InputDecoration(
                          labelText: 'Location *',
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
                              controller: latitute,
                              decoration: InputDecoration(
                                labelText: 'Latitude (only number) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width / 2.8,
                            child: TextField(
                              controller: longtute,
                              decoration: InputDecoration(
                                labelText: 'Longitude (only number) *',
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
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
                                latitute.text.isNotEmpty &&
                                longtute.text.isNotEmpty &&
                                _bannerImageUrl!.isNotEmpty &&
                                _bannerImageUrl2!.isNotEmpty &&
                                _bannerImageUrl3!.isNotEmpty) {
                              firestore
                                  .collection('restaurants')
                                  .doc(id)
                                  .update({
                                'name': restaurantNameController.text,
                                'location': restaurantLocationController.text,
                                'description': description.text,
                                'latitude': latitute.text,
                                'longtitude': longtute.text,
                                'rate': starController.text.isNotEmpty
                                    ? starController.text
                                    : "0.0",
                                'rate_count': noCountController.text.isNotEmpty
                                    ? noCountController.text
                                    : "0",
                                'banner1': _bannerImageUrl,
                                'banner2': _bannerImageUrl2,
                                'banner3': _bannerImageUrl3,
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
        });
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
                                  restaurant['banner1'],
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
                                              restaurantId: restaurant.id,
                                              name: restaurant['name'],
                                            )),
                                  );
                                },

                                // 'banner': _bannerImageUrl,
                                // 'lenght': lenght,
                                // 'desctiption': description,

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //
                                    // 'latitude': latitute.text,
                                    // 'longtitude':longtute.text

                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _editRestaurant(
                                        context,
                                        restaurant.id,
                                        restaurant['name'],
                                        restaurant['location'],
                                        restaurant['description'],
                                        restaurant['latitude'],
                                        restaurant['longtitude'],
                                        restaurant['rate'],
                                        restaurant['rate_count'],
                                        restaurant['banner1'],
                                        restaurant['banner2'],
                                        restaurant['banner3'],
                                      ),
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
