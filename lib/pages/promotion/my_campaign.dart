import 'package:flutter/material.dart';
import 'package:utm_courtify/data/promotion_data/campaign_service.dart';

class MyCampaign extends StatelessWidget {
  final String userEmail;

  MyCampaign({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Campaigns'),
        backgroundColor: Color(0xFFFB2626),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: CampaignService().fetchUserCampaigns(userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading your campaigns"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("You haven't joined any campaigns"));
          }

          final joinedCampaigns = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: joinedCampaigns.length,
            itemBuilder: (context, index) {
              final campaign = joinedCampaigns[index];

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
                      campaign['name'],
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      campaign['description'],
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Validity: ${campaign['validity']}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
