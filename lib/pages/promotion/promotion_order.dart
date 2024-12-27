import 'package:flutter/material.dart';
import 'promotion_order_receipt.dart';
import 'dart:math';

import 'package:utm_courtify/data/promotion_data/promotion_order_service.dart';  // Import the order service

class PromotionOrderDialog extends StatefulWidget {
  final String name;  // The name of the product
  final double price; // The price of the product

  const PromotionOrderDialog({
    Key? key,
    required this.name,
    required this.price,
  }) : super(key: key);

  @override
  _PromotionOrderDialogState createState() => _PromotionOrderDialogState();
}

class _PromotionOrderDialogState extends State<PromotionOrderDialog> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showConfirmPurchase = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Color(0xFFFB2626), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _showConfirmPurchase
            ? _buildConfirmPurchaseView()
            : _buildUserDetailsView(),
      ),
    );
  }

  // Order Confirmation Dialog
  Widget _buildConfirmPurchaseView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Order Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Do you want to proceed with the order?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFB2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showConfirmPurchase = false;
                });
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'No',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // User Details Confirmation Dialog
  Widget _buildUserDetailsView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'User Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFB2626)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFB2626), width: 2),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _idController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Matric Number / Staff ID',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFB2626)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFB2626), width: 2),
              ),
            ),
            validator: (value) => value!.isEmpty
                ? 'Please enter your Matric Number or Staff ID'
                : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFB2626)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFB2626), width: 2),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFB2626),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Create order after confirmation
                    await _createOrder();
                    // Proceed to receipt screen after order creation
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromotionOrderReceipt(
                          name: _nameController.text,
                          idNumber: _idController.text,
                          email: _emailController.text,
                          promotionProcuct: widget.name, // Using the name here
                          price: widget.price,
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Call the order service to create the order
  Future<void> _createOrder() async {
    final orderService = PromotionOrderService();
    final orderNumber = _generateOrderNumber();
    await orderService.createOrder(
      orderNumber: orderNumber,
      name: _nameController.text,
      email: _emailController.text,
      idNumber: _idController.text,
      price: widget.price,
      promotionProcuct: widget.name, // Passing the product name
      orderCompleted: false, // Mark the order as not completed
    );
  }

  String _generateOrderNumber() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(10)).join();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
