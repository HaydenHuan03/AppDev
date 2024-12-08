import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'customer_support_screen.dart';
import 'emergency_contacts_screen.dart';
import 'package:flutter_application_1/services/firebase_profile_service.dart';


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
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.isEditable ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      if (selectedDate != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '(${calculateAge(selectedDate!)} years old)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
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
  final List<Map<String, dynamic>> recentBookings = [
    {'court': 'Court A1', 'date': '2024-03-15', 'time': '10:00 AM'},
    {'court': 'Court B2', 'date': '2024-03-12', 'time': '2:00 PM'},
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFB2626), Color(0xFF8B0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
            child: Text(
              _nameController.text.split(' ').map((e) => e[0]).join(''),
              style: TextStyle(fontSize: 30, color: Color(0xFFFB2626)),
            ),
          ),
          SizedBox(height: 16),
          _isEditing
              ? TextField(
                  controller: _nameController,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    labelText: "Display Name",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                )
              : Text(
                  _nameController.text,
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
          Text(
            "969 Points",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHistory() {
    return Card(
      margin: EdgeInsets.all(16),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                  child: Text(
                    "Show more",
                    style: TextStyle(color: Color(0xFFFB2626)),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentBookings.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.sports_tennis, color: Color(0xFFFB2626)),
                title: Text(recentBookings[index]['court']),
                subtitle: Text("${recentBookings[index]['date']} at ${recentBookings[index]['time']}"),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Personal Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        children: [
          Icon(icon, color: Color(0xFFFB2626), size: 20),
          SizedBox(width: 16),
          Expanded(
            child: isEditable
                ? TextField(
                    controller: controller,
                    maxLines: maxLines ?? 1,
                    decoration: InputDecoration(
                      labelText: label,
                      isDense: true,
                    ),
                  )
                : isDropdown
                    ? DropdownButton<String>(
                        value: _selectedGender,
                        items: ["Male", "Female"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => _selectedGender = newValue!);
                        },
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(value),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
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
        child: Icon(Icons.support_agent),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.support, color: Color(0xFFFB2626)),
                    title: Text("Customer Support"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerSupportScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_hospital, color: Color(0xFFFB2626)),
                    title: Text("Emergency Contact"),
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
