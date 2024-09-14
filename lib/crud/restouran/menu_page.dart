import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'food_page.dart'; // Import the food page

class FoodTypePage extends StatefulWidget {
  final String restaurantId;

  FoodTypePage({required this.restaurantId});

  @override
  _FoodTypePageState createState() => _FoodTypePageState();
}

class _FoodTypePageState extends State<FoodTypePage> {
  final TextEditingController foodTypeController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addFoodType() async {
    await firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('types_of_food')
        .doc(foodTypeController.text)
        .set({
      'type': foodTypeController.text,
    });
    foodTypeController.clear();
  }

  void _editFoodType(String id, String type) {
    foodTypeController.text = type;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Food Type"),
          content: Container(
            width: 300,
            height: 150,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 25.0, horizontal: 15),
                  child: TextField(
                      controller: foodTypeController,
                      decoration: InputDecoration(
                        labelText: 'Edit food  type',
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
                      firestore
                          .collection('restaurants')
                          .doc(widget.restaurantId)
                          .collection('types_of_food')
                          .doc(id)
                          .update({
                        'type': foodTypeController.text,
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteFoodType(String id) {
    firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('types_of_food')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Food Types",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.grey[180],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
            child: TextField(
              controller: foodTypeController,
              decoration: InputDecoration(
                labelText: 'Food type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 55,
            margin: EdgeInsets.symmetric(vertical: 15),
            padding: EdgeInsets.symmetric(
              horizontal: 50,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: ElevatedButton.icon(
              icon: Icon(Icons.save),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  backgroundColor: Colors.indigoAccent,
                  iconColor: Colors.white),
              onPressed: addFoodType,
              iconAlignment: IconAlignment.start,
              label: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                child: Text(
                  "Add food type",
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
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text('Loading...');
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var foodType = snapshot.data!.docs[index];
                    return Card(
                      elevation: 4,
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      child: Center(
                        child: ListTile(
                          title: Text(foodType['type']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FoodPage(
                                        restaurantId: widget.restaurantId,
                                        foodTypeId: foodType.id,
                                      )),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editFoodType(
                                    foodType.id, foodType['type']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteFoodType(foodType.id),
                              ),
                            ],
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
