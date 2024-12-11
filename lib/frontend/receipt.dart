import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ad_project_v2/backend/product.dart';
import 'package:ad_project_v2/backend/order_service.dart';

class ReceiptPage extends StatelessWidget {
  final String name;
  final String email;
  final List<Product> cartItems;
  final double totalPrice;
  final VoidCallback onClearCart;
  final OrderService _orderService = OrderService();

  ReceiptPage({
    Key? key,
    required this.name,
    required this.email,
    required this.cartItems,
    required this.totalPrice,
    required this.onClearCart,
  }) : super(key: key);

  //For randomly generate order number
  String _generateOrderNumber() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(10)).join();
  }

  @override
  Widget build(BuildContext context) {
    final orderNumber = _generateOrderNumber();

    // Create order in database before showing receipt
    _orderService.createOrder(
      orderNumber: orderNumber,
      name: name,
      email: email,
      totalPrice: totalPrice,
      cartItems: cartItems,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Color(0xFFFB2626), width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Order Receipt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Spacing between 'Order Receipt' and order details
              const SizedBox(height: 20),

              _buildReceiptDetail('Order Number:', orderNumber),
              _buildReceiptDetail('Name:', name),
              _buildReceiptDetail('Email:', email),
              _buildReceiptDetail(
                  'Total Price:', 'RM ${totalPrice.toStringAsFixed(2)}'),

              // Spacing between order details and the reminder
              const SizedBox(height: 20),

              const Text(
                'Soft Reminder: Please screenshot this receipt then show to the sports hall staff at the counter and pay for the ordered items. Thank you ^_^',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              // Spacing between reminder and noted bar
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFB2626),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  onClearCart();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Noted',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}