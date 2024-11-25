import 'dart:math';

import 'package:budgia/screens/initial_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:lottie/lottie.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E21),
              const Color(0xFF0A0E21).withOpacity(0.8),
              Colors.indigo.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenSize.height - MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.08,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenSize.height * 0.15),

                    // Logo/Mascot image
                    SizedBox(
                      height: screenSize.height * 0.25,
                      child: DotLottieLoader.fromAsset(
                        "assets/animations/intro.lottie",
                        frameBuilder: (BuildContext ctx, DotLottie? dotlottie) {
                          if (dotlottie != null) {
                            return Lottie.memory(
                              dotlottie.animations.values.single,
                              fit: BoxFit.contain,
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.05),

                    // App Name
                    Text(
                      'SaveSmart',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Subtitle
                    Text(
                      'Empowering You with Smart Saving\nStrategies & Budgeting Insights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.08),

                    // Get Started Button
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: min(screenSize.width * 0.85, 300),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InitialSetupScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.018,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
