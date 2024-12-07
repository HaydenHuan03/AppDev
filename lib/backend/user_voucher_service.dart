import 'package:cloud_firestore/cloud_firestore.dart';

class UserVoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user points by email
  Future<int> getUserPointsByEmail(String email) async {
    try {
      final userSnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (userSnapshot.docs.isNotEmpty) {
        return userSnapshot.docs.first['points'] ?? 0;
      } else {
        return 0; // Return 0 if the user doesn't exist
      }
    } catch (e) {
      print("Error fetching user points by email: $e");
      return 0;
    }
  }

  // Redeem a voucher and update points
  Future<void> redeemVoucherByEmail(String email, Map<String, dynamic> voucher, int userPoints) async {
    final requiredPoints = int.parse(voucher['points'].toString());

    try {
      // Start transaction
      await _firestore.runTransaction((transaction) async {
        final userQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();

        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          final newPoints = userPoints - requiredPoints;

          // Update user points
          transaction.update(userDoc.reference, {'points': newPoints});

          // Add the redeemed voucher to user's vouchers collection
          await _firestore.collection('users').doc(userDoc.id).collection('vouchers').add({
            'voucherId': voucher['voucherId'],
            'value': voucher['value'],
            'validity': voucher['validity'], // Keep the validity as a string
            'redeemedAt': Timestamp.now(), // Record the redemption timestamp
          });
        }
      });
    } catch (e) {
      print("Error redeeming voucher: $e");
    }
  }

  // Fetch vouchers from Firestore
  Future<List<Map<String, dynamic>>> fetchVouchers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('vouchers').get();
      // Return a list of vouchers as maps
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching vouchers: $e");
      return [];
    }
  }
}

