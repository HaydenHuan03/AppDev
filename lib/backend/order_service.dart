import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String orderNumber,
    required String name,
    required String email,
    required double totalPrice,
    required List<Product> cartItems,
  }) async {
    try {
      // Prepare order details
      Map<String, dynamic> orderData = {
        'orderNumber': orderNumber,
        'name': name,
        'email': email,
        'totalPrice': 'RM ${totalPrice.toStringAsFixed(2)}',
        'orderDate': FieldValue.serverTimestamp(),
        'items': cartItems
            .map((product) => {
                  'name': product.name,
                  'price': product.price,
                  'category': product.category,
                })
            .toList(),
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
