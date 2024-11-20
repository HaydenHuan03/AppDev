// From Eddy - Subsystem 2

import 'package:flutter/material.dart';
import 'product.dart';

// About cart list page - Adjust container
class CartListWidget extends StatelessWidget {
  final List<Product> cartItems;
  final Function(Product) onRemoveFromCart;

  const CartListWidget({
    Key? key,
    required this.cartItems,
    required this.onRemoveFromCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cartItems.isNotEmpty
        // When cart list no empty
        ? Column(
            children: [
              // "Cart List" container
              Container(
                color: Color(0xFFFB2626),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 5),
                child: const Center(
                  child: Text(
                    'Cart List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems[index];
                    return CartItemWidget(
                      product: product,
                      onRemove: () => onRemoveFromCart(product),
                    );
                  },
                ),
              ),
            ],
          )
        // When cart list is empty
        : Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFFFB2626), width: 2),
              ),
              child: const Text(
                'No item found in cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }
}

// About cart list page - Adjust item space in container
class CartItemWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.product,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Color(0xFFFB2626), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (product.name != null)
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
          const SizedBox(width: 16),
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
          // To remove item from cart list
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                color: Color(0xFFFB2626),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '-',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
