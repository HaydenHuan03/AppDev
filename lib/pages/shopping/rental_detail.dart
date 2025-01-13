import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utm_courtify/data/shopping_rental_data/rental_detail_service.dart';

class RentalDetailPage extends StatefulWidget {
  final String userName; // Pass name to this page
  final String userEmail; // Pass email to this page

  const RentalDetailPage({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  _RentalDetailPageState createState() => _RentalDetailPageState();
}

class _RentalDetailPageState extends State<RentalDetailPage> {
  final RentalDetailService _rentalService = RentalDetailService();
  List<Map<String, dynamic>> rental = [];
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchRental();
  }

  // Fetch rental numbers based on user ID
  Future<void> fetchRental() async {
    List<Map<String, dynamic>> result =
        await _rentalService.fetchRentalNumbersByUserId();

    setState(() {
      rental = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 5),
            child: const Center(
              child: Text(
                'Rental Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : rental.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Color(0xFFFB2626), width: 2),
                          ),
                          child: const Text(
                            'No rental detail found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: rental.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 15, right: 15),
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 20, right: 20),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(
                                  color: Color(0xFFFB2626), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history_edu,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rental Number: ${rental[index]['rentalNumber']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rent Time: ${DateFormat('dd MMM yyyy hh:mm a').format(rental[index]['rentDate'].toDate())}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Item Returned: ${rental[index]['returnItem'] ? "Yes" : "No"}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
