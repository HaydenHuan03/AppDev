import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch the user's redeemed vouchers and calculate validity date
  Future<List<Map<String, dynamic>>> fetchUserVouchers(String email) async {
    try {
      final userQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        final voucherQuery = await userDoc.reference.collection('vouchers').get();

        // Map the voucher data and calculate the validity date
        return voucherQuery.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Check if redeemedAt is not null and calculate validity
          if (data['redeemedAt'] != null) {
            DateTime redeemedAt = (data['redeemedAt'] as Timestamp).toDate();
            DateTime validityDate = redeemedAt.add(Duration(days: 30)); // Add 30 days
            data['validityDate'] = validityDate; // Store the calculated validity date
          }

          return data;
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching user vouchers: $e");
      return [];
    }
  }
}

