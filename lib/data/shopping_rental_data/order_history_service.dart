import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to fetch all orders based on email
  Future<List<Map<String, dynamic>>> fetchOrderNumbersByUserId() async {
    List<Map<String, dynamic>> orders = [];

    try {
      final User? currentUser = _auth.currentUser;
      final String userId = currentUser?.uid ?? '';
      // Reference to 'orders' collection
      CollectionReference ordersRef = _firestore.collection('orders');

      // Query all documents where email matches
      QuerySnapshot querySnapshot = await ordersRef.get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        if (data['userId'] == userId) {
          // Add orderNumber, totalPrice and orderCompleted to the list
          orders.add({
            'userId': userId,
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
