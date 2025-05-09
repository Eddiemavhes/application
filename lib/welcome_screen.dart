import 'package:flutter/material.dart';
import 'dart:async';

// Assuming you have added the Pacifico font to your project
// and declared it in pubspec.yaml.

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Auto-navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      // Replace with your actual main form route
      Navigator.pushReplacementNamed(context, '/mainForm');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Assuming the target width is 375px as per the HTML
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth > 375 ? 375 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: containerWidth,
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 48.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Image
                    Container(
                      width: 160,
                      height: 160,
                      margin: const EdgeInsets.only(bottom: 32.0),
                      child: Image.asset(
                        'assets/images/welcome_leaf.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Title
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'LeafGrader',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Or a dark gray color
                        ),
                      ),
                    ),
                    // Description
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48.0),
                      child: Text(
                        'AI-Powered Tobacco Leaf Quality Analysis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    // Loading Dots (Simple Animation)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity:
                                  index == (_controller.value * 3).floor() % 3
                                      ? 1.0
                                      : 0.3,
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50), // primary color
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the main form screen
                    // Replace with your actual main form route
                    Navigator.pushReplacementNamed(context, '/mainForm');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50), // primary color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // button radius
                    ),
                    elevation: 4.0, // shadow-lg
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600, // font-semibold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
