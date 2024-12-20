import 'package:cloud_firestore/cloud_firestore.dart';

class RentalDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch all rental detail based on matricNum/staffID
  Future<List<Map<String, dynamic>>> fetchRentalNumbersByMatricID(
      String userMatricNumStaffID) async {
    List<Map<String, dynamic>> rental = [];

    try {
      // Reference to 'rental' collection
      CollectionReference rentalRef = _firestore.collection('rental');

      // Query all documents where matricNum/staffID matches
      QuerySnapshot querySnapshot = await rentalRef.get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        if (data['matricNum/staffID'] == userMatricNumStaffID) {
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
