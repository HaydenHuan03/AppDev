import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch all orders based on matricNum/staffID
  Future<List<Map<String, dynamic>>> fetchOrderNumbersByMatricID(
      String userMatricNumStaffID) async {
    List<Map<String, dynamic>> orders = [];

    try {
      // Reference to 'orders' collection
      CollectionReference ordersRef = _firestore.collection('orders');

      // Query all documents where matricNum/staffID matches
      QuerySnapshot querySnapshot = await ordersRef.get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        if (data['matricNum/staffID'] == userMatricNumStaffID) {
          // Add orderNumber, totalPrice and orderCompleted to the list
          orders.add({
            'orderNumber': data['orderNumber'],
            'totalPrice': data['totalPrice'],
            'orderCompleted': data['orderCompleted'],
          });
        }
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }

    return orders;
  }
}
