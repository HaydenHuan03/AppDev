import 'package:flutter/material.dart';
import 'package:utm_courtify/data/promotion_data/voucher_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyVoucherScreen extends StatefulWidget {
  @override
  _MyVoucherScreenState createState() => _MyVoucherScreenState();
}

class _MyVoucherScreenState extends State<MyVoucherScreen> {
  final VoucherHistoryService _firebaseService = VoucherHistoryService();
  List<Map<String, dynamic>> _redeemedVouchers = [];
  String _userEmail = "";
  Map<String, dynamic>? _redeemedVoucherDetails;

  @override
  void initState() {
    super.initState();
    _userEmail = FirebaseAuth.instance.currentUser?.email ?? "guest@default.com";
    _fetchUserVouchers();
  }

  Future<void> _fetchUserVouchers() async {
    if (_userEmail.isNotEmpty) {
      final vouchers = await _firebaseService.fetchUserVouchers(_userEmail);
      setState(() {
        _redeemedVouchers = vouchers;
      });
    }
  }

  // Handle voucher redemption
  void _redeemVoucher(Map<String, dynamic> voucher) {
    setState(() {
      _redeemedVoucherDetails = voucher;
    });
  }

  // Confirm and redeem the voucher
  void _confirmRedeemVoucher(Map<String, dynamic> voucher) async {
    await _firebaseService.removeVoucher(_userEmail, voucher['voucherId']);
    _fetchUserVouchers();  // Refresh voucher list after redemption
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voucher redeemed successfully!')),
    );
  }

  // Pop-up to confirm redemption
  void _showRedemptionDialog(Map<String, dynamic> voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Redemption'),
        content: Text('Are you sure you want to redeem this voucher?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // Close dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();  // Close dialog
              _confirmRedeemVoucher(voucher);  // Redeem the voucher
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFB2626)),
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
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
          'My Vouchers',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _redeemedVouchers.isEmpty
            ? Center(
                child: Text(
                  "No Vouchers",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: _redeemedVouchers.length,
                itemBuilder: (context, index) {
                  final voucher = _redeemedVouchers[index];
                  return buildVoucherCard(voucher);
                },
              ),
      ),
    );
  }

  Widget buildVoucherCard(Map<String, dynamic> voucher) {
  return Container(
    margin: EdgeInsets.only(bottom: 20.0),
    padding: EdgeInsets.all(20.0),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          voucher["value"],
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Validity: ${voucher['validityDate'] ?? 'Not available'}",
              style: TextStyle(color: Colors.white70),
            ),
            ElevatedButton(
              onPressed: () {
                _showRedemptionDialog(voucher);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFB2626),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Use Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    ),
  );
}

}
