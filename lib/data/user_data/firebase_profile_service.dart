import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user profile data
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting user profile: $e');
      throw Exception('Failed to fetch user profile');
    }
  }

  // Update user profile information
  Future<void> updateProfile({
    required String displayName,
    required String gender,
    required DateTime? dateOfBirth,
    required String phoneNumber,
    required String bio,
  }) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No authenticated user found');

      // Validate phone number format
      if (phoneNumber.isNotEmpty && !_isValidPhoneNumber(phoneNumber)) {
        throw Exception('Invalid phone number format');
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'displayName': displayName.trim(),
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'phoneNumber': phoneNumber.trim(),
        'bio': bio.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Update Firestore document
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updateData);

    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  //Sprint 3
  // Update specific profile field
  Future<void> updateProfileField(String field, dynamic value) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No authenticated user found');

      // Validate field name
      if (!_allowedFields.contains(field)) {
        throw Exception('Invalid field name');
      }

      // Validate phone number if updating phone
      if (field == 'phoneNumber' && value != null && value.toString().isNotEmpty) {
        if (!_isValidPhoneNumber(value.toString())) {
          throw Exception('Invalid phone number format');
        }
      }

      // Update single field
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        field: value,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Error updating profile field: $e');
      throw Exception('Failed to update profile field: ${e.toString()}');
    }
  }

  // Get user points
  Future<int> getUserPoints() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No authenticated user found');

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return 0;
      final userData = doc.data() as Map<String, dynamic>;
      return userData['points'] ?? 0;
    } catch (e) {
      print('Error getting user points: $e');
      return 0;
    }
  }

  // Helper method to validate phone number
  bool _isValidPhoneNumber(String phone) {
    // Basic validation for Malaysian phone numbers
    // Matches formats like +60123456789 or 60123456789
    final RegExp phoneRegex = RegExp(r'^(\+?6?01)[0-9]{8,9}$');
    return phoneRegex.hasMatch(phone);
  }

  // List of allowed fields for individual updates
  final Set<String> _allowedFields = {
    'displayName',
    'gender',
    'dateOfBirth',
    'phoneNumber',
    'bio',
  };

  Future<List<Map<String, dynamic>>> getRecentBookings({int limit = 5}) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No authenticated user found');

      final QuerySnapshot bookingsQuery = await _firestore
          .collection('court_bookings')
          .where('bookingUserName', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('bookingDate', descending: true)
          .limit(limit)
          .get();

      return bookingsQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'court': data['courtName'],
          'date': _formatDate(data['bookingDate']),
          'time': data['timeSlot'],
          'rawData': data, // Include full data for potential future use
        };
      }).toList();
    } catch (e) {
      print('Error fetching recent bookings: $e');
      return [];
    }
  }

  // Helper method to format date
  String _formatDate(Timestamp bookingDate) {
    final DateTime date = bookingDate.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Method to get booking history with more options
  Future<List<Map<String, dynamic>>> getBookingHistory({
    bool includeUpcoming = true,
    bool includePast = true,
    int limit = 10,
    DateTime? startDate,
  }) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No authenticated user found');

      final now = DateTime.now();
      Query query = _firestore
          .collection('court_bookings')
          .where('bookingUserName', isEqualTo: userId);

      // Filter by date range
      if (startDate != null) {
        query = query.where('bookingDate', isGreaterThanOrEqualTo: startDate);
      }

      // Filter by booking status
      if (!includeUpcoming && !includePast) {
        return []; // Return empty if no type selected
      }

      // Apply status filters
      if (includeUpcoming && !includePast) {
        query = query.where('bookingDate', isGreaterThanOrEqualTo: now);
      } else if (!includeUpcoming && includePast) {
        query = query.where('bookingDate', isLessThan: now);
      }

      // Order and limit
      query = query.orderBy('bookingDate', descending: true).limit(limit);

      final QuerySnapshot bookingsQuery = await query.get();

      return bookingsQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'court': data['courtName'],
          'date': _formatDate(data['bookingDate']),
          'time': data['timeSlot'],
          'status': _determineBookingStatus(data['bookingDate'], data['status']),
          'rawData': data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching booking history: $e');
      return [];
    }
  }

  // Helper method to determine booking status
  String _determineBookingStatus(Timestamp bookingDate, String currentStatus) {
    final DateTime date = bookingDate.toDate();
    final DateTime now = DateTime.now();

    if (currentStatus == 'cancelled') return 'Cancelled';
    
    if (date.isBefore(now)) {
      return 'Past';
    } else {
      return 'Upcoming';
    }
  }
}


