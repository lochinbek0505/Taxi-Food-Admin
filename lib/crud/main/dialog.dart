import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectFoodDialog extends StatefulWidget {
  final String foodTypeId;

  const SelectFoodDialog({required this.foodTypeId});

  @override
  _SelectFoodDialogState createState() => _SelectFoodDialogState();
}

class _SelectFoodDialogState extends State<SelectFoodDialog> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? selectedRestaurant;
  String? selectedFood;
  Map<String, dynamic>? selectedFoodDetails;

  List<String> restaurants = [];
  List<String> foods = [];

  bool isRestaurantSelected = false;
  bool isLoadingFoods = false; // New: Loading indicator for foods

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  // Fetch the list of restaurants from Firestore
  Future<void> fetchRestaurants() async {
    QuerySnapshot querySnapshot =
        await firestore.collection('restaurants').get();
    setState(() {
      restaurants = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Fetch the list of foods by looping through all types_of_food for the selected restaurant
  Future<void> fetchFoods(String restaurantId) async {
    setState(() {
      isLoadingFoods = true; // Show loading indicator
      foods.clear(); // Clear previous foods
    });

    List<String> foodList = [];

    // Fetch all types_of_food sub-collections
    QuerySnapshot typesSnapshot = await firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .get();

    // Loop through each food type and get the foods within
    for (QueryDocumentSnapshot typeDoc in typesSnapshot.docs) {
      QuerySnapshot foodsSnapshot = await firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('types_of_food')
          .doc(typeDoc.id)
          .collection('foods')
          .get();

      // Add each food to the food list
      for (QueryDocumentSnapshot foodDoc in foodsSnapshot.docs) {
        foodList.add(foodDoc.id); // Collect the food document ID
      }
    }

    setState(() {
      foods = foodList; // Update the food list state
      isLoadingFoods = false; // Hide loading indicator
    });
  }

  // Fetch the selected food's details from Firestore
  Future<void> fetchFoodDetails(String restaurantId, String foodName) async {
    QuerySnapshot typesSnapshot = await firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .get();

    // Loop through each food type and fetch the food details
    for (QueryDocumentSnapshot typeDoc in typesSnapshot.docs) {
      DocumentSnapshot foodSnapshot = await firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('types_of_food')
          .doc(typeDoc.id)
          .collection('foods')
          .doc(foodName)
          .get();

      if (foodSnapshot.exists) {
        setState(() {
          selectedFoodDetails = foodSnapshot.data() as Map<String, dynamic>?;
          try {
            print(selectedFoodDetails);
          } catch (e) {
            print("ERRORORORORO $e");
          }
        });
        break;
      }
    }
  }

  // Function to add the selected food to the Firestore database
  Future<void> addFoodToDatabase(String foodName) async {
    if (selectedFoodDetails != null) {
      await firestore
          .collection('main_restaurants')
          .doc(widget.foodTypeId)
          .collection('foods')
          .doc(foodName)
          .set({
        'banner': selectedFoodDetails?['banner'] ?? '', // Save the banner URL
        'name': selectedFoodDetails?['name'] ?? foodName.toString(),
        'price': selectedFoodDetails?['price'] ??
            '0.00', // Actual price from selected food
        'description':
            selectedFoodDetails?['description'] ?? '', // Actual description
        'rate': selectedFoodDetails?['rate'] ?? '0.0',
        'rate_count': selectedFoodDetails?['rate_count'] ?? 0,
        'cat_id': widget.foodTypeId,
        'veg': selectedFoodDetails?['veg'] ?? false, // Actual veg status
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Food"),
      content: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown for selecting restaurant
            Padding(
              padding: EdgeInsets.all(20),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Select Restaurant"),
                value: selectedRestaurant,
                onChanged: (value) {
                  setState(() {
                    selectedRestaurant = value;
                    isRestaurantSelected = true;
                    selectedFood = null; // Reset food selection
                    foods.clear(); // Clear foods list
                  });
                  fetchFoods(
                      value!); // Fetch foods after selecting the restaurant
                },
                items: restaurants.map((restaurant) {
                  return DropdownMenuItem<String>(
                    value: restaurant,
                    child: Text(restaurant),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // Show CircularProgressIndicator while loading foods
            if (isRestaurantSelected && isLoadingFoods)
              CircularProgressIndicator(), // Show loading indicator

            // Dropdown for selecting food
            if (isRestaurantSelected && !isLoadingFoods && foods.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(25),
                child: DropdownButton<String>(
                  hint: Text("Select Food"),
                  value: selectedFood,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedFood = value;
                    });
                    try {
                      fetchFoodDetails(selectedRestaurant!,
                          value!); // F// etch food details after selecting
                    } catch (e) {
                      print("SALOM EROR $e");
                    }
                  },
                  items: foods.map((food) {
                    return DropdownMenuItem<String>(
                      value: food,
                      child: Text(food),
                    );
                  }).toList(),
                ),
              ),

            // If no foods are available after loading
            if (isRestaurantSelected && !isLoadingFoods && foods.isEmpty)
              Text("No foods available"),
          ],
        ),
      ),
      actions: [
        Container(
          width: MediaQuery.of(context).size.width / 2.2,
          height: 50,
          margin: EdgeInsets.symmetric(vertical: 15),
          padding: EdgeInsets.symmetric(
            horizontal: 50,
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                backgroundColor: Colors.indigoAccent,
                iconColor: Colors.white),
            onPressed: () async {
              if (selectedRestaurant != null && selectedFood != null) {
                // Add the selected food to Firestore
                try {
                  await addFoodToDatabase(selectedFood!);
                } catch (e) {
                  print("Erorrr $e");
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Food added successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Please select both restaurant and food')),
                );
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
              child: Text(
                "Submit",
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
  }
}
