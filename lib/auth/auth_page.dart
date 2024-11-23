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

        // Handle system lock
        if (systemLockEnabled) {
          Future.microtask(() async {
            final authenticated = await _authenticateWithBiometrics();
            if (authenticated) {
              Navigator.of(context).pushReplacementNamed(
                hasSeenIntro ? '/home' : '/',
              );
            } else {
              // If authentication fails, exit the app
              SystemNavigator.pop();
            }
          });
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
