import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _duration = TextEditingController();
  final TextEditingController controller = TextEditingController();

  final CollectionReference users = FirebaseFirestore.instance.collection("users");
  late final String uid;
  String readname = "";
  String documentId = 'demo-user';

  String? selectedVal = "Others";
  String? selectedDurationLabel = "7 Days";

  final Map<String, int> durationMap = {
    "7 Days": 7,
    "15 Days": 15,
    "30 Days": 30,
    "60 Days": 60,
    "90 Days": 90,
    "180 Days": 180,
    "365 Days": 365,
  };

  CollectionReference get namecollection => FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Skills");

  @override
  void initState() {
    super.initState();
    uid = "test-user-id"; // 🔁 Replace with FirebaseAuth.instance.currentUser!.uid when auth is integrated
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
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[400],
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Future<void> uploadTasktoDB() async {
    try {
      int durationInDays = durationMap[selectedDurationLabel] ?? 7;

      final data = {
        "title": _title.text.trim(),
        "category": selectedVal,
        "duration": durationInDays,
        "createdAt": Timestamp.now(),
      };

      await namecollection.add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Skill added successfully!")),
      );
    } catch (e) {
      print("Error uploading: $e");
    }
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
                  fontSize: 25
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
                      label: Text("Title", style: GoogleFonts.hanuman(color: ColorPalette.primaryNavy)),
                      hint: "Enter the Title",
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 30),
                    buildDropdownField<String>(
                      controller: _category,
                      labelText: Text("Category:", style: GoogleFonts.hanuman()),
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
                      labelText: Text("Duration:", style: GoogleFonts.hanuman()),
                      selectedValue: selectedDurationLabel ?? '7 Days',
                      items: durationMap.keys.toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDurationLabel = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: uploadTasktoDB,
                      icon: const Icon(Icons.upload),
                      label: const Text("Submit Skill"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
