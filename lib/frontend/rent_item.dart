import 'package:flutter/material.dart';
import 'package:ad_project_v2/backend/rent_item_data.dart';
import 'rental.dart';

// About Rent Item List
class RentItemWidget extends StatelessWidget {
  final RentItem item;

  // Change rent price from string to double
  double _rentPrice() {
    // Remove 'RM' and convert to double
    String priceString = item.price.replaceAll('RM ', '');
    return double.parse(priceString);
  }

  const RentItemWidget({
    Key? key,
    required this.item,
    //required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Color(0xFFFB2626), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Rent Item Image
          if (item != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                '${item.rentItemImages[item.name]}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          else
            const Icon(
              Icons.image,
              size: 80,
              color: Colors.white,
            ),

          // Spacing between image and text
          const SizedBox(width: 15),

          // Rent Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Rent Now Button
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => RentalPaymentDialog(
                  rentItem: item,
                  price: _rentPrice(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
              decoration: BoxDecoration(
                color: Color(0xFFFB2626),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'Rent Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
