import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/firebase_customersupport_service.dart';

class CustomerSupportScreen extends StatefulWidget {
  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final CustomerSupportService _supportService = CustomerSupportService();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  List<FaqItem> _faqList = [];

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  void _loadFAQs() async {
    try {
      QuerySnapshot faqSnapshot = await FirebaseFirestore.instance
          .collection('faqs')
          .get();

      setState(() {
        _faqList = faqSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return FaqItem(
            question: data['question'] ?? '',
            answer: data['answer'] ?? '',
            isExpanded: false,
          );
        }).toList();

        // If no FAQs in database, use default FAQs
        if (_faqList.isEmpty) {
          _faqList = _getDefaultFAQs();
          _supportService.storeFAQs(_faqList.map((faq) => {
            'question': faq.question,
            'answer': faq.answer
          }).toList());
        }
      });
    } catch (e) {
      print('Error loading FAQs: $e');
      setState(() {
        _faqList = _getDefaultFAQs();
      });
    }
  }

  List<FaqItem> _getDefaultFAQs() {
    return [
      FaqItem(
        question: "How do I create an account?",
        answer: "Navigate to the \"Register page\", enter your UTM ID, email, and password, then follow the prompts to complete your account registration.",
      ),
      FaqItem(
      question: "How do I reset my password?",
      answer: "On the login page, click the \"Forgot Password?\" link. Enter your registered email, and you'll receive a link to reset your password.",
    ),
    FaqItem(
      question: "How do I book a badminton court?",
      answer: "Go to the \"Booking\" section, select an available time slot, and confirm your booking. You will receive a notification upon successful booking.",
    ),
    FaqItem(
      question: "Can I cancel or reschedule my booking?",
      answer: "Yes, you can cancel or reschedule your booking from the \"My Bookings\" section before the reserved time.",
    ),
    FaqItem(
      question: "How do I update my profile information?",
      answer: "Go to your profile page and click the edit button (pencil icon). Modify your details and save the changes.",
    ),
    FaqItem(
      question: "What items are available in the shopping section?",
      answer: "You can purchase badminton-related equipment such as racquets, shuttlecocks, sports shirts, and refreshments like snacks and drinks.",
    ),
    FaqItem(
      question: "What happens if I encounter an error during booking or payment?",
      answer: "If you face an issue, please contact us via the \"Submit Ticket\" option on the customer support page for assistance.",
    ),
    FaqItem(
      question: "Can I access UTM-Courtify without an internet connection?",
      answer: "No, UTM-Courtify requires an active internet connection to access booking, shopping, and other services.",
    ),
    FaqItem(
      question: "How do I contact customer support for urgent issues?",
      answer: "For immediate assistance, you can call our hotline at +60123456789 or submit a support ticket.",
    ),
    FaqItem(
      question: "Can I view my previous bookings?",
      answer: "Yes, you can view your booking in the \"My Profile\" section under \"My Bookings\".",
    ),
    ];
  }

  void _submitSupportTicket() async {
    if (_subjectController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    bool success = await _supportService.submitSupportTicket(
      subject: _subjectController.text,
      content: _contentController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Support ticket submitted successfully')),
      );
      _subjectController.clear();
      _contentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit support ticket')),
      );
    }
  }

  void _showSupportTicketForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Describe your issue',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitSupportTicket();
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Support"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Frequently Asked Questions",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              ExpansionPanelList(
                elevation: 1,
                expandedHeaderPadding: EdgeInsets.all(0),
                expansionCallback: (int index, bool? isExpanded) {
                  setState(() {
                    _faqList[index].isExpanded = !_faqList[index].isExpanded;
                  });
                },
                children: _faqList.map<ExpansionPanel>((FaqItem item) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          item.question,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        item.answer,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              Text(
                "Contact Us",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _showSupportTicketForm,
                  child: Text( 
                    'Contact Us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}