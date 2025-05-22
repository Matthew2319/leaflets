import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3DB85),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              //LOGO NAME AND DESIGN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(width:80, height:0),
                  Image.asset('assets/logo/WelcomeLogo.png',
                  height: 50,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Leaflets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              //ILLUSTRATION
              const SizedBox(height: 112),
              Expanded(
                child: Column(
                  children: [
                       Image.asset(
                    'assets/images/welcome_illustration.png',
                    height: 200,
                    // If you don't have the image yet, you can use a placeholder
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: 200,
                        color: Colors.white.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          size: 100,
                          color: Color(0xFF9C834F),
                        ),
                      );
                    },
                  ),
                    const SizedBox(height: 24),


                    //TEXT BELOW ILLUSTRATION
                    Container(
                      width: 296,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Container(
                            width: 173,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                SizedBox(
                                  width: 173,
                                  child: Text(
                                    'Your Lofty',
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 36,
                                      fontFamily: 'Inria Sans',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.80,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 173,
                                  child: Text(
                                    'NOTEBOOK',
                                    style: TextStyle(
                                      color: const Color(0xFFF5F5DB),
                                      fontSize: 28,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Inria Sans',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.64,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 296,
                            child: Text(
                              'Encapsulate your thoughts in this comfortable space.',
                              style: TextStyle(
                                color: const Color(0xFF333333),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Inria Sans',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),


              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                ],
              ),

              //BUTTONS
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login page
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5DB),
                      foregroundColor: const Color(0xFF333333),
                      padding: const EdgeInsets.all(10),
                      minimumSize: const Size(140, 0),
                      elevation: 4,
                      shadowColor: const Color(0x3F000000),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF333333),
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'Inria Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Added proper spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to signup page
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C834F),
                      foregroundColor: const Color(0xFFF5F5DB),
                      padding: const EdgeInsets.all(10),
                      minimumSize: const Size(140, 0),
                      elevation: 4,
                      shadowColor: const Color(0x3F000000),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF9C834F),
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Color(0xFFF5F5DB),
                        fontSize: 16,
                        fontFamily: 'Inria Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}