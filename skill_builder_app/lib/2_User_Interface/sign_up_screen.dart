import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colorpallate.dart';

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

class SignUpPage extends StatelessWidget {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  SignUpPage({super.key});

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

                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Welcome to Sign UP",
                            style: GoogleFonts.hanuman(
                              fontSize: 25,
                              color: ColorPalette.primaryNavy,
                            ),
                          ),

                          SizedBox(height: 50),
                          _buildTextField(
                            controller: name,
                            label: "Name",
                            hint: "Enter Your Name",
                            icon: Icons.person,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: email,
                            label: "Email",
                            hint: "Enter Email ID",
                            icon: Icons.email,
                          ),
                          SizedBox(height: 20),
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
                              child: Text("Already have an account ?"),
                            ),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text("Submit"),
                            ),
                          ),
                        ],
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
