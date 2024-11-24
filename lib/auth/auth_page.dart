import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<bool> _authenticateWithBiometrics() async {
    final LocalAuthentication localAuth = LocalAuthentication();
    try {
      return await localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        final prefs = snapshot.data!;
        final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
        final systemLockEnabled = prefs.getBool('system_lock_enabled') ?? false;

        if (systemLockEnabled) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E21),
            body: Center(
              child: FutureBuilder<bool>(
                future: _authenticateWithBiometrics(),
                builder: (context, authSnapshot) {
                  if (authSnapshot.hasData) {
                    if (authSnapshot.data!) {
                      Future.microtask(() {
                        Navigator.of(context).pushReplacementNamed(
                          hasSeenIntro ? '/home' : '/',
                        );
                      });
                      return const CircularProgressIndicator(
                          color: Colors.blue);
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0A0E21),
                              const Color(0xFF1D1E33),
                              Colors.blue.shade900.withOpacity(0.5),
                            ],
                            stops: const [0.2, 0.6, 0.9],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background subtle pattern
                            Positioned.fill(
                              child: ShaderMask(
                                blendMode: BlendMode.softLight,
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.1),
                                      Colors.purple.withOpacity(0.1),
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo with glow effect
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/logo/full_logo.png',
                                      height: 180,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Stylish error message container
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1D1E33)
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Authentication Failed',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Animated Try Again button
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 48,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AuthPage(),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.fingerprint, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Try Again',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Styled Exit button
                                  TextButton.icon(
                                    onPressed: () => SystemNavigator.pop(),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                    ),
                                    icon:
                                        const Icon(Icons.exit_to_app, size: 20),
                                    label: const Text(
                                      'Exit App',
                                      style: TextStyle(
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  return const CircularProgressIndicator(color: Colors.blue);
                },
              ),
            ),
          );
        } else {
          // No system lock, proceed normally
          Future.microtask(() {
            Navigator.of(context).pushReplacementNamed(
              hasSeenIntro ? '/home' : '/',
            );
          });
        }

        return _buildLoadingScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }
}
