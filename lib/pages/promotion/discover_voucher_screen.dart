import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utm_courtify/data/promotion_data/user_voucher_service.dart';

class DiscoverVoucherScreen extends StatefulWidget {
  @override
  _DiscoverVoucherScreenState createState() => _DiscoverVoucherScreenState();
}

class _DiscoverVoucherScreenState extends State<DiscoverVoucherScreen> {
  final UserVoucherService _firebaseService = UserVoucherService();
  int _userPoints = 0;

  // Fetch user points based on the email (or another identifier)
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
  Future<void> _redeemVoucher(BuildContext context, Map<String, dynamic> voucher, int userPoints, String userEmail) async {
    final requiredPoints = int.parse(voucher['points'].toString());

    if (userPoints < requiredPoints) {
      // Show error dialog if not enough points
      _showErrorDialog(context, requiredPoints - userPoints);
      return;
    }

    // Show confirmation dialog if points are sufficient
    _showConfirmationDialog(context, voucher, userPoints, userEmail);
  }

  // Show error dialog (Not Enough Points)
  void _showErrorDialog(BuildContext context, int missingPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 15.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 40.0,
              ),
              SizedBox(height: 16.0),
              Text(
                'Not Enough Points!',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.0),
              Text(
                'You need $missingPoints more points to redeem this voucher.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFB2626),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
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

  // Show confirmation dialog
  void _showConfirmationDialog(BuildContext context, Map<String, dynamic> voucher, int userPoints, String userEmail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFB2626), Color(0xFF6A0E0E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 40.0,
              ),
              SizedBox(height: 16.0),
              Text(
                'Are You Sure?',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.0),
              Text(
                'You are able to redeem the "${voucher["value"]}" voucher. Do you want to proceed?',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Redeem the voucher and deduct points
                      await _firebaseService.redeemVoucherByEmail(userEmail, voucher, userPoints);
                      Navigator.pop(context);

                      // Update the local points state
                      setState(() {
                        _userPoints -= int.parse(voucher['points'].toString());
                      });

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Voucher redeemed successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFFFB2626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    child: Text(
                      'Yes, Redeem',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Assume we have some way to get the user's email, here it's hardcoded
    final String userEmail = "hayden@graduate.utm.my"; // Replace with dynamic email retrieval
    _getUserPoints(userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Discover Voucher',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
        elevation: 0,
      ),
      body: Column(
        children: [
          // User Points Display
          Container(
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.stars, color: Color(0xFFFB2626), size: 24),
                SizedBox(width: 8),
                Text(
                  'Your Points: $_userPoints pts',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Vouchers List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vouchers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No vouchers available'));
                }

                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final voucher = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: Color(0xFFFB2626), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFB2626).withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${voucher["value"]}",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Points Required: ${voucher["points"]}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFB2626),
                                    ),
                                  ),
                                  Text(
                                    voucher["description"],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "Validity: ${voucher["validity"]}",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              children: [
                                SizedBox(height: 50),
                                ElevatedButton(
                                  onPressed: () => _redeemVoucher(context, voucher, _userPoints, "hayden@graduate.utm.my"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFB2626),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  ),
                                  child: Text(
                                    "Redeem Now",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
