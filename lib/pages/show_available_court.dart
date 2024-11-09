import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowAvailableCourt extends StatefulWidget {
  const ShowAvailableCourt({super.key});

  @override
  State<ShowAvailableCourt> createState() => _ShowAvailableCourtState();
}

class _ShowAvailableCourtState extends State<ShowAvailableCourt> {
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  final ScrollController _scrollController = ScrollController();

  //time slots
  final List<String> timeSlots = [
    '8.00 AM',
    '9.00 AM',
    '10.00 AM',
    '11.00 AM',
    '2.00 PM',
    '3.00 PM',
    '4.00 PM',
    '5.00 PM',
  ];

  //Automatic choose the current date once user go to this page
  @override
  void initState(){
    super.initState();
    _updateSelectedDate();
    //Ensure this function is called after ListView.builder is fully built
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  void _updateSelectedDate(){
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  //Automatic locate the user screnn to the current date
  void _scrollToCurrentDate(){
    final now = DateTime.now();
    final startDate = DateTime(selectedDate.year, selectedDate.month, 1);
    final index = now.day - 3;

    _scrollController.animateTo(
      index * 100.0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.linearToEaseOut
    );
  }

  bool _isSelectedMonthInPast(DateTime date){
    final now = DateTime.now();
    return date.year < now.year || (date.year == now.year && date.month < now.month);
  }

  bool _isSelectedMonthCurrentOrFuture(DateTime date) {
  final now = DateTime.now();
  return date.year > now.year || (date.year == now.year && date.month >= now.month);
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
        backgroundColor: Color.fromRGBO(251, 38, 38, 100),
        leading: IconButton(
          onPressed: () {} , 
          icon: const Icon(Icons.arrow_back, color: Colors.white,)
          ) ,
        title: Text(
          "Book A Court", 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            ),
          ),
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
                  icon: Icon(Icons.chevron_left, color: _isSelectedMonthInPast(DateTime(selectedDate.year, selectedDate.month-1, 1)) ? Colors.grey[800] : Colors.white, size: 35),
                  onPressed: _isSelectedMonthInPast(DateTime(selectedDate.year, selectedDate.month-1, 1)) ? null : () {
                    setState(() {
                      selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month - 1,
                        selectedDate.day,
                      );
                    });
                }, 
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
                  onPressed: _isSelectedMonthCurrentOrFuture(DateTime(selectedDate.year, selectedDate.month +2, 1)) ? () {
                    setState(() {
                      selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month+1,
                        selectedDate.day,
                      );
                    });
                  } : null,
                )
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
                        selectedDate = date;
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
                          color: isSelected ? Colors.black: Colors.transparent,
                          borderRadius: BorderRadius.circular(8)
                        ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              color: isSelected ? Color.fromRGBO(251, 38, 38, 100) : isPast ? Colors.grey[800]: Colors.white,
                              fontSize: 16
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              color: isSelected ? Color.fromRGBO(251, 38, 38, 100) : isPast ? Colors.grey[800]: Colors.white,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((time){
                  final isSelected = selectedTimeSlot == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTimeSlot = time;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color : Colors.red),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.red,
                        )
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      );
    }
}