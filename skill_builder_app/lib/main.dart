import 'package:flutter/material.dart';
import 'package:skill_builder_app/2_User_Interface/home_page.dart';
import 'package:skill_builder_app/2_User_Interface/login_screen.dart';
import 'package:skill_builder_app/2_User_Interface/sign_up_screen.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:SignUpPage(),debugShowCheckedModeBanner: false,);
  }
}