// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skill_builder_app/2_User_Interface/home_page.dart';
import 'package:skill_builder_app/2_User_Interface/login_screen.dart';
import 'package:skill_builder_app/2_User_Interface/sign_up_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName:".env");
  await Firebase.initializeApp(options: FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY']!, 
    appId: dotenv.env['FIREBASE_APP_ID']!, 
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!, 
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!));
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
     
    return MaterialApp(home:Home(),debugShowCheckedModeBanner: false,);
  }
}