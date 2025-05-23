import 'package:flutter/material.dart';
import '../widgets/leaf_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    print('Debug - Form Values:');
    print('Username: $username');
    print('Email: $email');
    print('Password length: ${password.length}');
    print('Confirm Password length: ${confirmPassword.length}');

    // Validation
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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
      print('Debug - Attempting to create user with Firebase');
      
      // Configure Firebase Auth settings for this operation
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
      
      // Create user with email and password
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        print('Debug - User created successfully');
        // Update display name
        await userCredential.user!.updateDisplayName(username);
        print('Debug - Display name updated');

        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Debug - User data stored in Firestore');

        // Navigate to journal screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/journal');
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Debug - Firebase Auth Error: ${e.code}');
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        default:
          message = e.message ?? 'An error occurred during signup';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print('Debug - Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 40,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.80,
                              ),
                            ),

                            Text(
                              'Please sign in with your credentials.',
                              style: TextStyle(
                                color: const Color(0xFF333333),
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
                    Text(
                      'Already have an account? ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF333333),
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
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF333333),
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