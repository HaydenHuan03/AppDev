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
}