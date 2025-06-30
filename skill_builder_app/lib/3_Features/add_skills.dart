// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';
import 'package:skill_builder_app/2_User_Interface/home_page.dart';
import 'package:skill_builder_app/3_Features/models/skills.dart';

import 'package:skill_builder_app/3_Features/models/skills.dart';

class AddSkill extends StatefulWidget {
  const AddSkill({super.key});

  @override
  State<AddSkill> createState() => _AddSkillState();
}

class _AddSkillState extends State<AddSkill> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _duration = TextEditingController();
  // final TextEditingController controller = TextEditingController(); // This controller seems unused

  // ... (rest of your existing variables are fine)
  CollectionReference get namecollection => FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Skills");

  final CollectionReference users = FirebaseFirestore.instance.collection(
    "users",
  );

  late final String uid;

  String? selectedVal = "Others";
  String? selectedDurationLabel = "1 Day";

  final Map<String, int> durationMap = {
    "1 Day": 1,
    "7 Days": 7,
    "15 Days": 15,
    "30 Days": 30,
    "60 Days": 60,
    "90 Days": 90,
    "180 Days": 180,
    "365 Days": 365,
  };

  @override
  void initState() {
    super.initState();

    uid = FirebaseAuth.instance.currentUser!.uid; //!: Change this before Production
  }

  Future<void> uploadAndNavigate() async {
    // Basic validation
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title cannot be empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final String title = _title.text.trim();
      final String category = selectedVal!;
      final String durationLabel = selectedDurationLabel!;
      final int durationInDays = durationMap[durationLabel] ?? 1;

      final data = {
        "title": title,
        "category": category,
        "duration":
            durationInDays, // Storing the integer value is good practice
        "createdAt": Timestamp.now(),
      };

      DocumentReference docRef = await namecollection.add(data);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Skill added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillDetailScreen(
              uid:  FirebaseAuth.instance.currentUser!.uid,
              skillId: docRef.id,
              title: title,
              category: category,
              duration: durationInDays, 
              
              tasks: [], 
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error uploading skill: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> addDetails() async {
    final String title = _title.text.trim();
    final String category = selectedVal!;
    final String durationLabel = selectedDurationLabel!;
    final int durationInDays = durationMap[durationLabel] ?? 1;
    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "name": title,
      "category": category,
      "duration": durationInDays,
      "createdAt": DateTime.now(),
    });
  }

  Widget buildTextField({
    required TextEditingController controller,
    required Text label,
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
        label,
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

  Widget buildDropdownField<T>({
    required TextEditingController controller,
    required String selectedValue,
    required Text labelText,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    IconData? icon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText,
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 234, 234, 234),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              value: selectedValue as T,
              hint: Text(hintText ?? "Select"),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.grey[600]),
                        const SizedBox(width: 10),
                      ],
                      Text(item.toString()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.neutralCharcoal,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Add a Skill Here",
                style: GoogleFonts.hanuman(
                  color: ColorPalette.neutralLightGray,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: ColorPalette.secondaryCream,
                ),
                padding: const EdgeInsets.all(34.0),
                width: 450,
                child: Column(
                  children: [
                    buildTextField(
                      controller: _title,
                      label: Text(
                        "Title",
                        style: GoogleFonts.hanuman(
                          color: ColorPalette.primaryNavy,
                        ),
                      ),
                      hint: "Enter the Title",
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 30),
                    buildDropdownField<String>(
                      controller: _category,
                      labelText: Text(
                        "Category:",
                        style: GoogleFonts.hanuman(),
                      ),
                      selectedValue: selectedVal ?? "Others",
                      items: ["Health", "Coding", "Self Improvement", "Others"],
                      onChanged: (value) {
                        setState(() {
                          selectedVal = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    buildDropdownField<String>(
                      controller: _duration,
                      labelText: Text(
                        "Duration:",
                        style: GoogleFonts.hanuman(),
                      ),
                      selectedValue: selectedDurationLabel ?? '7 Days',
                      items: durationMap.keys.toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDurationLabel = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                     
                      onPressed: () {
                        uploadAndNavigate();

                        Navigator.push(context,MaterialPageRoute(builder: (_)=>HomePage()));
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text("Submit Skill"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Remember to dispose controllers
  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _duration.dispose();
    super.dispose();
  }
}


