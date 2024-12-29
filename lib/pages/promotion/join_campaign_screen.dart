import 'package:flutter/material.dart';
import 'package:utm_courtify/data/promotion_data/campaign_service.dart';
import 'package:utm_courtify/widgets/navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utm_courtify/widgets/campaign_card.dart';

class JoinCampaignScreen extends StatefulWidget {
  @override
  _JoinCampaignScreenState createState() => _JoinCampaignScreenState();
}

class _JoinCampaignScreenState extends State<JoinCampaignScreen> {
  int _selectedIndex = 0;
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";

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
          ),
        ),
        title: Text(
          'Campaign',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFB2626),
      ),
      body: Column(
        children: [
          ToggleButtonsSection(
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                ListOfCampaign(),
                MyCampaign(userEmail: userEmail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListOfCampaign extends StatelessWidget {
  final Map<String, String> campaignImageMap = {
    'Longest Rally Challenge': 'assets/images/Promotion/longest-rally-challenge.png',
    'Fastest Smash Challenge': 'assets/images/Promotion/fastest-smash-challenge.png',
    'Best Trick Shot Contest': 'assets/images/Promotion/best-trick-shot.png',
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
            final imageAsset = campaignImageMap[campaignName] ?? 'assets/images/default_image.jpg';

            return CampaignCard(
              campaignName: campaign['name'],
              description: campaign['description'],
              imageAsset: imageAsset,
            );
          },
        );
      },
    );
  }
}

class MyCampaign extends StatelessWidget {
  final String userEmail;
  final Map<String, String> campaignImageMap = {
    'Longest Rally Challenge': 'assets/images/Promotion/longest-rally-challenge.png',
    'Fastest Smash Challenge': 'assets/images/Promotion/fastest-smash-challenge.png',
    'Best Trick Shot Contest': 'assets/images/Promotion/best-trick-shot.png',
  };

  MyCampaign({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: CampaignService().fetchUserCampaigns(userEmail),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("You haven't joined any campaigns"));
        }
        final joinedCampaigns = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: joinedCampaigns.length,
          itemBuilder: (context, index) {
            final campaign = joinedCampaigns[index];
            final campaignName = campaign['name'];
            final imageAsset = campaignImageMap[campaignName] ?? 'assets/images/default_image.jpg';

            return CampaignCard(
              campaignName: campaign['name'],
              description: campaign['description'],
              imageAsset: imageAsset,
              showJoinButton: false,
            );
          },
        );
      },
    );
  }
}

class ToggleButtonsSection extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  ToggleButtonsSection({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFFFB2626), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? Color(0xFFFB2626) : Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('List of Campaigns', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? Color(0xFFFB2626) : Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('My Campaigns', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
