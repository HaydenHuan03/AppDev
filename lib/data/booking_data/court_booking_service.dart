import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourtBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return {
            'userId': user.uid,
            'userName': userDoc.data()?['displayName'] ?? 'Unknown User',
            'userEmail': user.email,
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<bool> bookCourt({
    required String courtId,
    required String courtName,
    required DateTime bookingDate,
    required String timeSlot,
    required String userId
  }) async {
    try {
      final userData = await _getCurrentUserData();
      if (userData == null) {
        throw Exception('User data not found');
      }
      final normalizedDate = DateTime(
        bookingDate.year, 
        bookingDate.month, 
        bookingDate.day
      );

      final bookingQuery = await _firestore
          .collection('court_bookings')
          .where('courtId', isEqualTo: courtId)
          .where('timeSlot', isEqualTo: timeSlot)
          .where('bookingDate', isEqualTo: normalizedDate)
          .where('status', isEqualTo: 'active')
          .get();

      if (bookingQuery.docs.isNotEmpty) {
        throw Exception('Court is already booked for the selected time slot');// Court is already booked for the selected time slot
      }

      await _firestore.collection('court_bookings').add({
        'courtId': courtId,
        'courtName': courtName,
        'bookingDate': normalizedDate,
        'timeSlot': timeSlot,
        'bookingUserName': userData['userName'],
        'userId': userId,
        'bookingTimestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
      return true;
    } catch (e) {
      print('Booking error: $e');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final userData = await _getCurrentUserData();

      if (userData == null) {
        throw Exception('User data not found');
      }

      final bookingDoc = await _firestore
          .collection('court_bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;

      if (bookingData['bookingUserName'] != userData['userName']) {
        throw Exception('You are not authorized to cancel this booking');
      }

      await _firestore
        .collection('court_bookings')
        .doc(bookingId)
        .update({
          'status': 'cancelled',
          'cancellationTimestamp': FieldValue.serverTimestamp(),
          'cancellationUserName': userData['userName'],
        });
        
      return true;
    } catch (e) {
      print('Cancel booking error: $e');
      return false;
    }
  }

  Future<bool> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    try {
      final userData = await _getCurrentUserData();

      if (userData == null) {
        throw Exception('User data not found');
      }
      // Start a transaction to ensure data consistency
      return await _firestore.runTransaction<bool>((transaction) async {
        // Get the existing booking
        final bookingDoc = await transaction.get(
          _firestore.collection('court_bookings').doc(bookingId)
        );
        
        if (!bookingDoc.exists) {
          throw Exception('Booking not found');
        }

        final bookingData = bookingDoc.data() as Map<String, dynamic>;
        
        // Check if the new slot is available
        final conflictQuery = await _firestore
            .collection('court_bookings')
            .where('courtId', isEqualTo: bookingData['courtId'])
            .where('timeSlot', isEqualTo: newTimeSlot)
            .where('bookingDate', isEqualTo: newDate)
            .where('status', isEqualTo: 'active')
            .get();

        if (conflictQuery.docs.isNotEmpty) {
          throw Exception('Selected time slot is already booked');
        }

        // Update the existing booking
        transaction.update(bookingDoc.reference, {
          'bookingDate': newDate,
          'timeSlot': newTimeSlot,
          'lastModified': FieldValue.serverTimestamp(),
          'lastModifiedBy': userData['userId'],
        });

        return true;
      });
    } catch (e) {
      print('Reschedule error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final userData = await _getCurrentUserData();
      if (userData == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('court_bookings')
          .where('status', isEqualTo: 'active')
          .where('userId', isEqualTo: userData['userId'])
          .orderBy('bookingDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  } 
}