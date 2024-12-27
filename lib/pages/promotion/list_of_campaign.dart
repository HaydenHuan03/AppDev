import 'package:flutter/material.dart';
import 'package:utm_courtify/data/promotion_data/campaign_service.dart';

class ListOfCampaign extends StatelessWidget {
  final Map<String, String> campaignImageMap = {
    'Longest Rally Challenge': 'assets/longest-rally-challenge.png',
    'Fastest Smash Challenge': 'assets/fastest-smash-challenge.png',
    'Best Trick Shot Contest': 'assets/best-trick-shot.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Campaigns'),
        backgroundColor: Color(0xFFFB2626),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: CampaignService().fetchAvailableCampaigns(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading campaigns"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No campaigns available"));
          }

          final campaigns = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              final campaignName = campaign['name'];

              // Get image path based on campaign name using the imageMap
              final imageAsset = campaignImageMap[campaignName] ?? 'assets/images/default_image.jpg'; // Default image if not found

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
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
                    ),
                    SizedBox(width: 16),
                    Column(
                      children: [
                        Image.asset(
                          imageAsset, // Use local asset path
                          height: 80.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 80.0,
                              width: 80.0,
                              color: Colors.grey,
                              child: Icon(Icons.error),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // Add join campaign logic here
                            bool hasJoined = await CampaignService().hasUserJoinedCampaign("hayden@graduate.utm.my", campaignName);
                            if (!hasJoined) {
                              await CampaignService().joinCampaign("hayden@graduate.utm.my", campaign);
                              _showJoinCampaignDialog(context);
                            } else {
                              _showAlreadyJoinedDialog(context);
                            }
                          },
                          child: Text(
                            'Join Campaign',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFB2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                          ),
                        ),
                      ],
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

  // Function to show a pop-up dialog when campaign is joined
  void _showJoinCampaignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFB2626),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners for the pop-up
        ),
        title: Text(
          'Campaign Joined Successfully!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You have successfully joined the campaign.',
          style: TextStyle(color: Colors.white70, fontSize: 16.0),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show a dialog when the user has already joined the campaign
  void _showAlreadyJoinedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFB2626),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners for the pop-up
        ),
        title: Text(
          'You have already joined this campaign!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You are already part of this campaign. You cannot join again.',
          style: TextStyle(color: Colors.white70, fontSize: 16.0),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
