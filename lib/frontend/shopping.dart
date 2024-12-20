import 'package:flutter/material.dart';
import 'cart.dart';
import 'package:ad_project_v2/backend/product_data.dart';
import 'package:ad_project_v2/backend/product_data_service.dart'
    as product_service; //Adjust a bit in Sprint 3
import 'order.dart'; //Sprint 2
import 'order_history.dart'; //Sprint 3
import 'package:ad_project_v2/backend/rent_item_data.dart'; //Sprint 3
import 'package:ad_project_v2/backend/rent_item_data_service.dart'
    as rent_service; //Sprint 3
import 'product.dart'; //Sprint 1 task - just changing file
import 'rent_item.dart'; //Sprint 3 task
import 'rental_detail.dart'; //Sprint 3

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  final product_service.FirebaseService _productFirebaseService =
      product_service.FirebaseService();
  final rent_service.FirebaseService _rentFirebaseService =
      rent_service.FirebaseService();
  bool _showSaleItems = true; // Toggle between sale and rental
  bool _showCart = false; // Toggle between sale/rental and cart list page
  String _selectedCategory = 'racquet'; // Track selected category
  final List<Product> _cartItems = []; // List to store cart items
  bool _showDropdownMenu = false; //Sprint 3
  bool _showOrderHistory = false; //Sprint 3
  bool _showRentalDetail = false; //Sprint 3

  // Default user details - Sprint 3
  final String _userName = "Eddy Koh Wei Hen";
  final String _userMatricNumStaffID = "A22EC0154";

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

  // Calculate total cart price
  double _calculateTotalPrice() {
    return _cartItems.fold(0.0, (total, product) {
      // Remove 'RM' and convert to double
      String priceString = product.price.replaceAll('RM ', '');
      return total + double.parse(priceString);
    });
  }

  // Stream builder for products
  Widget _buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: _productFirebaseService.getProductsByCategory(_selectedCategory),
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
        // Display when product is not available from database
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

  // Stream builder for rent item
  Widget _buildRentItemList() {
    return StreamBuilder<List<RentItem>>(
      stream: _rentFirebaseService.getRentItemByCategory("rent"),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading rent items: ${snapshot.error}',
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

        final rentItems = snapshot.data ?? [];
        // Display when rent item not available from database
        if (rentItems.isEmpty) {
          return const Center(
            child: Text(
              'No rent items available in this category',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: rentItems.length,
          itemBuilder: (context, index) {
            final item = rentItems[index];
            return RentItemWidget(
              item: item,
            );
          },
        );
      },
    );
  }

  // Dropdown menu - Sprint 3
  Widget _buildDropdownMenu() {
    // Sale page menu items
    List<Widget> salePageMenuItems = [
      _buildDropdownMenuItem(
          icon: Icons.shopping_basket,
          title: 'Shopping Cart',
          onTap: () {
            setState(() {
              _showCart = true;
              _showOrderHistory = false;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.history,
          title: 'Order History',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = true;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.history_edu,
          title: 'Rental Detail',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = false;
              _showRentalDetail = true;
              _showDropdownMenu = false;
            });
          }),
    ];

    // Cart page menu items
    List<Widget> cartPageMenuItems = [
      _buildDropdownMenuItem(
          icon: Icons.shopping_cart,
          title: 'Shopping Platform',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = false;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.history,
          title: 'Order History',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = true;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.history_edu,
          title: 'Rental Detail',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = false;
              _showRentalDetail = true;
              _showDropdownMenu = false;
            });
          }),
    ];

    // Order History menu items
    List<Widget> orderHistoryPageMenuItems = [
      _buildDropdownMenuItem(
          icon: Icons.shopping_cart,
          title: 'Shopping Platform',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = false;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.shopping_basket,
          title: 'Shopping Cart',
          onTap: () {
            setState(() {
              _showCart = true;
              _showOrderHistory = false;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.history_edu,
          title: 'Rental Detail',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = false;
              _showRentalDetail = true;
              _showDropdownMenu = false;
            });
          }),
    ];

    // Rental Detail menu items
    List<Widget> rentalDetailPageMenuItems = [
      _buildDropdownMenuItem(
          icon: Icons.shopping_cart,
          title: 'Shopping Platform',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = false;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.shopping_basket,
          title: 'Shopping Cart',
          onTap: () {
            setState(() {
              _showCart = true;
              _showOrderHistory = false;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
      _buildDropdownMenuItem(
          icon: Icons.history,
          title: 'Order History',
          onTap: () {
            setState(() {
              _showCart = false;
              _showOrderHistory = true;
              _showRentalDetail = false;
              _showDropdownMenu = false;
            });
          }),
    ];

    return Positioned(
      top: 70,
      right: 15,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Color(0xFFFB2626), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: () {
            if (_showCart) {
              return cartPageMenuItems;
            } else if (_showOrderHistory) {
              return orderHistoryPageMenuItems;
            } else if (_showRentalDetail) {
              return rentalDetailPageMenuItems;
            } else {
              return salePageMenuItems;
            }
          }(),
        ),
      ),
    );
  }

  // Helper method to build dropdown menu items
  Widget _buildDropdownMenuItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFFB2626), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 25),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Make changes in Sprint 3
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Top bar with welcome message and list icon
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_showCart)
                      const Text(
                        'Here is the shopping cart . . .',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (_showOrderHistory)
                      const Text(
                        'Here is the order history . . .',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (_showRentalDetail)
                      const Text(
                        'Here is the rental detail . . .',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        'Welcome $_userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    // Changed to constant list icon with dropdown functionality - Sprint 3
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showDropdownMenu = !_showDropdownMenu;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFB2626),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.list,
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_showCart) ...[
                // Cart view
                Expanded(
                  child: CartListWidget(
                    cartItems: _cartItems,
                    // Remove item from cart
                    onRemoveFromCart: _removeFromCart,
                  ),
                ),
                // Order Now bar - Only show when the cart list is no empty
                //Click to proceed payment features
                if (_cartItems.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => PaymentDialog(
                          cartItems: _cartItems,
                          totalPrice: _calculateTotalPrice(),
                          onClearCart: () {
                            setState(() {
                              _cartItems.clear();
                            });
                          },
                        ),
                      );
                    },
                    child: Container(
                      color: Color(0xFFFB2626),
                      width: 300, // width of buy now bar
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Center(
                        child: Text(
                          'Order Now: RM ${_calculateTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ] // Display when is in Order History page
              else if (_showOrderHistory) ...[
                Expanded(
                  child: OrderHistoryPage(
                    userName: _userName,
                    userMatricNumStaffID: _userMatricNumStaffID,
                  ),
                ),
              ]
              // Display when is in Rental Detail page
              else if (_showRentalDetail) ...[
                Expanded(
                  child: RentalDetailPage(
                    userName: _userName,
                    userMatricNumStaffID: _userMatricNumStaffID,
                  ),
                ),
              ] // Display when is in Sale/Rental page
              else ...[
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
                              onTap: () =>
                                  setState(() => _showSaleItems = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        7.5), //padding of word in toggle bar
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
                                      fontSize:
                                          27.5, //size of "Sale" in toggle bar
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
                              onTap: () =>
                                  setState(() => _showSaleItems = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        7.5), //padding of word in toggle bar
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
                              'Shuttlecock'),
                          _buildCategoryIcon(
                              'icons/SaleCategories/Shirt_Icon.png',
                              'shirt',
                              'Shirt'),
                          _buildCategoryIcon(
                              'icons/SaleCategories/Snacks_Icon.png',
                              'snacks',
                              'Snacks'),
                          _buildCategoryIcon(
                              'icons/SaleCategories/Drinks_Icon.png',
                              'drinks',
                              'Drinks'),
                        ],
                      ),
                    ),
                  ),

                  // Product list
                  Expanded(
                    child: _buildProductList(),
                  ),
                ] else ...[
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
                    ),
                  ),

                  // Rent item list
                  Expanded(
                    child: _buildRentItemList(),
                  ),
                ],
              ]
            ],
          ),
          // Dropdown menu overlay
          if (_showDropdownMenu) _buildDropdownMenu(),
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
