import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch all orders based on email
  Future<List<Map<String, dynamic>>> fetchOrderNumbersByEmail(
      String userEmail) async {
    List<Map<String, dynamic>> orders = [];

    try {
      // Reference to 'orders' collection
      CollectionReference ordersRef = _firestore.collection('orders');

      // Query all documents where email matches
      QuerySnapshot querySnapshot = await ordersRef.get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        if (data['email'] == userEmail) {
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
