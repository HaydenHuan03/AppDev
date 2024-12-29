import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utm_courtify/data/promotion_data/user_voucher_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscoverVoucherScreen extends StatefulWidget {
  @override
  _DiscoverVoucherScreenState createState() => _DiscoverVoucherScreenState();
}

class _DiscoverVoucherScreenState extends State<DiscoverVoucherScreen> {
  final UserVoucherService _firebaseService = UserVoucherService();
  int _userPoints = 0;
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch logged-in user's email and points
  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _userEmail = user.email!;
      await _getUserPoints(_userEmail);
    }
  }

  // Fetch user points based on email
  Future<void> _getUserPoints(String userEmail) async {
    try {
      final points = await _firebaseService.getUserPointsByEmail(userEmail);
      setState(() {
        _userPoints = points;
      });
    } catch (e) {
      print("Error fetching user points: $e");
    }
  }

  // Redeem a voucher
  Future<void> _redeemVoucher(BuildContext context, Map<String, dynamic> voucher) async {
    final requiredPoints = int.parse(voucher['points'].toString());

    if (_userPoints < requiredPoints) {
      _showErrorDialog(context, requiredPoints - _userPoints);
      return;
    }

    _showConfirmationDialog(context, voucher);
  }

  // Show error dialog
  void _showErrorDialog(BuildContext context, int missingPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.redAccent,
        title: Text('Not Enough Points!'),
        content: Text('You need $missingPoints more points to redeem this voucher.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog
  void _showConfirmationDialog(BuildContext context, Map<String, dynamic> voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Redemption'),
        content: Text('Do you want to redeem the "${voucher["value"]}" voucher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firebaseService.redeemVoucherByEmail(_userEmail, voucher, _userPoints);
              Navigator.pop(context);
              _getUserPoints(_userEmail);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Voucher redeemed successfully!')),
              );
            },
            child: Text('Redeem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: Text(
          'Discover Voucher',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
      ),
      body: Column(
        children: [
          // User Points Display
          Container(
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Icon(Icons.stars, color: Color(0xFFFB2626)),
                SizedBox(width: 8),
                Text(
                  'Your Points: $_userPoints pts',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vouchers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No vouchers available', style: TextStyle(color: Colors.white)));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final voucher = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Color(0xFFFB2626)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFB2626).withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Voucher Details (Top Left)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${voucher["value"]}",
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Description: ${voucher["description"]}",
                                style: TextStyle(fontSize: 14.0, color: Colors.white70),
                              ),
                              Text(
                                "Validity: ${voucher["validity"]}",
                                style: TextStyle(fontSize: 14.0, color: Colors.white70),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Points Required: ${voucher["points"]}",
                                style: TextStyle(fontSize: 16.0, color: Color(0xFFFB2626)),
                              ),
                            ],
                          ),
                          // "Redeem Now" Button (Bottom Right)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ElevatedButton(
                              onPressed: () => _redeemVoucher(context, voucher),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFB2626),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: Text('Redeem Now', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
