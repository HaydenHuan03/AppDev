//Not yet include user data
import 'package:cloud_firestore/cloud_firestore.dart';

class CourtBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isCourtAvailable(String courtID, DateTime date, String timeSlot) async{
    String bookingDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final bookings = await _firestore
      .collection('bookings')
      .where('courtId', isEqualTo: courtID)
      .where('date', isEqualTo: date)
      .where('timeSlot', isEqualTo: timeSlot)
      .get();

    return bookings.docs.isEmpty;
  }

  Future<void> createBooking({
    required String courtID,
    required String courtName,
    required DateTime date,
    required String timeSlot,
  })async{
    String bookingDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    bool isAvailable = await isCourtAvailable(courtID, date, timeSlot);
    if(!isAvailable){
      throw Exception('Court is not available for selected time');
    }

    await _firestore.collection('bookings').add({
      'courtID' : courtID,
      'courtName' : courtName,
      'date' : date,
      'timeSlot' : timeSlot,
      'createdAt' : FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getBookingsForDate(DateTime date) async{
    String bookingDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try{
      final querySnapshot = await _firestore
      .collection('bookings')
      .where('date', isEqualTo: bookingDate)
      .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        'courtId' : doc['courtId'],
        'courtName' : doc['courtName'],
        'timeSlot' : doc['timeSlot'],
      }).toList();
    }catch(e){
      print('Error: $e');
      rethrow;
    }
  }

  
}