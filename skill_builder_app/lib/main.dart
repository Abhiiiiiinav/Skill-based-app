// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skill_builder_app/3_Features/models/task.dart';
import '3_Features/models/skills.dart';
import 'package:skill_builder_app/2_User_Interface/add_skills.dart';
import 'package:skill_builder_app/2_User_Interface/home_page.dart';
import 'package:skill_builder_app/2_User_Interface/login_screen.dart';
import 'package:skill_builder_app/2_User_Interface/sign_up_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  final String uid = "demoUser123";
final String skillId = "exampleSkillId";
final String title = "Learn Flutter";
final String category = "Coding";
final String duration = "30 Days";
final int totalDays = 30;
final List<Task> tasks = [
  Task(id:"1",title: "Install Flutter", isCompleted: false,createdAt: DateTime.now()),
  Task(id:'2',title: "Create First App", isCompleted: true,createdAt: DateTime.now()),
];
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: 
      home: HomePage(),
    );
  }
}
