import 'package:flutter/material.dart';
import 'package:utm_courtify/pages/promotion/discover_voucher_screen.dart';
import 'package:utm_courtify/pages/promotion/my_voucher_screen.dart';
import 'package:utm_courtify/widgets/navigation_bar.dart';
import 'promotion_list_screen.dart';
import 'join_campaign_screen.dart';

class PromotionMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )
        ),
        title: Text(
          'Promotion',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          } , 
          icon: const Icon(Icons.arrow_back, color: Colors.white,)
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
        elevation: 0,
      ),
      bottomNavigationBar: CustomNavigationBar(initialIndex: 3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items at the top
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50), // Add space below the AppBar
            // Equipment Promotion Column
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PromotionListScreen(),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 30.0), // Adjust spacing between buttons
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Color(0xFFFB2626), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFB2626),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Equipment Promotion',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Discover Voucher Column
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscoverVoucherScreen(),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 30.0), // Adjust spacing between buttons
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
                child: Center(
                  child: Text(
                    'Discover Voucher',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // My Voucher Column
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyVoucherScreen(userEmail: "hayden@graduate.utm.my"),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 30.0),
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
                child: Center(
                  child: Text(
                    'My Voucher',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Join Campaign Column (New)
            GestureDetector(
              onTap: () {
                // Define the navigation to the Join Campaign page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinCampaignScreen(), // Replace with your screen
                  ),
                );
              },
              child: Container(
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
                child: Center(
                  child: Text(
                    'Join Campaign',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
