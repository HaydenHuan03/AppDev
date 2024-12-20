import 'package:cloud_firestore/cloud_firestore.dart';

// Rent_Item list
class RentItem {
  final String name;
  final String price;
  final String category;
  final String? id;
  final int selectedImageIndex;
  final Map<String, String> rentItemImages = {
    'Flex GMP': 'images/Renting/Flex_Racquet.jpeg',
    'Gopher Alpha': 'images/Renting/Gopher_Racquet.jpeg',
    'Maxbolt Bob': 'images/Renting/Maxbolt_Racquet.jpeg',
    'Victor Success': 'images/Renting/Victor_Racquet.jpeg',
    'Mizuno Katana': 'images/Renting/Mizuno_Racquet.jpeg',
  };

  RentItem({
    required this.name,
    required this.price,
    required this.category,
    this.selectedImageIndex = 0,
    this.id,
  });

  // Convert Firestore document to Rent Item object
  factory RentItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RentItem(
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

  factory RentItem.fromMap(Map<String, dynamic> map) {
    return RentItem(
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      category: map['category'],
    );
  }

  // Convert Rent Item object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }
}
