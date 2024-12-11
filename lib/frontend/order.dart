import 'package:flutter/material.dart';
import 'receipt.dart';
import 'package:ad_project_v2/backend/product.dart';

class PaymentDialog extends StatefulWidget {
  final List<Product> cartItems;
  final double totalPrice;
  final VoidCallback onClearCart;

  const PaymentDialog({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
    required this.onClearCart,
  }) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showConfirmPurchase = true;
  bool _showUserDetails = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xFFFB2626), width: 2)),
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

        //spacing between 'Order Confirmation' and 'Do you want to proceed with the order?'
        const SizedBox(height: 20),

        const Text(
          'Do you want to proceed with the order?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),

        //spacing between 'Do you want to proceed with the order?' and yes/no
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

          //spacing between 'User Details' and name, email
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
            //Make sure the name is not null
            validator: (value) =>
                value!.isEmpty ? 'Please enter your name' : null,
          ),

          //spacing between name and email
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
              // Basic email validation
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          //spacing between name, email and confirm/cancel
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
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReceiptPage(
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  cartItems: widget.cartItems,
                                  totalPrice: widget.totalPrice,
                                  onClearCart: widget.onClearCart,
                                )));
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
