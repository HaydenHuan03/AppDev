import 'package:cloud_firestore/cloud_firestore.dart';

// Moved EmergencyContact class to top-level
class EmergencyContact {
  final String id;
  final String title;
  final String number;

  EmergencyContact({
    required this.id,
    required this.title,
    required this.number,
  });

  // Convert Firestore document to EmergencyContact object
  factory EmergencyContact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EmergencyContact(
      id: doc.id,
      title: data['title'] ?? '',
      number: data['number'] ?? '',
    );
  }

  // Convert EmergencyContact to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'number': number,
    };
  }
}

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all emergency contacts
  Stream<List<EmergencyContact>> getEmergencyContacts() {
    return _firestore
        .collection('emergency_contacts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyContact.fromFirestore(doc))
            .toList());
  }

  // Add a new emergency contact
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    await _firestore
        .collection('emergency_contacts')
        .add(contact.toMap());
  }

  // Update an existing emergency contact
  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    await _firestore
        .collection('emergency_contacts')
        .doc(contact.id)
        .update(contact.toMap());
  }

  // Delete an emergency contact
  Future<void> deleteEmergencyContact(String contactId) async {
    await _firestore
        .collection('emergency_contacts')
        .doc(contactId)
        .delete();
  }

  // Get Health Centre Information
  Future<Map<String, dynamic>> getHealthCentreInfo() async {
    DocumentSnapshot doc = await _firestore
        .collection('health_centre_info')
        .doc('utm_health_centre')
        .get();
    
    return doc.data() as Map<String, dynamic>;
  }
}