import 'package:cloud_firestore/cloud_firestore.dart';
import 'rent_item_data.dart';

class RentalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRental({
    required String rentalNumber,
    required String name,
    required String email,
    required String idNumber,
    required double price,
    required RentItem rentItem,
    required bool returnItem,
  }) async {
    try {
      // Prepare rental details
      Map<String, dynamic> rentalData = {
        'rentalNumber': rentalNumber,
        'name': name,
        'email': email,
        'matricNum/staffID': idNumber,
        'price': 'RM ${price.toStringAsFixed(2)}',
        'rentDate': FieldValue.serverTimestamp(),
        'items': rentItem.name,
        'returnItem': returnItem,
      };

      // Get the current number of rental and use it to generate a sequential document name
      int rentalCount = await _getRentalCount();
      String documentName = 'rental${rentalCount + 1}';

      // Add order to Firestore using the custom document name
      await _firestore.collection('rental').doc(documentName).set(rentalData);
    } catch (e) {
      print('Error creating rental: $e');
      rethrow;
    }
  }

  Future<int> _getRentalCount() async {
    QuerySnapshot snapshot = await _firestore.collection('rental').get();
    return snapshot.docs.length;
  }
}
