import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:utm_courtify/data/court_booking_service.dart';

class BookingRecord extends StatefulWidget {
  const BookingRecord({super.key});

  @override
  State<BookingRecord> createState() => _BookingRecordState();
}

class _BookingRecordState extends State<BookingRecord> {
  final CourtBookingService _bookingService = CourtBookingService();
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _pastBookings = [];
  bool _isLoading = true;
  
  // Add a tab controller for switching between upcoming and past bookings
  int _currentTabIndex = 0;

  @override 
  void initState() {
    super.initState();
    _fetchBookingsRecords();
  }

  Future<void> _fetchBookingsRecords() async {
    try {
      final now = DateTime.now();
      final normalizedNow = DateTime(now.year, now.month, now.day);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('court_bookings')
          .where('status', isEqualTo: 'active')
          .orderBy('bookingDate', descending: true)
          .get();
      
      setState(() {
        // Separate bookings into upcoming and past
        final allBookings = querySnapshot.docs.map((doc){
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();

        _upcomingBookings = allBookings.where((booking) {
          final bookingDate = (booking['bookingDate'] as Timestamp).toDate();
          return bookingDate.isAfter(normalizedNow.subtract(const Duration(days: 1)));
        }).toList();

        _pastBookings = allBookings.where((booking) {
          final bookingDate = (booking['bookingDate'] as Timestamp).toDate();
          return bookingDate.isBefore(normalizedNow);
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar( 
        SnackBar(
          content: Text('Error fetching bookings: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      final success = await _bookingService.cancelBooking(bookingId);
      if (success) {
        await _fetchBookingsRecords();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking canceled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),  
        );
      }
    } catch (e) {
      print('Error cancelling booking: $e');      
    }
  }

  void _showCancelConfirmationDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(bookingId);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isPastBooking) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isPastBooking ? Colors.grey[800] : Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${booking['courtName']}',
                  style: TextStyle(
                    color: isPastBooking ? Colors.white54 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(
                    (booking['bookingDate'] as Timestamp).toDate()
                  ),
                  style: TextStyle(
                    color: isPastBooking ? Colors.white38 : Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Time Slot: ${booking['timeSlot']}',
              style: TextStyle(
                color: isPastBooking ? Colors.white54 : Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Booked by: ${booking['bookingUserName']}',
              style: TextStyle(
                color: isPastBooking ? Colors.white38 : Colors.white70,
                fontSize: 14,
              ),
            ),
            if (!isPastBooking) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement reschedule functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reschedule feature coming soon')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Reschedule'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showCancelConfirmationDialog(booking['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(251, 38, 38, 1),
                    ),
                    child: Text('Cancel', style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Bookings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(251, 38, 38, 1),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _currentTabIndex = 0),
                child: Text(
                  'Upcoming',
                  style: TextStyle(
                    color: _currentTabIndex == 0 ? Colors.white : Colors.white54,
                    fontWeight: _currentTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15
                  ),
                ),
              ),
              SizedBox(width: 20),
              TextButton(
                onPressed: () => setState(() => _currentTabIndex = 1),
                child: Text(
                  'Past',
                  style: TextStyle(
                    color: _currentTabIndex == 1 ? Colors.white : Colors.white54,
                    fontWeight: _currentTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(251, 38, 38, 1),
              ),
            )
          : _currentTabIndex == 0
              ? _upcomingBookings.isEmpty
                  ? Center(
                      child: Text(
                        'No upcoming bookings found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _upcomingBookings.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(_upcomingBookings[index], false);
                      },
                    )
              : _pastBookings.isEmpty
                  ? Center(
                      child: Text(
                        'No past bookings found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pastBookings.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(_pastBookings[index], true);
                      },
                    ),
    );
  }
}