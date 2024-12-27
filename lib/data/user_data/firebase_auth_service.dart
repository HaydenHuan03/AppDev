import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new user with custom ID
  Future<Map<String, dynamic>> registerUserWithCustomId({
    required String email,
    required String password,
    required String utmId,
  }) async {
    try {
      // 1. Get the list of all existing user documents
      final usersRef = _firestore.collection('users');
      final snapshot = await usersRef.get();

      // 2. Determine the next available user index
      int nextIndex = 1;
      snapshot.docs.forEach((doc) {
        final docId = doc.id;
        if (docId.startsWith('user_')) {
          final index = int.parse(docId.split('_')[1]);
          if (index >= nextIndex) {
            nextIndex = index + 1;
          }
        }
      });

      // 3. Create the new user document with the determined index
      final newUserDocRef = usersRef.doc('user_$nextIndex');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await newUserDocRef.set({
        'email': email,
        'displayName': utmId,
        'createdAt': FieldValue.serverTimestamp(),
        'points': 0,
        'gender': 'Male',
        'dateOfBirth': null,
        'phoneNumber': '',
        'bio': '',
      });

      return {
        'success': true,
        'message': 'Registration successful',
        'userId': newUserDocRef.id,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getFirebaseAuthExceptionMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  // Register new user (original version)
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String utmId,
  }) async {
    try {
      // Check if email already exists in Firestore
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'This email is already registered.'
        };
      }

      // Create user in Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': utmId,
        'createdAt': FieldValue.serverTimestamp(),
        'points': 0,
        'gender': 'Male',
        'dateOfBirth': null,
        'phoneNumber': '',
        'bio': '',
      });

      return {
        'success': true,
        'message': 'Registration successful',
        'userId': userCredential.user!.uid,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getFirebaseAuthExceptionMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  String _getFirebaseAuthExceptionMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return 'An error occurred during registration.';
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      // Remove email from update data if it exists
      data.remove('email');
      
      await _firestore.collection('users').doc(userId).update(data);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}