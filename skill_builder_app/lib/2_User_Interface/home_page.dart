// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';
import 'package:skill_builder_app/3_Features/models/skills.dart';
import 'package:skill_builder_app/3_Features/models/task.dart';
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
        skills = snapshot.docs.map(
                (doc) 
                {
                    final data = doc.data() ;
                    data['id'] = doc.id; // include docRef.id manually here
                  return data;
                }
                ).toList();

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
        color: const Color.fromARGB(255, 255, 250, 234),
        margin: EdgeInsets.all(12),
        child: ListTile(
        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SkillDetailScreen(
        uid: FirebaseAuth.instance.currentUser!.uid,
        skillId: skill['id'], // You must include this manually in your fetch
        title: skill['title'] ?? 'No Title',
        category: skill['category'] ?? '',
        duration: skill['duration'].toString(),
        totalDays: skill['duration'] ?? 0,
        tasks: (skill['tasks'] as List<dynamic>? ?? [])
            .map((t) => Task.fromMap(Map<String, dynamic>.from(t)))
            .toList(),
      ),
    ),
  );
},
          title: Text(skill['title'].toString().toUpperCase(),style: GoogleFonts.hanuman(fontWeight: FontWeight.bold, fontSize: 18,color: ColorPalette.mocha),),
          subtitle: Text("Category: ${skill['category'].toString().toUpperCase()}",style: GoogleFonts.caladea(fontSize: 15),),
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
