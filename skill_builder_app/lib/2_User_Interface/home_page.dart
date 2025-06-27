// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';
import "../3_Features/add_skills.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> skills = [];



  @override
  void initState() {
    super.initState();
    fetchAllSkills();
  }

  Future<void> fetchAllSkills() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("Skills")
          .get();

      setState(() {
        skills = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error reading skills: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.secondaryCream,

      body:Column(
        children: [
          Expanded(
  child: ListView.builder(
    itemCount: skills.length + 1, // +1 for the Add Skill tile
    itemBuilder: (context, index) {
      if (index == skills.length) {
        // Special Tile at End
        return Card(
          margin: EdgeInsets.all(12),
          color: Colors.green[100],
          child: ListTile(
            leading: Icon(Icons.add, color: Colors.green[800]),
            title: Text(
              "Add a New Skill",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddSkill()),
              );
            },
          ),
        );
      }

      // Regular Skill Tile
      final skill = skills[index];
      return Card(
        margin: EdgeInsets.all(12),
        child: ListTile(
          onTap: () => {},
          title: Text(skill['title'] ?? 'No Title',style: GoogleFonts.hanuman(fontWeight: FontWeight.bold,),),
          subtitle: Text("Category: ${skill['category'] ?? 'No Category'}"),
          trailing: Text("Duration: ${skill['duration'] ?? '0'} days"),
        ),
      );
    },
  ),
),
          ElevatedButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>AddSkill())), child: Text("Add a Skill"))
        ],
      ),

    );
  }
}
