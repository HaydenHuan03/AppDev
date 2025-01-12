import 'package:flutter/material.dart';
import 'package:utm_courtify/pages/user/profile_screen.dart';
import 'package:utm_courtify/pages/booking/show_available_court.dart';
import 'package:utm_courtify/pages/booking/booking_record.dart';
import 'package:utm_courtify/widgets/navigation_bar.dart';
import 'package:utm_courtify/data/promotion_data/equipment_service.dart';
import 'package:utm_courtify/pages/promotion/promotion_detail_screen.dart';
import 'package:utm_courtify/pages/promotion/promotion.dart';
import 'package:utm_courtify/pages/user/customer_support_screen.dart';
import 'package:utm_courtify/pages/user/emergency_contacts_screen.dart';
import 'package:utm_courtify/data/user_data/firebase_auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Start with Home selected (index 2)
  final FirebaseAuthService _authService = FirebaseAuthService();
  final EquipmentService equipmentService = EquipmentService();

  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Fetch the user's name on initialization
  }

  Future<void> _loadUserName() async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      Map<String, dynamic>? userProfile = await _authService.getUserProfile(userId);
      setState(() {
        _userName = userProfile?['displayName'] ?? 'User';
      });
    } else {
      setState(() {
        _userName = 'Guest';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Color(0xFF000000),
      ),
      body: Container(
        color: Color(0xFF000000), // Set the background color to black
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Welcome to UTM-Courtify, ${_userName ?? 'Loading...'}!", // Dynamic username
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Navigate to different subsystems",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Quick Access Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowAvailableCourt(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFB2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "Book a Court",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingRecord(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFB2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "View Booking History",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Active Equipment Promotions Section
                Text(
                  "Active Promotions (Equipment)",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                FutureBuilder<List<Map<String, dynamic>>>(
                  future: equipmentService.fetchEquipment('badminton', '20%'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Color(0xFFFB2626)),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "No active promotions available",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final promotions = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: promotions.length,
                      itemBuilder: (context, index) {
                        final promo = promotions[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.only(bottom: 12),
                          color: Color(0xFF1C1C1C),
                          child: ListTile(
                            leading: Icon(
                              Icons.local_offer,
                              color: Color(0xFFFB2626),
                            ),
                            title: Text(
                              promo['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              "Discount: ${promo['discount']}\nPrice: RM${promo['price'].toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey[400],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PromotionDetailScreen(
                                    promotion: Promotion(
                                      title: promo['name'],
                                      validity: promo['validity'] ?? 'N/A',
                                      detail: promo['detail'] ?? '',
                                      category: promo['category'] ?? 'Equipment',
                                      discount: promo['discount'] ?? 'N/A',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 24),

                // Customer Support and Emergency Contact Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerSupportScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFB2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "Customer Support",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmergencyContactScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFB2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "Emergency Contact",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        initialIndex: _currentIndex,
      ),
    );
  }
}
