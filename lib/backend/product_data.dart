import 'package:cloud_firestore/cloud_firestore.dart';

// Products list
class Product {
  final String name;
  final String price;
  final String category;
  final String? id;
  final int selectedImageIndex;
  final Map<String, String> productImages = {
    'Yonex Lightning': 'images/racquet/Yonex_Racquet.jpeg',
    'Li-Ning Ultra': 'images/racquet/Li_Ning_Racquet.jpeg',
    'Fleet FarLight': 'images/racquet/Fleet_Racquet.jpeg',
    'Apacs CP3': 'images/racquet/Apacs_Racquet.jpeg',
    'Yonex AS3': 'images/Shuttlecock/Yonex_Shuttlecock.jpeg',
    'Li-Ning Pro': 'images/Shuttlecock/Li_Ning_Shuttlecock.jpeg',
    'Fleet SU7': 'images/Shuttlecock/Fleet_Shuttlecock.jpeg',
    'Apacs JPX': 'images/Shuttlecock/Apacs_Shuttlecock.jpeg',
    'Sports Tee Red': 'images/Shirt/Red_Sport_Shirt.jpeg',
    'Sports Tee Blue': 'images/Shirt/Blue_Sport_Shirt.jpeg',
    'Sports Tee Black': 'images/Shirt/Black_Sport_Shirt.jpeg',
    'Sports Tee Yellow': 'images/Shirt/Yellow_Sport_Shirt.jpeg',
    'Bika': 'images/Snacks/Bika.jpeg',
    'Mr Potato': 'images/Snacks/Mr_Potato.jpeg',
    'Super Ring': 'images/Snacks/Super_Ring.jpeg',
    'Coca-Cola': 'images/Drinks/Cola.jpeg',
    '100 Plus': 'images/Drinks/100plus.jpeg',
    'Mineral Water': 'images/Drinks/Mineral_Water.jpeg',
  };

  Product({
    required this.name,
    required this.price,
    required this.category,
    this.selectedImageIndex = 0,
    this.id,
  });

  // Convert Firestore document to Product object
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      category: map['category'],
    );
  }

  // Convert Product object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }
}
