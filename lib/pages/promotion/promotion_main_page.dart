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
          ),
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
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
        elevation: 0,
      ),
      bottomNavigationBar: CustomNavigationBar(initialIndex: 3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PromotionListScreen(),
                  ),
                );
              },
              child: buildPromotionCard('Equipment Promotion'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscoverVoucherScreen(),
                  ),
                );
              },
              child: buildPromotionCard('Discover Voucher'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyVoucherScreen(),
                  ),
                );
              },
              child: buildPromotionCard('My Voucher'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JoinCampaignScreen(),
                  ),
                );
              },
              child: buildPromotionCard('Join Campaign'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPromotionCard(String title) {
    return Container(
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
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
