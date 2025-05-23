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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                    onPressed: () async {
                      final username = _usernameController.text.trim();
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final confirmPassword = _confirmPasswordController.text.trim();

                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Passwords do not match!')),
                        );
                        return;
                      }

                      try {
                        UserCredential userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(email: email, password: password);

                        // Optionally, update the display name
                        await userCredential.user?.updateDisplayName(username);

                        // Store user profile in Firestore
                        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                          'username': username,
                          'email': email,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // Navigate to journal screen
                        Navigator.pushReplacementNamed(context, '/journal');
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Signup failed')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C834F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'START WRITING',
                      style: TextStyle(
                        color: const Color(0xFFF5F5DB),
                        fontSize: 16,
                        fontFamily: 'Inria Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.32,
                      ),
                    )
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