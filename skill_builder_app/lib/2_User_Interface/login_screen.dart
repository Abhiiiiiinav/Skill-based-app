import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 0, 245, 147),
            Color.fromARGB(255, 0, 209, 236),
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 600,
                  width: 400,
                  decoration: BoxDecoration(
                    // image: DecorationImage(image: ),
                    color: const Color.fromARGB(255, 231, 255, 247),

                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 192, 251, 239),
                        blurRadius: 20,
                      ),
                    ],
                  ),

                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text("Welcome to LOGIN", style: GoogleFonts.hanuman(fontSize: 25)),
                        SizedBox(height: 50),
                        TextField(controller: email,decoration: InputDecoration(labelText: "Enter email"),)
                      
                      ],
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
