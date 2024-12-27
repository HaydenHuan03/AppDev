import 'package:flutter/material.dart';
import 'dart:math';
//import 'package:ad_project_v2/backend/rent_item_data.dart'; //maybe no need this
import 'package:utm_courtify/data/promotion_data/promotion_order_service.dart';

class PromotionOrderReceipt extends StatelessWidget {
  final String name;
  final String idNumber;
  final String email;
  final String promotionProcuct; //According your file // the item
  final double price;
  final PromotionOrderService _orderService = PromotionOrderService();

  PromotionOrderReceipt({
    Key? key,
    required this.name,
    required this.idNumber,
    required this.email,
    required this.promotionProcuct, //According your file
    required this.price,
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
      idNumber: idNumber,
      email: email,
      price: price,
      promotionProcuct: promotionProcuct, //According your file
      orderCompleted: false,
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

              // Spacing between 'Order Receipt' and Order details
              const SizedBox(height: 20),

              _buildOrderReceiptDetail('Order Number:', orderNumber),
              _buildOrderReceiptDetail('Name:', name),
              _buildOrderReceiptDetail('Matric Number/Staff ID:', idNumber),
              _buildOrderReceiptDetail('Email:', email),
              _buildOrderReceiptDetail(
                  'Price:', 'RM ${price.toStringAsFixed(2)}'),

              // Spacing between Order details and the reminder
              const SizedBox(height: 20),

              const Text(
                'Friendly Reminder: Upon making payment for the order, please screenshot this receipt and present it to the sports hall staff at the counter. Thank you ^_^',
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
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
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

  Widget _buildOrderReceiptDetail(String label, String value) {
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
