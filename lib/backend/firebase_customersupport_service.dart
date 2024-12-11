import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerSupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUserSupportTickets() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getSupportTicketReplies(String ticketId) {
    return _firestore
        .collection('support_tickets')
        .doc(ticketId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<bool> closeSupportTicket(String ticketId) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': 'Closed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error closing support ticket: $e');
      return false;
    }
  }

  // Added method to store FAQs
  Future<void> storeFAQs(List<Map<String, dynamic>> faqs) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      // Clear existing FAQs first
      QuerySnapshot existingFAQs = await _firestore.collection('faqs').get();
      for (var doc in existingFAQs.docs) {
        batch.delete(doc.reference);
      }

      // Add new FAQs
      for (var faq in faqs) {
        DocumentReference docRef = _firestore.collection('faqs').doc();
        batch.set(docRef, faq);
      }

      await batch.commit();
    } catch (e) {
      print('Error storing FAQs: $e');
    }
  }

  // Added method to submit support ticket
  Future<bool> submitSupportTicket({
    required String subject, 
    required String content
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('support_tickets').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'subject': subject,
        'content': content,
        'status': 'Open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error submitting support ticket: $e');
      return false;
    }
  }
}