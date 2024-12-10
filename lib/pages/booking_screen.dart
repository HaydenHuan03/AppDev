import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utm_courtify/data/court_booking_service.dart';
import 'package:utm_courtify/data/court_service.dart';

class CourtBookingScreen extends StatefulWidget {
  final Map<String, dynamic> court;
  final DateTime selectedDate;
  final String? selectedTimeSlot;

  const CourtBookingScreen({
    super.key,
    required this.court,
    required this.selectedDate,
    required this.selectedTimeSlot,
  });

  @override
  _CourtBookingScreenState createState() => _CourtBookingScreenState();
}

class _CourtBookingScreenState extends State<CourtBookingScreen> {
  final CourtService _courtService = CourtService();
  bool _isBooking = false;

  void _confirmBooking() async {
    setState(() {
      _isBooking = true;
    });

    try {
      // TODO: Implement actual booking logic
      final bookingService = CourtBookingService();
      final booked = await bookingService.bookCourt(
        courtId: widget.court['id'],
        courtName: widget.court['name'],
        bookingDate: widget.selectedDate,
        timeSlot: widget.selectedTimeSlot!,
      );

      // Show success message
      if (booked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Court booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Handle booking errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Confirm Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromRGBO(251, 38, 38, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(),
            SizedBox(height: 20),
            _buildBookingButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    return Card(
      color: Color.fromRGBO(30, 30, 30, 1),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _buildDetailRow('Court', widget.court['name']),
            _buildDetailRow('Location', 'UTM Sport Hall'),
            _buildDetailRow('Max Players', '${widget.court['maxPlayers']} players'),
            _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(widget.selectedDate)),
            _buildDetailRow('Time Slot', widget.selectedTimeSlot ?? 'Not selected'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _isBooking ? null : () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: _isBooking ? null : _confirmBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(251, 38, 38, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isBooking
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Confirm Booking',
                style: TextStyle(color: Colors.white),
              ),
        ),
      ],
    );
  }
}