import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  // Add SharedPreferences instance
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _isEmailAlreadyRegistered(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tbl_users')
        .where('email', isEqualTo: email)
        .get();
    
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    print('Debug - Form Values:');
    print('First Name: $firstName');
    print('Last Name: $lastName');
    print('Username: $username');
    print('Email: $email');
    print('Password length: ${password.length}');
    print('Confirm Password length: ${confirmPassword.length}');

    // Validation
    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      print('Debug - Empty fields detected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      print('Debug - Passwords do not match');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    if (password.length < 6) {
      print('Debug - Password too short');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Debug - Starting signup process');
      
      // Check if email is already registered
      if (await _isEmailAlreadyRegistered(email)) {
        throw Exception('email-already-in-use');
      }

      // Hash the password
      final hashedPassword = _hashPassword(password);
      
      // Generate a unique user ID
      final String userId = FirebaseFirestore.instance.collection('tbl_users').doc().id;

      // Prepare user data
      final userData = {
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'password': hashedPassword, // Store hashed password
        'uid': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      print('Debug - Saving to Firestore');
      await FirebaseFirestore.instance
          .collection('tbl_users')
          .doc(userId)
          .set(userData);
      
      // Save user session locally
      await _prefs.setString('user_id', userId);
      await _prefs.setString('username', username);
      await _prefs.setString('email', email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please log in.')),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Debug - Error: $e');
      String message;
      if (e.toString().contains('email-already-in-use')) {
        message = 'This email is already registered';
      } else {
        message = 'An unexpected error occurred: $e';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Image.asset('assets/logo/SignupLogo.png',
                        height: 132,
                        width: 132,
                      ),
                      Container(
                        width: 131,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 40,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.80,
                              ),
                            ),

                            Text(
                              'Please sign in with your credentials.',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                            ),


                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 20),
                Container(
                  width: 357,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // First Name TextFormField
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextFormField(
                          controller: _firstNameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                              labelText: 'First Name',
                              labelStyle: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                              enabledBorder: InputBorder.none
                          ),
                        ),
                      ),

                      // Last Name TextFormField
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextFormField(
                          controller: _lastNameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                              labelText: 'Last Name',
                              labelStyle: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                              enabledBorder: InputBorder.none
                          ),
                        ),
                      ),

                      // Username TextFormField
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                              enabledBorder: InputBorder.none
                          ),
                        ),
                      ),

                      // Email TextFormField
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                              enabledBorder: InputBorder.none
                          ),
                        ),
                      ),

                      // Password TextFormField
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                              enabledBorder: InputBorder.none
                          ),
                        ),
                      ),

                      // Confirm Password TextFormField
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                              enabledBorder: InputBorder.none
                          ),
                        ),
                      ),


                    ],
                  ),
                ),


                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C834F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'START WRITING',
                          style: TextStyle(
                            color: Color(0xFFF5F5DB),
                            fontSize: 16,
                            fontFamily: 'Inria Sans',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.32,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'Inria Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.32,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Inria Sans',
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.32,
                        ),
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}