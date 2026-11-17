
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF540602),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.science,
                size: 70,
                color: Color(0xFFF5EBDD),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'LAB INVENTORY',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF540602),
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Laboratory Equipment Management',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 17,
                color: Color(0xFF540602),
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 35),

            const CircularProgressIndicator(
              color: Color(0xFF540602),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
