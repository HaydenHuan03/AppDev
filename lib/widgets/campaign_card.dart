import 'package:flutter/material.dart';
import 'package:utm_courtify/data/promotion_data/campaign_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CampaignCard extends StatelessWidget {
  final String campaignName;
  final String description;
  final String imageAsset;
  final bool showJoinButton;

  CampaignCard({
    required this.campaignName,
    required this.description,
    required this.imageAsset,
    this.showJoinButton = true,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Image.asset(
                imageAsset,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey,
                    child: Icon(Icons.broken_image, color: Colors.white),
                  );
                },
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaignName,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14.0, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showJoinButton)
            SizedBox(height: 20),
          if (showJoinButton)
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
                  if (userEmail.isNotEmpty) {
                    final campaignData = {
                      'name': campaignName,
                      'description': description,
                      'validity': 'N/A',
                      'image': imageAsset,  // Pass image to Firestore
                    };

                    bool hasJoined = await CampaignService().hasUserJoinedCampaign(userEmail, campaignName);
                    if (!hasJoined) {
                      await CampaignService().joinCampaign(userEmail, campaignData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You have successfully joined $campaignName!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You have already joined $campaignName.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please log in to join the campaign.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFB2626),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Join Now', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
