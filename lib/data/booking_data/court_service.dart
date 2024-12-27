import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CourtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getActiveCourts({
    DateTime? selectedDate,
    String? selectedTimeSlot,
  }) async {
    try {
      if(selectedDate == null || selectedTimeSlot == null) {
        throw ArgumentError('Both selectedDate and selectedTimeSlot must be provided.');
      }

      final normalizedDate = DateTime(
        selectedDate.year, 
        selectedDate.month, 
        selectedDate.day
      );

      // First, get all active courts from the courts collection
      final QuerySnapshot courtSnapshot = await _firestore
          .collection('courts')
          .where('isActive', isEqualTo: true)
          .where('courtName', isNotEqualTo: null)
          .get();

      // Check for existing bookings for the selected date and time slot
      final bookedCourtsQuery = await _firestore
          .collection('court_bookings')
          .where('bookingDate', isEqualTo: normalizedDate)
          .where('timeSlot', isEqualTo: selectedTimeSlot)
          .where('status', isEqualTo: 'active')
          .get();

    // Create a set of booked court IDs
    final bookedCourtIds = bookedCourtsQuery.docs
        .map((doc) => doc['courtId'] as String)
        .toSet();
        print(bookedCourtIds);

      // Filter courts that are active and not booked
      return courtSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>; 
          return {
            'id': doc.id,
            'name': data['courtName'] ?? 'Unnamed Court',
            'isActive': data['isActive'] ?? true,
            'maxPlayers': data['maxPlayers'] ?? 0,

          };
        })
        .where((court) => !bookedCourtIds.contains(court['id']))
        .toList();
    } catch (e) {
      print('Error from gaining courts: $e');
      return [];
    }
  }

Future<List<String>> getTimeSLots({
    DateTime? selectedDate,
  }) async {
    try {
      // First, get all active time slots
      final QuerySnapshot slotSnapshot = await _firestore
        .collection('time_slots')
        .where('isActive', isEqualTo: true)
        .orderBy('orderIndex')
        .get();

      // If no date is provided, return all active time slots
      if (selectedDate == null) {
        return slotSnapshot.docs
          .map((doc) => (
            doc.data() as Map<String, dynamic>
          )['slot'] as String).toList();
      }

      // Get all active courts
      final QuerySnapshot courtSnapshot = await _firestore
          .collection('courts')
          .where('isActive', isEqualTo: true)
          .get();

      // If no courts are available, return an empty list
      if (courtSnapshot.docs.isEmpty) {
        return [];
      }

      // Get the IDs of all active courts
      final activeCourtsIds = courtSnapshot.docs.map((doc) => doc.id).toList();

      // Check bookings for the selected date
      final bookedSlotsQuery = await _firestore
          .collection('court_bookings')
          .where('bookingDate', isEqualTo: Timestamp.fromDate(selectedDate))
          .where('status', isEqualTo: 'active')
          .get();

      // Get the booked court IDs for this date
      final bookedCourtIds = bookedSlotsQuery.docs
          .map((doc) => doc['courtId'] as String)
          .toSet();

      // Find available courts for each time slot
      final List<String> availableTimeSlots = [];

      for (var slot in slotSnapshot.docs) {
        final slotData = slot.data() as Map<String, dynamic>;
        final slotName = slotData['slot'] as String;

        // Check if there are any available courts for this slot
        final availableCourtsForSlot = activeCourtsIds
            .where((courtId) => !bookedCourtIds.contains(courtId))
            .toList();

        // If there are available courts for this slot, add it to available time slots
        if (availableCourtsForSlot.isNotEmpty) {
          availableTimeSlots.add(slotName);
        }
      }

      return availableTimeSlots;

    } catch (e) {
      print('Error from gaining time slots: $e');
      rethrow;
    }
  }
}