import 'package:flutter/material.dart';
import 'package:utm_courtify/pages/user/history_screen.dart';
import 'package:utm_courtify/pages/user/customer_support_screen.dart';
import 'package:utm_courtify/pages/user/emergency_contacts_screen.dart';
import 'package:utm_courtify/pages/booking/booking_record.dart';
import 'package:utm_courtify/data/user_data/firebase_profile_service.dart';


class DatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final bool isEditable;
  final Function(DateTime) onDateSelected;

  DatePickerField({
    required this.controller,
    required this.isEditable,
    required this.onDateSelected,
  });

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    
    // Parse initial date from controller
    try {
      selectedDate = DateTime.parse(widget.controller.text);
    } catch (e) {
      selectedDate = DateTime.now().subtract(Duration(days: 365 * 18)); // Default to 18 years ago
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFFFB2626),
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[850],
          ),
          child: DatePickerDialog(
            initialDate: selectedDate ?? DateTime.now().subtract(Duration(days: 365 * 18)),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            initialCalendarMode: DatePickerMode.year, // Start with year selection
          ),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = picked.toIso8601String().split('T')[0];
        widget.onDateSelected(picked);
      });
    }
  }

  String get formattedDate {
    if (selectedDate == null) return 'Select Date';
    return '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';
  }

  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isEditable ? () => _selectDate(context) : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.cake, color: Color(0xFFFB2626), size: 20),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold , color: Colors.white),
                  ),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.isEditable ? Theme.of(context).primaryColor : Colors.white,
                        ),
                      ),
                      if (selectedDate != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '(${calculateAge(selectedDate!)} years old)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (widget.isEditable)
              Icon(Icons.calendar_today, color: Color(0xFFFB2626), size: 20),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
  final ProfileService _profileService = ProfileService();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  
  // Controllers for editable fields
  final _nameController = TextEditingController(text: "CHAN Qing Yee");
  final _dobController = TextEditingController(text: "1995-08-15");
  final _emailController = TextEditingController(text: "qingyee0219@gmail.com");
  final _phoneController = TextEditingController(text: "+60137339035");
  final _bioController = TextEditingController(text: "Badminton lover and enthusiast.");

  String _selectedGender = "Male";
  
  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Recent bookings data (example)
  List<Map<String, dynamic>> recentBookings = [
    {'court': 'Court 1', 'date': '2024-12-31', 'time': '8:00 AM'},
    {'court': 'Court 1', 'date': '2025-01-01', 'time': '9:00 AM'},
  ];


Future<void> _loadUserProfile() async {
  try {
    final userData = await widget._profileService.getCurrentUserProfile();
    if (userData != null) {
      setState(() {
        _nameController.text = userData['displayName'] ?? '';
        _selectedGender = userData['gender'] ?? 'Male';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phoneNumber'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        
        if (userData['dateOfBirth'] != null) {
          _selectedDate = DateTime.parse(userData['dateOfBirth']);
          _dobController.text = _selectedDate!.toIso8601String();
        }
      });
    }
  } catch (e) {
    _showErrorSnackBar('Failed to load profile data');
  }
}

  Future<void> _loadRecentBookings() async {
    try {
      final bookings = await widget._profileService.getRecentBookings(limit: 3);
      setState(() {
        recentBookings = bookings;
      });
    } catch (e) {
      print('Failed to load recent bookings: $e');
      // Optionally show a snackbar or handle the error
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 8, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFFFB2626),
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    try {
      _selectedDate = DateTime.parse(_dobController.text);
    } catch (e) {
      _selectedDate = DateTime.now().subtract(Duration(days: 365 * 18));
      _dobController.text = _selectedDate!.toIso8601String().split('T')[0];
    }

    _loadUserProfile();
}
    

void _saveChanges() async {

  if (_nameController.text.isEmpty) {
      _showErrorSnackBar("Name cannot be empty");
      return;
    }

  try {
    await widget._profileService.updateProfile(
      displayName: _nameController.text,
      gender: _selectedGender,
      dateOfBirth: _selectedDate,
      phoneNumber: _phoneController.text,
      bio: _bioController.text,
    );
    
    setState(() => _isEditing = false);
    _showSuccessSnackBar("Profile updated successfully!");
  } catch (e) {
    _showErrorSnackBar(e.toString());
  }
}

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text("Logout", style: TextStyle(color: Color(0xFFFB2626))),
          ),
        ],
      ),
    );
  }

Widget _buildProfileHeader() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFFB2626), Color(0xFF8B0000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Animated background circle
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Profile avatar
            Hero(
              tag: 'profile-avatar',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join('')
                        : 'U',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFFFB2626),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (_isEditing)
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: "Display Name",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (value) {
                // Add your submit logic here
              },
            ),
          )
        else
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : "User Name",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 20,
            ),
            SizedBox(width: 4),
            Text(
              "969 Points",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildBookingHistory() {
  return Container(
    margin: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black, // Set background to black
      borderRadius: BorderRadius.circular(12), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.redAccent.withOpacity(0.3), // Red neon glow
          blurRadius: 20, // Glow effect size
          spreadRadius: 5, // Spread effect size
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Bookings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingRecord()),
                  );
                },
                child: Text(
                  "Show more",
                  style: TextStyle(color: Color(0xFFFB2626)), // Red accent colour
                ),
              ),
            ],
          ),
        ),
        if (recentBookings.isEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "No recent bookings",
                style: TextStyle(color: Colors.grey), // Grey text for no data
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentBookings.length,
            itemBuilder: (context, index) {
              final booking = recentBookings[index];
              return ListTile(
                leading: Icon(
                  Icons.sports_tennis,
                  color: Color(0xFFFB2626), // Red accent for icons
                ),
                title: Text(
                  booking['court'],
                  style: TextStyle(color: Colors.white), // White text for title
                ),
                subtitle: Text(
                  "${booking['date']} at ${booking['time']}",
                  style: TextStyle(color: Colors.grey), // Grey text for subtitle
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'cancel') {
                      _showCancelBookingDialog(booking);
                    } else if (value == 'reschedule') {
                      _showRescheduleBookingDialog(booking);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'cancel',
                      child: Text(
                        'Cancel Booking',
                        style: TextStyle(color: Colors.white), // White text
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'reschedule',
                      child: Text(
                        'Reschedule',
                        style: TextStyle(color: Colors.white), // White text
                      ),
                    ),
                  ],
                  color: Colors.black, // Black background for popup menu
                ),
              );
            },
          ),
      ],
    ),
  );
}


void _showCancelBookingDialog(Map<String, dynamic> booking) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel your booking for ${booking['court']} on ${booking['date']} at ${booking['time']}?'),
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
              // TODO: Implement actual cancellation logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

void _showRescheduleBookingDialog(Map<String, dynamic> booking) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Reschedule Booking'),
        content: Text('Reschedule feature for ${booking['court']} is coming soon.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget _buildProfileDetails() {
  return Container(
    margin: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black, // Set the background colour to black
      borderRadius: BorderRadius.circular(12), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.redAccent.withOpacity(0.3), // Red neon glow
          blurRadius: 20, // Glow effect size
          spreadRadius: 5, // Spread effect size
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text
            ),
          ),
          SizedBox(height: 16),
          DatePickerField(
            controller: _dobController,
            isEditable: _isEditing,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
          ),
          _buildDetailField(
            icon: Icons.person,
            label: "Gender",
            value: _selectedGender,
            isDropdown: _isEditing,
          ),
          _buildDetailField(
            icon: Icons.email,
            label: "Email",
            value: _emailController.text,
            controller: _emailController,
            isEditable: _isEditing,
          ),
          _buildDetailField(
            icon: Icons.phone,
            label: "Phone",
            value: _phoneController.text,
            controller: _phoneController,
            isEditable: _isEditing,
          ),
          _buildDetailField(
            icon: Icons.info,
            label: "Bio",
            value: _bioController.text,
            controller: _bioController,
            isEditable: _isEditing,
            maxLines: 3,
          ),
        ],
      ),
    ),
  );
}

Widget _buildDetailField({
  required IconData icon,
  required String label,
  required String value,
  TextEditingController? controller,
  bool isEditable = false,
  bool isDropdown = false,
  int? maxLines,
  VoidCallback? onTap,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Color(0xFFFB2626), // Red icon for dark theme
          size: 24, // Slightly larger icon for better visibility
        ),
        SizedBox(width: 16),
        Expanded(
          child: isEditable
              ? TextField(
                  controller: controller,
                  maxLines: maxLines ?? 1,
                  style: TextStyle(
                    color: Colors.white, // White text for input
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(
                      color: Colors.white, // Subtle white for labels
                      fontSize: 14,
                    ),
                    isDense: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red), // Red underline
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red), // Focused underline
                    ),
                  ),
                )
              : isDropdown
                  ? DropdownButton<String>(
                      value: value,
                      dropdownColor: Colors.black, // Dropdown menu background
                      style: TextStyle(
                        color: Colors.white, // White text for dropdown items
                      ),
                      items: ["Male", "Female"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        // Handle dropdown change here
                      },
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Subtle white for label
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          value,
                          style: TextStyle(
                            color: Colors.white, // White text for value
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            ),
            centerTitle: true,
            backgroundColor: Color.fromRGBO(251, 38, 38, 1),
            title: Text(
              "Profile", 
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                ),
            ),
            leading: IconButton(onPressed: (){Navigator.pushNamed(context, '/home');}, icon: Icon(Icons.arrow_back)), 
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: _isEditing ? _saveChanges : () => setState(() => _isEditing = true),
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _showLogoutDialog,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildProfileDetails(),
                _buildBookingHistory(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFB2626),
        child: Icon(Icons.support_agent, color: Colors.white,),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              decoration: BoxDecoration(
                 color: Colors.black, // Set background to black
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.support, color: Color(0xFFFB2626)),
                    title: Text(
                      "Customer Support",
                      style: TextStyle(color: Colors.white),
                     ), // Set text colour to white),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerSupportScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_hospital, color: Color(0xFFFB2626)),
                    title: Text(
                      "Emergency Contact",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmergencyContactScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
