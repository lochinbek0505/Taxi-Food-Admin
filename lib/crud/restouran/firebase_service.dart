import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Restaurant CRUD
  Future<void> addRestaurant(String name, String location, String url) async {
    await _db.collection('restaurants').doc(name).set({
      'name': name,
      'location': location,
      'banner': url,
    });
  }

  Future<List<Map<String, dynamic>>> getRestaurants() async {
    var restaurantsSnapshot = await _db.collection('restaurants').get();
    return restaurantsSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'location': doc['location'],
              'banner': doc['banner'],
            })
        .toList();
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    await _db.collection('restaurants').doc(restaurantId).delete();
  }

  // Food Type CRUD
  Future<void> addFoodType(String restaurantId, String type) async {
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .doc(type)
        .set({
      'type': type,
    });
  }

  Future<List<Map<String, dynamic>>> getFoodTypes(String restaurantId) async {
    var foodTypesSnapshot = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .get();
    return foodTypesSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'type': doc['type'],
            })
        .toList();
  }

  Future<void> deleteFoodType(String restaurantId, String foodTypeId) async {
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .doc(foodTypeId)
        .delete();
  }

  // Food CRUD
  Future<void> addFood(String restaurantId, String foodTypeId, String name,
      double price, String description) async {
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .doc(foodTypeId)
        .collection('foods')
        .doc(name)
        .set({
      'name': name,
      'price': price,
      'description': description,
    });
  }

  Future<List<Map<String, dynamic>>> getFoods(
      String restaurantId, String foodTypeId) async {
    var foodsSnapshot = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .doc(foodTypeId)
        .collection('foods')
        .get();
    return foodsSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'price': doc['price'],
              'description': doc['description'],
            })
        .toList();
  }

  Future<void> deleteFood(
      String restaurantId, String foodTypeId, String foodId) async {
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('types_of_food')
        .doc(foodTypeId)
        .collection('foods')
        .doc(foodId)
        .delete();
  }
}
