import 'package:firebase_auth/firebase_auth.dart';
// Removed: import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Current user data structure
class CurrentUser {
  final String uid;
  final String username;
  final String email;

  CurrentUser({
    required this.uid,
    required this.username,
    required this.email,
  });
}

class AuthService {
  final FirebaseAuth _firebaseAuth;
  // final FirebaseFirestore _firestore; // Remove unused field

  AuthService(this._firebaseAuth); // Update constructor

  // Constructor (can also be initialized with FirebaseAuth.instance directly)
  // AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore}) 
  //   : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
  //     _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user from SharedPreferences
  Future<CurrentUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('user_id');
      final username = prefs.getString('username');
      final email = prefs.getString('email');

      if (uid != null && username != null && email != null) {
        return CurrentUser(
          uid: uid,
          username: username,
          email: email,
        );
      }
      return null;
    } catch (error) {
      print('Error getting current user: $error');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') != null;
  }

  // Sign out user
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 