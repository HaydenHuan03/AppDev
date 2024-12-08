import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String utmId,
    required String password,
  }) async {
    try {
      // First, query Firestore to find the user with the given UTM ID
      final userQuery = await _firestore
          .collection('users')
          .where('displayName', isEqualTo: utmId)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return {
          'success': false,
          'message': 'No account found with this UTM ID.',
        };
      }

      // Get the email associated with the UTM ID
      final userDoc = userQuery.docs.first;
      final userEmail = userDoc.get('email') as String;

      // Attempt to sign in with email and password
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: password,
      );

      // Get additional user data from Firestore
      final userData = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return {
        'success': true,
        'message': 'Login successful',
        'user': {
          'uid': userCredential.user!.uid,
          'email': userEmail,
          'displayName': utmId,
          ...userData.data() ?? {},
        },
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getFirebaseAuthExceptionMessage(e),
      };
    } catch (e) {
      print('Unexpected error during login: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred during login.',
      };
    }
  }

  // Updated password reset email method
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      // Verify if the email exists in Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return {
          'success': false,
          'message': 'No account found with this email.',
        };
      }

      // Send password reset email without ActionCodeSettings
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      return {
        'success': true,
        'message': 'Password reset link sent to your email.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getFirebaseAuthExceptionMessage(e),
      };
    } catch (e) {
      print('Unexpected error during password reset: $e');
      return {
        'success': false,
        'message': 'Failed to send reset email. Please try again.',
      };
    }
  }

  // Verify password reset code
  Future<Map<String, dynamic>> verifyPasswordResetCode(String code) async {
    try {
      // Verify the password reset code is valid
      final email = await _auth.verifyPasswordResetCode(code);
      
      return {
        'success': true,
        'message': 'Reset code verified successfully.',
        'email': email,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getFirebaseAuthExceptionMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid or expired reset code.',
      };
    }
  }

  // Confirm password reset
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      // Confirm the password reset
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );

      return {
        'success': true,
        'message': 'Password reset successfully.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getFirebaseAuthExceptionMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reset password. Please try again.',
      };
    }
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        return {
          'uid': user.uid,
          'email': user.email,
          ...userData.data() ?? {},
        };
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper method to get readable error messages
  String _getFirebaseAuthExceptionMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid login credentials.';
      case 'expired-action-code':
        return 'Password reset link has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'Invalid password reset link. Please request a new one.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      default:
        return 'An error occurred: ${e.code}';
    }
  }
}
