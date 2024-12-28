import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:utm_courtify/data/booking_data/court_booking_service.dart';
import 'package:utm_courtify/data/booking_data/court_service.dart';

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
    
    final querySnapshot = await FirebaseFirestore.instance
        .collection('court_bookings')
        .where('status', isEqualTo: 'active')
        .orderBy('bookingDate', descending: true)
        .get();
    
    setState(() {
      final allBookings = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      _upcomingBookings = allBookings.where((booking) {
        try {
          final bookingDate = (booking['bookingDate'] as Timestamp).toDate();
          final timeSlot = booking['timeSlot'] as String;
          
          // Parse using exact format "h.mma"
          final parsedTime = DateFormat('h.mma').parse(timeSlot);
          
          final bookingDateTime = DateTime(
            bookingDate.year,
            bookingDate.month,
            bookingDate.day,
            parsedTime.hour,
            parsedTime.minute,
          );
          
          return bookingDateTime.isAfter(now);
        } catch (e) {
          print('Error processing upcoming booking: $e');
          print('Problematic time slot: ${booking['timeSlot']}');
          return false;
        }
      }).toList();

      _pastBookings = allBookings.where((booking) {
        try {
          final bookingDate = (booking['bookingDate'] as Timestamp).toDate();
          final timeSlot = booking['timeSlot'] as String;
          
          // Parse using exact format "h.mma"
          final parsedTime = DateFormat('h.mma').parse(timeSlot);
          
          final bookingDateTime = DateTime(
            bookingDate.year,
            bookingDate.month,
            bookingDate.day,
            parsedTime.hour,
            parsedTime.minute,
          );
          
          return bookingDateTime.isBefore(now);
        } catch (e) {
          print('Error processing past booking: $e');
          print('Problematic time slot: ${booking['timeSlot']}');
          return false;
        }
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

  Future<void> _confirmReschedule(
  String bookingId,
  DateTime newDate,
  String newTimeSlot,
  ) async {
    try {
      final success = await _bookingService.rescheduleBooking(
        bookingId: bookingId,
        newDate: newDate,
        newTimeSlot: newTimeSlot,
      );
      
      Navigator.pop(context);
      
      if (success) {
        await _fetchBookingsRecords();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking rescheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reschedule booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error rescheduling booking: $e');
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

  void _showRescheduleDialog(Map<String, dynamic> booking) {
    DateTime? selectedDate;
    String? selectedTimeSlot;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Reschedule Booking'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          // Reset time slot when date changes
                          selectedTimeSlot = null;
                        });
                      }
                    },
                    child: Text(selectedDate != null 
                      ? DateFormat('dd MMM yyyy').format(selectedDate!)
                      : 'Select Date'),
                  ),
                  SizedBox(height: 16),
                  if (selectedDate != null)
                    FutureBuilder<List<String>>(
                      future: CourtService().getTimeSLots(selectedDate: selectedDate),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();
                        
                        // Filter out past time slots if the selected date is today
                        List<String> availableSlots = snapshot.data!;
                        if (selectedDate?.day == DateTime.now().day &&
                            selectedDate?.month == DateTime.now().month &&
                            selectedDate?.year == DateTime.now().year) {
                          availableSlots = availableSlots.where((slot) {
                            try {
                              final now = DateTime.now();
                              final parsedTime = DateFormat('h.mma').parse(slot);
                              final slotDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                parsedTime.hour,
                                parsedTime.minute,
                              );
                              // Add a buffer of 30 minutes
                              return slotDateTime.isAfter(now.add(Duration(minutes: 30)));
                            } catch (e) {
                              print('Error parsing time slot: $e');
                              return false;
                            }
                          }).toList();
                        }
                        
                        // If no valid slots are available
                        if (availableSlots.isEmpty) {
                          return Text(
                            'No available time slots for this date',
                            style: TextStyle(color: Colors.red),
                          );
                        }

                        return DropdownButton<String>(
                          value: selectedTimeSlot,
                          hint: Text('Select Time Slot'),
                          items: availableSlots.map((slot) {
                            return DropdownMenuItem(
                              value: slot,
                              child: Text(slot),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedTimeSlot = value);
                          },
                        );
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: (selectedDate != null && selectedTimeSlot != null)
                    ? () {
                        // Final validation before confirming reschedule
                        final now = DateTime.now();
                        final parsedTime = DateFormat('h.mma').parse(selectedTimeSlot!);
                        final selectedDateTime = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          parsedTime.hour,
                          parsedTime.minute,
                        );
                        
                        if (selectedDateTime.isBefore(now)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot reschedule to a past time'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        _confirmReschedule(
                          booking['id'],
                          selectedDate!,
                          selectedTimeSlot!,
                        );
                      }
                    : null,
                  child: Text('Reschedule'),
                ),
              ],
            );
          },
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
                    onPressed: () => _showRescheduleDialog(booking),
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