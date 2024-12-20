import 'package:flutter/material.dart';

class RentalPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                'Rental Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Spacing between 'Rental Policy' and content
              const SizedBox(height: 20),

              const Text(
                'Kindly be reminded that the renting duration is 3 hours and will start counting down from now. If the rented item is not returned within 3 hours, a penalty in the form of an extra charge will be imposed upon returning rented item.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  //fontStyle: FontStyle.italic,
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
                  'Yes, I agree with the policy.',
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
