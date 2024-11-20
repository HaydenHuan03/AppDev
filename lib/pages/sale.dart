// From Eddy - Subsystem 2

import 'package:flutter/material.dart';
import 'cart.dart';
import 'product.dart';
import 'package:ad_project_v2/pages/firebase_service.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _showSaleItems = true; // Toggle between sale and rental
  bool _showCart = false; // Toggle between sale/rental and cart list page
  String _selectedCategory = 'racquet'; // Track selected category
  final List<Product> _cartItems = []; // List to store cart items

  // final Map<String, String> _images = {
  //   'Yonex_Lightning': 'Yonex_Lightning.jpeg',
  // };

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartItems.remove(product);
    });
  }

  // Stream builder for products
  Widget _buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: _firebaseService.getProductsByCategory(_selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading products: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFB2626),
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products available in this category',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductWidget(
              product: product,
              onAddToCart: _addToCart,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar with welcome message and cart
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //About welcome user text
                Text(
                  _showCart
                      ? 'Here is the shopping cart . . .'
                      : 'Welcome User 001!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Cart/Basket toggle button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCart = !_showCart;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFB2626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _showCart ? Icons.shopping_cart : Icons.shopping_basket,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Display when is in Sale/Rental page
          if (!_showCart) ...[
            // Help text
            const Text(
              'How can I help you?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),

            // Sale/Rental toggle button
            Padding(
              padding: const EdgeInsets.only(
                  top: 7.5, bottom: 20.0), //padding of toggle bar
              child: Center(
                child: Container(
                  width: 250, // Fixed width for the toggle bar
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFFB2626), width: 2),
                    borderRadius: BorderRadius.circular(7.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          // Show sale items
                          onTap: () => setState(() => _showSaleItems = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7.5), //padding of word in toggle bar
                            decoration: BoxDecoration(
                              color: _showSaleItems
                                  ? Color(0xFFFB2626)
                                  : Colors.black,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Sale',
                                style: TextStyle(
                                  fontSize: 27.5, //size of "Sale" in toggle bar
                                  // When display sale, the sale word black, rental word white
                                  color: _showSaleItems
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          // show rental item
                          onTap: () => setState(() => _showSaleItems = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7.5), //padding of word in toggle bar
                            decoration: BoxDecoration(
                              color: !_showSaleItems
                                  ? Color(0xFFFB2626)
                                  : Colors.black,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Rental',
                                style: TextStyle(
                                  fontSize:
                                      27.5, //size of "Rental" in toggle bar
                                  // When display rental, the rental word black, sale word white
                                  color: !_showSaleItems
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Show categories and products if in Sale view
            if (_showSaleItems) ...[
              Container(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                          color: Color(0xFFFFB2626),
                          width: 2), // Only top and bottom borders),
                      //borderRadius: BorderRadius.circular(7.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCategoryIcon(
                          'icons/SaleCategories/Badmintion_Icon.png',
                          'racquet',
                          'Racquet'),
                      _buildCategoryIcon(
                          'icons/SaleCategories/Shuttlecock_Icon.png',
                          'shuttlecock',
                          'Shuttle'),
                      _buildCategoryIcon('icons/SaleCategories/Shirt_Icon.png',
                          'shirt', 'Shirt'),
                      _buildCategoryIcon('icons/SaleCategories/Snacks_Icon.png',
                          'snacks', 'Snacks'),
                      _buildCategoryIcon('icons/SaleCategories/Drinks_Icon.png',
                          'drinks', 'Drinks'),
                    ],
                  ),
                ),
              ),

              // Product list
              Expanded(
                child: _buildProductList(),
              ),
            ],
          ] else ...[
            // Cart view
            Expanded(
              child: CartListWidget(
                cartItems: _cartItems,
                // Remove item from cart
                onRemoveFromCart: _removeFromCart,
              ),
            ),
            // Buy Now bar - Only show when the cart list is no empty
            if (_cartItems.isNotEmpty)
              Container(
                color: Color(0xFFFB2626),
                width: 150, // width of buy now bar
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: const Center(
                  child: Text(
                    'Buy Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // About sale category icon
  Widget _buildCategoryIcon(String assetPath, String category, String tooltip) {
    bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(5), // Padding of icon
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFB2626) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Image.asset(
            assetPath,
            width: 50,
            height: 50,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

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
