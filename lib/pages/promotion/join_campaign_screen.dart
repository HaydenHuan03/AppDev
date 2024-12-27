import 'package:flutter/material.dart';
import 'package:utm_courtify/pages/promotion/list_of_campaign.dart';
import 'package:utm_courtify/pages/promotion/my_campaign.dart';
import 'package:utm_courtify/widgets/navigation_bar.dart';

class JoinCampaignScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: CustomNavigationBar(initialIndex: 3),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/promotion');
          } , 
          icon: const Icon(Icons.arrow_back, color: Colors.white,)
        ),
        title: Text(
          'Campaign',
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
      body: Container(
        margin: EdgeInsets.only(top: 50.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items at the top
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [ // Add space below the AppBar
            // List Of Campaign Column
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListOfCampaign(),
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
                    'List Of Campaign',
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
                    builder: (context) => MyCampaign(userEmail: "hayden@graduate.utm.my"), // Replace with your screen
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
                    'My Campaign',
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
