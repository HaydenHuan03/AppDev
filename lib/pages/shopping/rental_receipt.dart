import 'package:flutter/material.dart';
import 'dart:math';
import 'package:utm_courtify/data/shopping_rental_data/rent_item_data.dart';
import 'package:utm_courtify/data/shopping_rental_data/rental_service.dart';
import 'rental_policy.dart';

class RentalReceipt extends StatelessWidget {
  final String name;
  final String idNumber;
  final String email;
  final RentItem rentItem;
  final double price;
  final RentalService _rentalService = RentalService();

  RentalReceipt({
    Key? key,
    required this.name,
    required this.idNumber,
    required this.email,
    required this.rentItem,
    required this.price,
  }) : super(key: key);

  //For randomly generate rental number
  String _generateRentalNumber() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(10)).join();
  }

  @override
  Widget build(BuildContext context) {
    final rentalNumber = _generateRentalNumber();

    // Create rental in database before showing receipt
    _rentalService.createRental(
      rentalNumber: rentalNumber,
      name: name,
      idNumber: idNumber,
      email: email,
      price: price,
      rentItem: rentItem,
      returnItem: false,
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
                'Rental Receipt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Spacing between 'Rental Receipt' and rental details
              const SizedBox(height: 20),

              _buildRentalReceiptDetail('Rental Number:', rentalNumber),
              _buildRentalReceiptDetail('Name:', name),
              _buildRentalReceiptDetail('Matric Number/Staff ID:', idNumber),
              _buildRentalReceiptDetail('Email:', email),
              _buildRentalReceiptDetail(
                  'Price:', 'RM ${price.toStringAsFixed(2)}'),

              // Spacing between rental details and the reminder
              const SizedBox(height: 20),

              const Text(
                'Friendly Reminder: Upon making payment for the rented item, please screenshot this receipt and present it to the sports hall staff at the counter. Thank you ^_^',
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
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => RentalPolicy()));
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

  Widget _buildRentalReceiptDetail(String label, String value) {
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
