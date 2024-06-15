import 'package:butterflies/components/screens/dashboard_screen.dart';
import 'package:butterflies/components/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> signInWithGoogle(BuildContext context) async {
    try {
      // Initiate the Google Sign-In process.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in process.
        return 'Google sign-in was canceled.';
      }

      // Retrieve the authentication details from the Google sign-in.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new Firebase credential.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential.

      await _firebaseAuth.signInWithCredential(credential);

      // Sign-in successful and Save the login state

      await saveLoginState(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
      return null;
    } catch (e) {
      // Handle sign-in errors.
      print('Error during Google sign-in: $e');
      return 'Error during Google sign-in: $e';
    }
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<bool> getLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Retrieve the current user's details from Firebase Authentication
  Future<Map<String, String>?> getCurrentUser() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        String displayName = user.displayName ?? 'No Username';
        String email = user.email ?? 'No Email';
        return {'displayName': displayName, 'email': email};
      } else {
        return null; // No user logged in
      }
    } catch (e) {
      print('Error retrieving current user: $e');
      return null; // Error occurred
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}
