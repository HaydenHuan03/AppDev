import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:utm_courtify/data/booking_data/court_service.dart';
import 'package:utm_courtify/pages/booking/booking_screen.dart';
import 'package:utm_courtify/widgets/navigation_bar.dart';
import 'package:utm_courtify/pages/booking/booking_record.dart';

class ShowAvailableCourt extends StatefulWidget {
  const ShowAvailableCourt({super.key});

  @override
  State<ShowAvailableCourt> createState() => _ShowAvailableCourtState();
}

class _ShowAvailableCourtState extends State<ShowAvailableCourt> {
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _courtScrollController = ScrollController();
  final CourtService _courtService = CourtService();

  List<Map<String, dynamic>> courts = [];
  List<String> timeSlots = [];
  bool isLoading = true;

  //Automatic choose the current date once user go to this page
  @override
  void initState(){
    super.initState();
    _updateSelectedDate();
    _loadInitialData();

    //Ensure this function is called after ListView.builder is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  //New function to load timeslot data from firebase
  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    
    try {
      final timeSlotData = await _courtService.getTimeSLots();
      setState(() {
        timeSlots = timeSlotData;
      });

      // Find the first valid future time slot
      String? validTimeSlot;
      for (String slot in timeSlots) {
        if (isTimeSlotValid(slot)) {
          validTimeSlot = slot;
          break;
        }
      }

      // Update selectedTimeSlot if necessary
      if (selectedTimeSlot == null || !isTimeSlotValid(selectedTimeSlot!)) {
        selectedTimeSlot = validTimeSlot;
      }

      // Load courts if we have a valid time slot
      if (selectedTimeSlot != null && isTimeSlotValid(selectedTimeSlot!)) {
        final courtsData = await _courtService.getActiveCourts(
          selectedDate: selectedDate,
          selectedTimeSlot: selectedTimeSlot,
        );

        setState(() {
          courts = courtsData;
          isLoading = false;
        });
      } else {
        setState(() {
          courts = [];
          isLoading = false;
        });
      }
    }catch(e){
      print('Error loading initial data: $e');
      setState(() => isLoading = false);
    }
  }

    bool isTimeSlotValid(String timeSlot) {
    final parsedTime = DateFormat('h.mma').parse(timeSlot);
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );
    return !selectedDateTime.isBefore(DateTime.now());
  }

  bool areAllTimeSlotsPast() {
    final now = DateTime.now();
    
    return timeSlots.every((time) {
      final parsedTime = DateFormat('h.mma').parse(time);
      final selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
      return selectedDateTime.isBefore(now);
    });
  }

  void _updateAvailableCourt(){
    _loadInitialData();
  }

  void _updateSelectedDate(){
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  //Automatic locate the user screen to the current date
  void _scrollToCurrentDate(){
    final now = DateTime.now();
    final index = now.day-6;

    _scrollController.animateTo(
      index * 100.0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.linearToEaseOut
    );
  }

  //scroll method to handle first day of the month
  void _scrollToSelectedDate(DateTime date) {
    final targetDay = date.day;
    
    _scrollController.animateTo(
      (targetDay - 3) * 100.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut
    );
  }

  //Check and get the valid date when users switch between the months
  DateTime _getValidDateForMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final now = DateTime.now();
    
    // If first day is in the past, return today's date
    if (firstDayOfMonth.isBefore(DateTime(now.year, now.month, now.day))) {
      return DateTime(now.year, now.month, now.day);
    }
    
    return firstDayOfMonth;
  }

  void _goToNextMonth() {
    if (_isSelectedMonthCurrentOrFuture(DateTime(selectedDate.year, selectedDate.month + 2, 1))) {
      setState(() {
        selectedDate = _getValidDateForMonth(
          DateTime(selectedDate.year, selectedDate.month + 1, 1)
        );
        selectedTimeSlot = timeSlots[0];
      });
      
      // Scroll to the selected date after state update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate(selectedDate);
      });
    }
  }

/// Navigates to the previous month, updating the selected date to a valid date
/// within that month. If the previous month is in the past, the function does
/// nothing. After updating the state, it scrolls to the selected date.

  void _goToPreviousMonth() {
    if (!_isSelectedMonthInPast(DateTime(selectedDate.year, selectedDate.month - 1, 1))) {
      setState(() {
        selectedDate = _getValidDateForMonth(
          DateTime(selectedDate.year, selectedDate.month - 1, 1)
        );
        selectedTimeSlot = timeSlots[0];
      });
      
      // Scroll to the selected date after state update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate(selectedDate);
      });
    }
  }

  void _selectDate(DateTime date) {
    if (!date.isBefore(DateTime.now()) || date.day == DateTime.now().day) {
      setState(() {
        selectedDate = date;
        // Initialise time slot selection to first one
      if (selectedTimeSlot == null || !timeSlots.contains(selectedTimeSlot)) {
        selectedTimeSlot = timeSlots.isNotEmpty ? timeSlots[0] : null;
      }
      });
      _updateAvailableCourt();
    }
  }

  bool _isSelectedMonthInPast(DateTime date){
    final now = DateTime.now();
    return date.year < now.year || (date.year == now.year && date.month < now.month);
  }

  bool _isSelectedMonthCurrentOrFuture(DateTime date) {
    final now = DateTime.now();
    return date.year > now.year || (date.year == now.year && date.month >= now.month);
  }

  //Widget to control court list
  Widget _buildCourtItem(Map<String, dynamic> court) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromRGBO(251, 38, 38, 100),
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${court['name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color.fromRGBO(251, 38, 38, 100),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'UTM Sport Hall',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: Color.fromRGBO(251, 38, 38, 100),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Max ${court['maxPlayers']} players',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourtBookingScreen(
                      court: court,
                      selectedDate: selectedDate,
                      selectedTimeSlot: selectedTimeSlot,
                    )
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(251, 38, 38, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      //Calculate the days in a month
      int daysInMonth(DateTime date) {
        return DateTime(date.year, date.month + 1, 0).day;
      }

      DateTime now = DateTime.now();
      DateTime startDate = DateTime(selectedDate.year, selectedDate.month, 1);
      int numberOfDays = daysInMonth(selectedDate);
      List<int> daysList = List.generate(numberOfDays, (index) => index + 1);
      bool hasValidTimeSlot = selectedTimeSlot != null && isTimeSlotValid(selectedTimeSlot!);

    return Scaffold(
      backgroundColor: Colors.black,
      
      //App Bar
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(251, 38, 38, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          } , 
          icon: const Icon(Icons.arrow_back, color: Colors.white,)
          ) ,
        title: Text(
          "Book A Court", 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            ),
          ),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingRecord(),
                )
              );
            },
          )
        ],
      ),

      //body
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: _isSelectedMonthInPast(DateTime(selectedDate.year, selectedDate.month-1, 1))
                      ? Colors.grey[800]
                      : Colors.white,
                    size: 35
                  ),
                  onPressed: _isSelectedMonthInPast(DateTime(selectedDate.year, selectedDate.month-1, 1))
                    ? null
                    : _goToPreviousMonth,
                ),
                Text(
                  DateFormat('MMM yyyy').format(selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white, size:35),
                  onPressed: _isSelectedMonthCurrentOrFuture(DateTime(selectedDate.year, selectedDate.month +2, 1)) 
                    ? _goToNextMonth 
                    : null,
                ),
              ],
            ),
          ),

          //Date Selector
          SizedBox(
            height: 85,
            child: 
              ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: daysList.length,
                itemBuilder: (context, index){
                  final date = DateTime(startDate.year, startDate.month, daysList[index],);
                  final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(selectedDate);
                  final isPast = date.isBefore(DateTime.now()) && date.day != now.day;
                  return GestureDetector(
                    onTap: isPast ? null : () {
                      setState(() {
                        _selectDate(date);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isSelected ? Color .fromRGBO(251, 38, 38, 1) : isPast ? Colors.transparent : Colors.transparent,
                            width: isSelected ? 1 : 0
                          ),
                          color: isSelected ? Color.fromRGBO(251, 38, 38, 1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(25)
                        ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              color: isPast? Colors.grey[800] : isSelected ? Colors.white : Color.fromRGBO(251, 38, 38, 1),
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              color: isPast 
                    ? Colors.grey[800]
                    : isSelected 
                      ? Colors.white 
                      : Color.fromRGBO(251, 38, 38, 1),
                      fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),

            //Time Slot Title
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                'Time Slot',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
            
            //Time Slots Grid Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 17,
                crossAxisSpacing: 17,
                childAspectRatio: 2.0,
                physics: NeverScrollableScrollPhysics(),
                children: timeSlots.map((time) {
                  final now = DateTime.now();
                // Parse the time slot with a 12-hour format
                  final parsedTime = DateFormat('h.mma').parse(time);

                  // Combine the parsed time with the selected date
                  final selectedDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    parsedTime.hour,
                    parsedTime.minute,
                  );
                  final isPast = selectedDateTime.isBefore(now);
                  final isSelected = selectedTimeSlot == time && !isPast;
                  return GestureDetector(
                    onTap: isPast? null : () {
                      setState(() {
                        selectedTimeSlot = time;
                      });
                      _updateAvailableCourt();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPast? Colors.grey[800] : isSelected ? Color.fromRGBO(251, 38, 38, 1) : Colors.transparent,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(25),
                        border: isPast? Border.all(color: Colors.transparent) : Border.all(
                          color: Color.fromRGBO(251, 38, 38, 1),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isPast ? Colors.black : isSelected ? Colors.white : Color.fromRGBO(251, 38, 38, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            ),

            //Available Court Title
         if (hasValidTimeSlot) ...[
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Center(
                child: Text(
                  'Available Courts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),
            Expanded(
              child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(251, 38, 38, 1),
                    ),
                  )
                : ListView.builder(
                    controller: _courtScrollController,
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      return _buildCourtItem(courts[index]);
                    }
                  ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.access_time,
                      size: 64,
                      color: Color.fromRGBO(251, 38, 38, 1),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Available Courts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please select a future time slot',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        initialIndex: 0,
      ),
    );
  }
}