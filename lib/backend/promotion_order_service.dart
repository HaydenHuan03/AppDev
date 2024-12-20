import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String orderNumber,
    required String name,
    required String email,
    required String idNumber,
    required double price,
    required String promotionProcuct, 
    required bool orderCompleted,
  }) async {
    try {
      // Prepare order details
      Map<String, dynamic> orderData = {
        'orderNumber': orderNumber,
        'name': name,
        'email': email,
        'matricNum/staffID': idNumber,
        'price': 'RM ${price.toStringAsFixed(2)}',
        'items': promotionProcuct, 
        'orderCompleted': orderCompleted,
      };

      // Get the current number of promotion order and use it to generate a sequential document name
      int orderCount = await _getOrderCount();
      String documentName = 'promotionOrder${orderCount + 1}';

      // Add order to Firestore using the custom document name
      await _firestore
          .collection('promotion_order')
          .doc(documentName)
          .set(orderData);
    } catch (e) {
      print('Error creating promotion_order: $e');
      rethrow;
    }
  }

  Future<int> _getOrderCount() async {
    QuerySnapshot snapshot =
        await _firestore.collection('promotion_order').get();
    return snapshot.docs.length;
  }
}
