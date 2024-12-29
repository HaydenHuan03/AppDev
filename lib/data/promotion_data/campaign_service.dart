  import 'package:cloud_firestore/cloud_firestore.dart';

  class CampaignService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Fetch available campaigns from Firestore
    Future<List<Map<String, dynamic>>> fetchAvailableCampaigns() async {
      try {
        final QuerySnapshot snapshot = await _firestore.collection('campaign').get();
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data;
        }).toList();
      } catch (e) {
        print("Error fetching campaigns: $e");
        return [];
      }
    }

    // Fetch campaigns that the user has joined
    Future<List<Map<String, dynamic>>> fetchUserCampaigns(String userEmail) async {
      try {
        final userQuery = await _firestore.collection('users').where('email', isEqualTo: userEmail).get();
        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          final campaignQuery = await userDoc.reference.collection('joined_campaigns').get();
          return campaignQuery.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data;
          }).toList();
        }
        return [];
      } catch (e) {
        print("Error fetching user's joined campaigns: $e");
        return [];
      }
    }

    // Check if the user has already joined the campaign
    Future<bool> hasUserJoinedCampaign(String userEmail, String campaignName) async {
      try {
        final userQuery = await _firestore.collection('users').where('email', isEqualTo: userEmail).get();
        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          final campaignQuery = await userDoc.reference.collection('joined_campaigns').where('name', isEqualTo: campaignName).get();
          return campaignQuery.docs.isNotEmpty; // Returns true if the user has already joined the campaign
        }
        return false;
      } catch (e) {
        print("Error checking if user joined campaign: $e");
        return false;
      }
    }

    // Add campaign to the user's "joined_campaigns" collection
    Future<void> joinCampaign(String userEmail, Map<String, dynamic> campaign) async {
      try {
        // Check if the user has already joined this campaign
        bool hasJoined = await hasUserJoinedCampaign(userEmail, campaign['name']);
        if (hasJoined) {
          print("User has already joined this campaign.");
          return; // Do not add the campaign if the user has already joined
        }

        // Get the user document
        final userQuery = await _firestore.collection('users').where('email', isEqualTo: userEmail).get();
        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          
          // Add campaign to the "joined_campaigns" collection
          await userDoc.reference.collection('joined_campaigns').add({
            'name': campaign['name'],
            'description': campaign['description'],
            'validity': campaign['validity'],
            'joinedAt': FieldValue.serverTimestamp(),
          });
          print("Campaign successfully added to user's joined campaigns.");
        }
      } catch (e) {
        print("Error adding campaign to user's joined campaigns: $e");
      }
    }
  }
