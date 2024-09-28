import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

import 'dialog.dart';

class FoodPage2 extends StatefulWidget {
  final String foodTypeId;

  final String name;

  FoodPage2({required this.foodTypeId, required this.name});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage2> {
  bool isVeg = false;
  final TextEditingController newCategoryController = TextEditingController();

// Initial selection - Veg selected by default

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  String? selectedRestaurantId;
  String? selectedRestaurantName =
      "Select Restaurant"; // Store selected restaurant name

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

  Future<void> addFood(String name, String price, String description,
      String star, int nomer, bool isVeg2, String img) async {
    // if (_bannerImage != null) {
    //   _bannerUrl = await uploadBanner(_webImage!);
    // }

    // print(
    //     "${widget.restaurantId}-----${widget.foodTypeId}---${name}____${_bannerImageUrl}");

    await firestore
        .collection('main_restaurants')
        .doc(widget.foodTypeId)
        .collection('foods')
        .doc(name)
        .set({
      'banner': img ?? '', // Save the banner URL
      'name': name.toString(),
      'price': price.toString(),
      'description': description.toString(),
      'rate': star.isNotEmpty ? star : '0.0',
      'rate_count': nomer != null ? nomer : 0,

      'cat_id': widget.foodTypeId,
      'veg': isVeg2,
    });

    await firestore.collection('main_foods').doc(name).set({
      'banner': img ?? '', // Save the banner URL
      'name': name.toString(),
      'price': price.toString(),
      'description': description.toString(),
      'rate': '0.0',
      'rate_count': 0,
      'cat_id': widget.foodTypeId,

      'veg': isVeg2,
    });

    setState(() {
      _bannerImageUrl = null;
      isVeg = false;
    });
  }

  List<bool> isSelected = [
    true,
    false,
  ];

  void addRestouran(context) {
    final TextEditingController foodNameController = TextEditingController();
    final TextEditingController foodPriceController = TextEditingController();
    final TextEditingController foodDescriptionController =
        TextEditingController();
    final TextEditingController starController = TextEditingController();
    final TextEditingController noCountController = TextEditingController();

    bool isVeg = false;
    var size = MediaQuery.of(context).size;
    List<bool> isSelected = [true, false]; // Default selection: Veg selected

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text("Add Food"),
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
                          vertical: 15, horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size.width / 2.8,
                            child: TextField(
                              controller: foodNameController,
                              decoration: InputDecoration(
                                labelText: 'Food Name *',
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
                                labelText: 'Food Price (only number) *',
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
                        controller: foodDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Food Description *',
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
                                labelText: 'No of People (only number)',
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return ToggleButtons(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 8.0),
                                child: Text('Veg'),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 8.0),
                                child: Text('Non Veg'),
                              ),
                            ],
                            isSelected: isSelected,
                            onPressed: (int index) {
                              setState(() {
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = i == index;
                                }
                                isVeg = isSelected[
                                    0]; // Update isVeg based on selection
                              });
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            selectedBorderColor: Colors.green,
                            selectedColor: Colors.white,
                            fillColor: Colors.green,
                            color: Colors.black,
                          );
                        },
                      ),
                    ),
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
                              foodDescriptionController.text.isNotEmpty &&
                              foodPriceController.text.isNotEmpty &&
                              starController.text.isNotEmpty &&
                              noCountController.text.isNotEmpty &&
                              _bannerImageUrl!.isNotEmpty) {
                            print(_bannerImageUrl);

                            addFood(
                                foodNameController.text,
                                foodPriceController.text,
                                foodDescriptionController.text,
                                starController.text,
                                noCountController.text.isNotEmpty
                                    ? int.parse(
                                        noCountController.text,
                                      )
                                    : 0,
                                isVeg,
                                // Pass whether it is Veg or Non Veg
                                _bannerImageUrl!);

                            foodNameController.clear();
                            foodDescriptionController.clear();
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
        });
      },
    );
  }

  /// Add Food Document to Firestore

  /// Edit Food Document
  void _editFood(String id, String name, String price, String description,
      bool isVeg, String banner, String rate, String rate_count) {
    _webImage = null;
    final TextEditingController foodNameController = TextEditingController();
    final TextEditingController foodPriceController = TextEditingController();
    final TextEditingController foodDescriptionController =
        TextEditingController();
    final TextEditingController starController = TextEditingController();
    final TextEditingController noCountController = TextEditingController();

    // bool isVeg = false;
    var size = MediaQuery.of(context).size;
    foodNameController.text = name;
    foodPriceController.text = price.toString();
    foodDescriptionController.text = description;
    starController.text = rate;
    noCountController.text = rate_count;
    _bannerImageUrl = banner;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            title: Text("Edit Food"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
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
                        vertical: 15, horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: size.width / 2.8,
                          child: TextField(
                            controller: foodNameController,
                            decoration: InputDecoration(
                              labelText: 'Food Name *',
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
                              labelText: 'Food Price (only number) *',
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
                      controller: foodDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Food Description *',
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
                              labelText: 'No of People (only number)',
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return ToggleButtons(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 8.0),
                              child: Text('Veg'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 8.0),
                              child: Text('Non Veg'),
                            ),
                          ],
                          isSelected: isSelected,
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < isSelected.length; i++) {
                                isSelected[i] = i == index;
                              }
                              isVeg = isSelected[
                                  0]; // Update isVeg based on selection
                            });
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          selectedBorderColor: Colors.green,
                          selectedColor: Colors.white,
                          fillColor: Colors.green,
                          color: Colors.black,
                        );
                      },
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
                          if (foodNameController.text.isNotEmpty &&
                              foodDescriptionController.text.isNotEmpty &&
                              foodPriceController.text.isNotEmpty &&
                              _bannerImageUrl!.isNotEmpty) {
                            // main_foods
                            firestore
                                .collection('main_restaurants')
                                .doc(widget.foodTypeId)
                                .collection('foods')
                                .doc(id)
                                .update({
                              'banner': _bannerImageUrl,
                              'name': foodNameController.text,
                              'price': foodPriceController.text,
                              'description': foodDescriptionController.text,
                              'rate': starController.text.isNotEmpty
                                  ? starController.text
                                  : rate,
                              'rate_count': noCountController.text.isNotEmpty
                                  ? int.parse(noCountController.text)
                                  : int.parse(rate_count),
                              'cat_id': widget.foodTypeId,
                              'veg': isVeg,
                            });

                            firestore.collection('main_foods').doc(id).update({
                              'banner': banner,
                              'name': foodNameController.text,
                              'price': foodPriceController.text,
                              'description': foodDescriptionController.text,
                              'rate': starController.text.isNotEmpty
                                  ? starController.text
                                  : rate,
                              'rate_count': noCountController.text.isNotEmpty
                                  ? int.parse(noCountController.text)
                                  : int.parse(rate_count),
                              'cat_id': widget.foodTypeId,
                              'veg': isVeg,
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
        });
      },
    );
  }

  /// Delete Food Document
  void _deleteFood(String id) {
    firestore
        .collection('main_restaurants')
        .doc(widget.foodTypeId)
        .collection('foods')
        .doc(id)
        .delete();
    firestore.collection('main_foods').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[180],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2.2,
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 15),
                    child: Text(
                      "Add food",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2.2,
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 50),
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SelectFoodDialog(foodTypeId: widget.foodTypeId);
                      },
                    );
                  },
                  iconAlignment: IconAlignment.start,
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "Add Exist Food",
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
          Expanded(
            child: StreamBuilder(
              stream: firestore
                  .collection('main_restaurants')
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
                                      food['veg'],
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
