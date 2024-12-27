import 'package:flutter/material.dart';
import 'package:utm_courtify/data/shopping_rental_data/product_data.dart';

// About Product List
class ProductWidget extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductWidget({
    Key? key,
    required this.product,
    required this.onAddToCart,
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
          // Product Image
          if (product != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                '${product.productImages[product.name]}',
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

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Add to Cart Button
          GestureDetector(
            onTap: () => onAddToCart(product),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
              decoration: BoxDecoration(
                color: Color(0xFFFB2626),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '+',
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
