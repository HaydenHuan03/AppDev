import 'package:flutter/material.dart';
import 'package:utm_courtify/data/promotion_data/voucher_history_service.dart';

class MyVoucherScreen extends StatefulWidget {
  final String userEmail;

  MyVoucherScreen({required this.userEmail});

  @override
  _MyVoucherScreenState createState() => _MyVoucherScreenState();
}

class _MyVoucherScreenState extends State<MyVoucherScreen> {
  final VoucherHistoryService _firebaseService = VoucherHistoryService();
  List<Map<String, dynamic>> _redeemedVouchers = [];
  Map<String, dynamic>? _redeemedVoucherDetails;  // To store voucher details for pop-up
  bool _isVoucherRedeemed = false; // To track if a voucher was redeemed

  @override
  void initState() {
    super.initState();
    _fetchUserVouchers();
  }

  // Fetch redeemed vouchers for the user
  Future<void> _fetchUserVouchers() async {
    final vouchers = await _firebaseService.fetchUserVouchers(widget.userEmail);
    setState(() {
      _redeemedVouchers = vouchers;
    });
  }

  // Handle voucher redemption
  void _redeemVoucher(Map<String, dynamic> voucher) {
    setState(() {
      _redeemedVoucherDetails = voucher;
      _isVoucherRedeemed = true; // Voucher is redeemed
    });
  }

  // Handle confirm button click
  void _confirmRedeemVoucher(Map<String, dynamic> voucher) async {
    await _firebaseService.removeVoucher(widget.userEmail, voucher['voucherId']);
    setState(() {
      _redeemedVoucherDetails = null; // Clear the voucher details
      _isVoucherRedeemed = false; // Voucher redeemed and pop-up closed
      _fetchUserVouchers(); // Refresh the list of vouchers
    });
  }

  // Handle close pop-up
  void _closePopUp() {
    setState(() {
      _redeemedVoucherDetails = null;
      _isVoucherRedeemed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        
        title: Text(
          'My Vouchers',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _redeemedVouchers.isEmpty
            ? Center(child: Text('No vouchers redeemed yet'))
            : ListView.builder(
                itemCount: _redeemedVouchers.length,
                itemBuilder: (context, index) {
                  final voucher = _redeemedVouchers[index];

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
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Validity: ${voucher['validityDate'] != null ? voucher['validityDate'].toString() : 'Not available'}",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Redeemed At: ${voucher["redeemedAt"] != null ? voucher["redeemedAt"].toDate().toLocal() : "Not redeemed yet"}",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child:                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                            onPressed: () => _redeemVoucher(voucher),
                            iconAlignment: IconAlignment.end,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFB2626), // Background color
                              padding: EdgeInsets.all(10.0), // Padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                            ),
                            child: Text(
                              'Use Now',
                              style: TextStyle(
                                color: Colors.white, // Set font color to white
                                fontSize: 16.0, // Optional: Adjust font size if needed
                              ),
                            ),
                          ),
                          ]
                        )
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: _isVoucherRedeemed
          ? _buildVoucherRedeemedPopUp()
          : null,
    );
  }

  // Pop-up design enhancement
  Widget _buildVoucherRedeemedPopUp() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(  // Add scroll functionality in case content overflows
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensure the column is sized to its content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Voucher Redeemed',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _closePopUp,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(color: Colors.white),
              SizedBox(height: 10),
              Text(
                'Voucher: ${_redeemedVoucherDetails?['value'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Validity: ${_redeemedVoucherDetails?['validityDate'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              // Increase the height of the "Redeemed At" section by adding padding
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Redeemed At: ${_redeemedVoucherDetails?['redeemedAt']?.toDate() ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _confirmRedeemVoucher(_redeemedVoucherDetails!),
                  child: Text('Confirm Redemption'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFFB2626),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
