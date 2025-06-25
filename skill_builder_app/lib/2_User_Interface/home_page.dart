

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';
import 'package:skill_builder_app/2_User_Interface/sign_up_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController controller = TextEditingController();
  CollectionReference get namecollection => FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Skills");
  final CollectionReference users = FirebaseFirestore.instance.collection(
    "users",
  );
  late final String uid;
  String readname = "";
  String documentId = 'demo-user';
  String? selectedVal = "Others";

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
  required Text labelText,
  required String selectedValue,
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


  /* 
================================================
||           Text Controllers                   || 
================================================
*/
  final TextEditingController _title = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _totalDays = TextEditingController();
  final TextEditingController _completedDays = TextEditingController();
  final TextEditingController _task = TextEditingController();
  final TextEditingController _isCompleted = TextEditingController();

  /* 
================================================
||           CRUD Operations                   || 
================================================
*/

  void createData() {
    users.doc(documentId).set({'name': controller.text});
  }

  void readData() async {
    DocumentSnapshot doc = await users.doc(documentId).get();
    if (doc.exists) {
      setState(() {
        readname = doc['name'];
      });
    } else {
      setState(() {
        readname = "no data found";
      });
    }
  }

  void updatedata() {
    users.doc(documentId).update({"name": controller.text});
  }

  void deletedata() {
    users.doc(documentId).delete();
    controller.clear();
  }

  /* 
================================================
||           Upload Data to DB                 || 
================================================
*/
  Future<void> uploadTasktoDB() async {
    try {
      /* final await data = FirebaseFirestore.instance.collection("Skills").add(
       {
         "title": _title.text.trim(),
         ...
      //  }
      */ 
    } catch (e) {
      print(e);
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
              Text(
                "Add a Skill Here",
                style: GoogleFonts.hanuman
                (
                  color: ColorPalette.neutralLightGray,
                  fontWeight: FontWeight.bold
                ),
              ),
             Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: ColorPalette.secondaryCream
                  ),
                  padding: EdgeInsets.all(34.0),
                  
                  width: 450,
                  height: 1700,
                  child: Column(
                    children: [
                      buildTextField(
                    controller: _title, 
                    label: Text("Title",style: GoogleFonts.hanuman(color: ColorPalette.primaryNavy),),
                     hint:"Enter the Title",
                      icon: Icons.title),
                      buildDropdownField(controller:_category,labelText:  Text("Category"), selectedValue: selectedVal??"Others", items: ["Health","Coding","Self Improvement","Others"], onChanged: (value)=>{
                        setState(() {
                          selectedVal = value;
                        })
                      })
                      
                      
                    ],
                  )
                      ),
        
              
            ],
          
          ),
        ),
      ),
    );
  }
}
