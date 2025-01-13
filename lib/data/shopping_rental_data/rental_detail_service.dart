import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to fetch all rental detail based on email
  Future<List<Map<String, dynamic>>> fetchRentalNumbersByUserId() async {
    List<Map<String, dynamic>> rental = [];

    try {
      final User? currentUser = _auth.currentUser;
      final String userId = currentUser?.uid ?? '';
      // Reference to 'rental' collection
      CollectionReference rentalRef = _firestore.collection('rental');

      // Query all documents where email matches
      QuerySnapshot querySnapshot = await rentalRef.get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        if (data['userId'] == userId) {
          // Add rentalNumber, rentDate and returnItem to the list
          rental.add({
            'rentalNumber': data['rentalNumber'],
            'rentDate': data['rentDate'],
            'returnItem': data['returnItem'],
          });
        }
      }
    } catch (e) {
      print('Error fetching rental: $e');
    }

    return rental;
  }
}
