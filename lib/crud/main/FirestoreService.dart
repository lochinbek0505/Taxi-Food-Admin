import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE: Main Document
  Future<void> createMainDocument(
      String collectionName, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionName).doc(docId).set(data);
    } catch (e) {
      print('Error creating main document: $e');
    }
  }

  // READ: Main Document
  Future<Map<String, dynamic>?> readMainDocument(
      String collectionName, String docId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(collectionName).doc(docId).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error reading main document: $e');
      return null;
    }
  }

  // UPDATE: Main Document
  Future<void> updateMainDocument(String collectionName, String docId,
      Map<String, dynamic> updatedData) async {
    try {
      await _db.collection(collectionName).doc(docId).update(updatedData);
    } catch (e) {
      print('Error updating main document: $e');
    }
  }

  // DELETE: Main Document
  Future<void> deleteMainDocument(String collectionName, String docId) async {
    try {
      await _db.collection(collectionName).doc(docId).delete();
    } catch (e) {
      print('Error deleting main document: $e');
    }
  }

  // CREATE: Nested Document (Sub-Collection)
  Future<void> createNestedDocument(String parentCollection, String parentDocId,
      String childCollection, Map<String, dynamic> childData) async {
    try {
      await _db
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(childCollection)
          .add(childData);
    } catch (e) {
      print('Error creating nested document: $e');
    }
  }

  // READ: Nested Documents (Sub-Collection)
  Stream<List<Map<String, dynamic>>> readNestedDocuments(
      String parentCollection, String parentDocId, String childCollection) {
    return _db
        .collection(parentCollection)
        .doc(parentDocId)
        .collection(childCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  // UPDATE: Nested Document
  Future<void> updateNestedDocument(
      String parentCollection,
      String parentDocId,
      String childCollection,
      String childDocId,
      Map<String, dynamic> updatedData) async {
    try {
      await _db
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(childCollection)
          .doc(childDocId)
          .update(updatedData);
    } catch (e) {
      print('Error updating nested document: $e');
    }
  }

  // DELETE: Nested Document
  Future<void> deleteNestedDocument(String parentCollection, String parentDocId,
      String childCollection, String childDocId) async {
    try {
      await _db
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(childCollection)
          .doc(childDocId)
          .delete();
    } catch (e) {
      print('Error deleting nested document: $e');
    }
  }
}
