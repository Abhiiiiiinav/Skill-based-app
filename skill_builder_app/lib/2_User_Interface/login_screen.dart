// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/3_Features/add_skills.dart';
import 'package:skill_builder_app/2_User_Interface/home_page.dart';
import 'package:skill_builder_app/2_User_Interface/sign_up_screen.dart';
import "colorpallate.dart";

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  TextInputType? keyboardType,
  bool isPassword = false,
  bool isPasswordVisible = false,
  VoidCallback? onTogglePassword,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 234, 234, 234),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !isPasswordVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ),
    ],
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();

  final TextEditingController pass = TextEditingController();
  
  Future<void> loginWithEmailPassword() async {
    try {
      final usercredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.text.trim(),
            password: pass.text.trim(),
          );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "something went wrong")),
      );
    }
  }

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
                    color: const Color.fromARGB(255, 246, 250, 249),

                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 192, 251, 239),
                        blurRadius: 20,
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              "Welcome to LOGIN",
                              style: GoogleFonts.hanuman(fontSize: 25),
                            ),

                            SizedBox(height: 50),
                            _buildTextField(
                              controller: email,
                              label: "Email",
                              hint: "Enter Email ID",
                              icon: Icons.email,
                            ),

                            SizedBox(height: 40),

                            _buildTextField(
                              controller: pass,
                              label: "Password",
                              hint: "Enter  the Password",
                              icon: Icons.password,
                              isPassword: true,
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text("Forgot Passsword??"),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColorPalette.lightpowdergreen,
                                    ColorPalette.lightpowderblue,
                                  ],
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 11,
                                    color: const Color.fromARGB(
                                      82,
                                      22,
                                      158,
                                      155,
                                    ),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  loginWithEmailPassword();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      10,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: ColorPalette.secondaryCream,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SignUpPage(),
                                  ),
                                );
                              },
                              child: Text("Sign up"),
                            ),
                          ],
                        ),
                      ),
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
