import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    try {
      return _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          // Get list of image paths for this product
          List<String> imagePaths = _getProductImagePaths(
              data['category'],
              data['name'],
              data['imageCount'] ?? 1 // Get number of images from Firebase
              );

          print(data);
          return Product(
            category: data['category'],
            name: data['name'],
            price: data['price'],
          );
        }).toList();
      });
    } catch (e) {
      print('Error in getProductsByCategory: $e');
      return Stream.value([]);
    }
  }

  // Add a new product
  Future<void> addProduct(Product product) {
    return _firestore.collection('products').add(product.toFirestore());
  }

  // Update a product
  Future<void> updateProduct(String id, Product product) {
    return _firestore
        .collection('products')
        .doc(id)
        .update(product.toFirestore());
  }

  // Delete a product
  Future<void> deleteProduct(String id) {
    return _firestore.collection('products').doc(id).delete();
  }
}

List<String> _getProductImagePaths(
    String category, String name, int imageCount) {
  String baseFileName = name.toLowerCase().replaceAll(' ', '_');
  List<String> paths = [];

  for (int i = 1; i <= imageCount; i++) {
    String fileName =
        imageCount == 1 ? '${baseFileName}.jpeg' : '${baseFileName}_$i.jpeg';

    switch (category) {
      case 'racquet':
        paths.add('images/racquet/$fileName.jpeg');
        break;
    }
  }
  return paths;
}
