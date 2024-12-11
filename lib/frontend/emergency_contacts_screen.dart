import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/services/firebase_emergencycontact_service.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({Key? key}) : super(key: key);

  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final EmergencyContactService _contactService = EmergencyContactService();
  Map<String, dynamic> _healthCentreInfo = {};
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHealthCentreInfo();
    _fetchEmergencyContacts();
  }

  // Fetch Health Centre Information
  Future<void> _fetchHealthCentreInfo() async {
    try {
      final info = await _contactService.getHealthCentreInfo();
      if (mounted) {
        setState(() {
          _healthCentreInfo = info;
        });
      }
    } catch (e) {
      print('Error fetching health centre info: $e');
    }
  }

  // Fetch Emergency Contacts
  void _fetchEmergencyContacts() {
    _contactService.getEmergencyContacts().listen((contacts) {
      if (mounted) {
        setState(() {
          _contacts = contacts.isEmpty 
            ? [
                EmergencyContact(
                  id: '1',
                  title: 'UTM Health Centre',
                  number: '+6 075537233',
                ),
                EmergencyContact(
                  id: '2', 
                  title: 'Emergency (24 hours)', 
                  number: '+6 075530999'
                ),
                EmergencyContact(
                  id: '3', 
                  title: 'Malaysian Emergency Services', 
                  number: '999'
                ),
              ]
            : contacts;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error fetching emergency contacts: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching $url: $e')),
      );
    }
  }

  // Reusable contact card widget
  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.number,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _launchUrl('tel:${contact.number}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red.shade900,
        elevation: 0,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.red.shade700))
        : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Centre Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _healthCentreInfo['name'] ?? 'UTM Health Centre',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _healthCentreInfo['address'] ?? 'Pusat Pentadbiran Universiti Teknologi Malaysia\n80990 Skudai, Johor',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Operating Hours:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatOperatingHours(_healthCentreInfo['operatingHours']),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Contact Cards
              ...List.generate(_contacts.length, (index) {
                return _buildContactCard(_contacts[index]);
              }),

              // Location Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl('https://www.google.com/maps/search/?api=1&query=UTM+Health+Centre'),
                  icon: const Icon(Icons.location_on),
                  label: const Text('View Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format operating hours
  String _formatOperatingHours(Map<String, dynamic>? hours) {
    if (hours == null) {
      return 'Monday - Wednesday: 8 am – 5 pm\n'
             'Thursday: 8 am – 3:30 pm\n'
             'Friday - Saturday: 8:30 am – 12:30 pm\n'
             'Sunday: 8 am – 5 pm';
    }

    return hours.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n');
  }
}