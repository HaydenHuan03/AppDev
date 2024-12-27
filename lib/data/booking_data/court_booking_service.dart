import 'package:cloud_firestore/cloud_firestore.dart';

class CourtBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> bookCourt({
    required String courtId,
    required String courtName,
    required DateTime bookingDate,
    required String timeSlot,
    String? bookingUserName,
  }) async {
    try {
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
        'bookingUserName': bookingUserName ?? 'Unknown User',
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
      await _firestore
        .collection('court_bookings')
        .doc(bookingId)
        .update({
          'status': 'cancelled',
          'cancellationTimestamp': FieldValue.serverTimestamp(),
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
        });

        return true;
      });
    } catch (e) {
      print('Reschedule error: $e');
      return false;
    }
  }
}