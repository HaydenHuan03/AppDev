import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch equipment data from Firestore based on category and discount
  Future<List<Map<String, dynamic>>> fetchEquipment(String category, String discount) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('equipment')
          .where('category', isEqualTo: category)
          .where('discount', isEqualTo: discount)
          .get();

      // Return a list of equipment items as maps
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['price'] is int) {
          data['price'] = (data['price'] as int).toDouble();
        }
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching equipment data: $e");
      return [];
    }
  }

  // Calculate discounted price
  double calculateDiscountedPrice(double price, String discount) {
    if (discount.contains('%')) {
      final percentage = double.parse(discount.replaceAll('%', '')) / 100;
      return price - (price * percentage);
    } else if (discount.contains('RM')) {
      final amount = double.parse(discount.replaceAll('RM', ''));
      return price - amount;
    }
    return price;
  }
}

