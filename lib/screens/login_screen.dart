import 'package:flutter/material.dart';
import '../widgets/leaf_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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

                //LOGIN INSTRUCTIONS AND LOGO
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
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
                                'Login',
                                style: TextStyle(
                                  color: const Color(0xFF333333),
                                  fontSize: 40,
                                  fontFamily: 'Inria Sans',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.80,
                                ),
                              ),

                               Text(
                                'Please log in with your account’s credentials.',
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
                      Image.asset('assets/logo/LoginLogo.png',
                        height: 132,
                        width: 132,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                //PASSWORD AND USERNAME
                Container(
                  width: 357,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Username TextFormField
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
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

                      // Password TextFormField
                      Container(
                        width: double.infinity,
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


                    ],
                  ),
                ),



                const SizedBox(height: 24),

                //LEAF IN BUTTON
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/journal');
                      // Implement login functionality
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
                      'LEAF-IN',
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


                const SizedBox(height: 24),
                Text(
                  'Or Login using',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Inria Sans',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.32,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialLoginButton(Icons.email, () {}),
                    const SizedBox(width: 16),
                    _socialLoginButton(Icons.code, () {}),
                    const SizedBox(width: 16),
                    _socialLoginButton(Icons.facebook, () {}),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dont have an account yet? ',
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
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign Up',
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

  Widget _socialLoginButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.black54,
        ),
      ),
    );
  }
}