<<<<<<< HEAD:lib/data/shopping_rental_data/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_data.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String orderNumber,
    required String name,
    required String email,
    required String idNumber,
    required double totalPrice,
    required List<Product> cartItems,
    required bool orderCompleted,
  }) async {
    try {
      // Prepare order details
      Map<String, dynamic> orderData = {
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
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_data.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String orderNumber,
    required String name,
    required String email,
    required String idNumber,
    required double totalPrice,
    required List<Product> cartItems,
    required bool orderCompleted,
  }) async {
    try {
      // Prepare order details
      Map<String, dynamic> orderData = {
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
>>>>>>> 60273afa819430474acaea1a73aa1330e1233cf6:lib/backend/order_service.dart
