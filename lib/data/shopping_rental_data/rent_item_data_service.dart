import 'package:cloud_firestore/cloud_firestore.dart';
import 'rent_item_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all rent items
  Stream<List<RentItem>> getRentItem() {
    return _firestore.collection('rent_products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RentItem.fromFirestore(doc)).toList());
  }

  // Get rent items by category
  Stream<List<RentItem>> getRentItemByCategory(String category) {
    try {
      return _firestore
          .collection('rent_products')
          .where('category', isEqualTo: category)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          // Get list of image paths for this rent item
          List<String> imagePaths = _getRentItemImagePaths(
              data['category'],
              data['name'],
              data['imageCount'] ?? 1 // Get number of images from Firebase
              );

          print(data);
          return RentItem(
            category: data['category'],
            name: data['name'],
            price: data['price'],
          );
        }).toList();
      });
    } catch (e) {
      print('Error in getRentItemByCategory: $e');
      return Stream.value([]);
    }
  }

  // Add a new rent item
  Future<void> addRentItem(RentItem item) {
    return _firestore.collection('rent_products').add(item.toFirestore());
  }

  // Update a rent item
  Future<void> updateRentItem(String id, RentItem item) {
    return _firestore
        .collection('rent_products')
        .doc(id)
        .update(item.toFirestore());
  }

  // Delete a rent item
  Future<void> deleteRentItem(String id) {
    return _firestore.collection('rent_products').doc(id).delete();
  }
}

List<String> _getRentItemImagePaths(
    String category, String name, int imageCount) {
  String baseFileName = name.toLowerCase().replaceAll(' ', '_');
  List<String> paths = [];

  for (int i = 1; i <= imageCount; i++) {
    String fileName =
        imageCount == 1 ? '${baseFileName}.jpeg' : '${baseFileName}_$i.jpeg';

    switch (category) {
      case 'rent':
        paths.add('images/rent/$fileName.jpeg');
        break;
    }
  }
  return paths;
}
