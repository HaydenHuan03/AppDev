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
  int _currentIndex = 2;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final EquipmentService equipmentService = EquipmentService();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
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

    void _showNotification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1C1C1C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.notifications, color: Color(0xFFFB2626)),
              SizedBox(width: 10),
              Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            height: 300,
            width: double.maxFinite,
            child: ListView(
              children: [
                _notificationItem(
                  'Booking Confirmation',
                  'Your court booking for tomorrow has been confirmed.',
                  '2 mins ago',
                ),
                _notificationItem(
                  'New Promotion',
                  'Check out our new equipment promotion!',
                  '1 hour ago',
                ),
                _notificationItem(
                  'Maintenance Notice',
                  'Court 3 will be under maintenance tomorrow.',
                  '2 hours ago',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFFFB2626)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _notificationItem(String title, String message, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: Color(0xFFFB2626),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(String text, VoidCallback onPressed, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFB2626),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFFFB2626),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Color(0xFF000000),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFB2626),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sports_tennis,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "UTM Courtify",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _showNotification,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFB2626),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFF000000),
        child: RefreshIndicator(
          color: Color(0xFFFB2626),
          onRefresh: () async {
            await _loadUserName();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFB2626), Color(0xFF8B0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back,",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${_userName ?? 'Loading...'}!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Quick Access Section
                  _buildSectionTitle("Quick Access"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAccessButton(
                        "Book a Court",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShowAvailableCourt()),
                        ),
                        Icons.sports_tennis,
                      ),
                      _buildQuickAccessButton(
                        "Booking History",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookingRecord()),
                        ),
                        Icons.history,
                      ),
                    ],
                  ),

                  // Promotions Section
                  _buildSectionTitle("Active Promotions"),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: equipmentService.fetchEquipment('badminton', '20%'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Color(0xFFFB2626)),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF1C1C1C),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.local_offer_outlined, color: Colors.grey, size: 48),
                                SizedBox(height: 8),
                                Text(
                                  "No active promotions available",
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
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
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1C1C1C), Color(0xFF2A2A2A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFB2626).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.local_offer,
                                  color: Color(0xFFFB2626),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                promo['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text(
                                    "Discount: ${promo['discount']}",
                                    style: TextStyle(
                                      color: Color(0xFFFB2626),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "RM${promo['price'].toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 16,
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

                  // Support Section
                  _buildSectionTitle("Support"),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _buildSupportButton(
                          "Customer Support",
                          Icons.support_agent,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CustomerSupportScreen()),
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildSupportButton(
                          "Emergency Contact",
                          Icons.emergency,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmergencyContactScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        initialIndex: _currentIndex,
      ),
    );
  }

  Widget _buildSupportButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFB2626),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}