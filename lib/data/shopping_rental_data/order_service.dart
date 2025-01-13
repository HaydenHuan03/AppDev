import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_data.dart';

class OrderService {
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

  Future<void> createOrder({
    required String orderNumber,
    required String name,
    required String email,
    required String idNumber,
    required double totalPrice,
    required List<Product> cartItems,
    required bool orderCompleted,
    required String userId,
  }) async {
    try {
      final userData = await _getCurrentUserData();
      if (userData == null) {
        throw Exception('User data not found');
      }
      // Prepare order details
      Map<String, dynamic> orderData = {
        'userId': userId,
        'orderNumber': orderNumber,
        'name': name,
        'email': email,
        'matricNum/staffID': idNumber,
        'totalPrice': 'RM ${totalPrice.toStringAsFixed(2)}',
        'orderDate': FieldValue.serverTimestamp(),
        'items': cartItems
            .map((product) => {
                  'name': product.name,
                  'price': product.price,
                  'category': product.category,
                })
            .toList(),
        'orderCompleted': orderCompleted,
      };

      // Get the current number of orders and use it to generate a sequential document name
      int orderCount = await _getOrderCount();
      String documentName = 'order${orderCount + 1}';

      // Add order to Firestore using the custom document name
      await _firestore.collection('orders').doc(documentName).set(orderData);
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<int> _getOrderCount() async {
    QuerySnapshot snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.length;
  }
}
