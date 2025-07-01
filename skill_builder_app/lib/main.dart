// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skill_builder_app/User%20Interface/splashscreen.dart';
import 'package:skill_builder_app/Models%20and%20Features/models/task.dart';
import 'Models and Features/models/skills.dart';
import 'package:skill_builder_app/Models%20and%20Features/add_skills.dart';
import 'package:skill_builder_app/User%20Interface/home_page.dart';
import 'package:skill_builder_app/User%20Interface/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBLUCW0iItRJG1e56EA_-d8y5z7Jh3Wjrs",
      authDomain: "skill-tracker-app-b227c.firebaseapp.com",
      projectId: "skill-tracker-app-b227c",
      storageBucket: "skill-tracker-app-b227c.firebasestorage.app",
      messagingSenderId: "138491269064",
      appId: "1:138491269064:web:f77cab51d7e0d45fd37afd",
    ),
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        nextScreen: AuthWrapper(), // Pass the auth wrapper as next screen
      ),
    );
  }
}

// Create a separate widget for authentication logic
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF023436), // deepTeal
                    Color(0xFF1A365D), // primaryNavy
                    Color(0xFF2D3748), // neutralCharcoal
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF1B998B), // aquaMint
                  ),
                ),
              ),
            ),
          );
        }
        
        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return HomePage();
        }
        
        // User is not logged in
        return LoginScreen();
      },
    );
  }
}