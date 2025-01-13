import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rent_item_data.dart';

class RentalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return {
            'userId': user.uid,
            'userName': userDoc.data()?['displayName'] ?? 'Unknown User',
            'userEmail': user.email,
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> createRental({
    required String rentalNumber,
    required String name,
    required String email,
    required String idNumber,
    required double price,
    required RentItem rentItem,
    required bool returnItem,
    required String userId,
  }) async {
    try {
      final userData = await _getCurrentUserData();
      if (userData == null) {
        throw Exception('User data not found');
      }
      // Prepare rental details
      Map<String, dynamic> rentalData = {
        'userId': userId,
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
