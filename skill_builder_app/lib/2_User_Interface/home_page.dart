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
Future<List<Task>> fetchTasks(String uid, String skillId) async {
  final docSnapshot = await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("Skills")
      .doc(skillId)
      .get();

  if (!docSnapshot.exists) return [];

  final data = docSnapshot.data();
  final tasksRaw = data?['tasks'] as List<dynamic>? ?? [];

  return tasksRaw.map((taskMap) {
    return Task.fromMap(Map<String, dynamic>.from(taskMap));
  }).toList();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.secondaryCream,

      body:Column(
        children: [
          Expanded(
  child: ListView.builder(
    itemCount: skills.length + 1, 
    itemBuilder: (context, index) {
      if (index == skills.length) {
        return Card(
          margin: const EdgeInsets.all(12),
          color: Colors.green[100],
          child: ListTile(
            leading: const Icon(Icons.add, color: Colors.green),
            title: const Text("Add a New Skill"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSkill()));
            },
          ),
        );
      }

      final skill = skills[index];
      return Card(
        margin: const EdgeInsets.all(12),
        color: const Color.fromARGB(255, 255, 250, 234),
        child: ListTile(
          title: Text(
            skill['title'] ?? 'No Title',
            style: GoogleFonts.hanuman(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Category: ${skill['category'] ?? ''}"),
          trailing: Text("Duration: ${skill['duration']} days"),
          onTap: () async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            final tasks = await fetchTasks(uid, skill['id']);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SkillDetailScreen(
                  uid: uid,
                  skillId: skill['id'],
                  title: skill['title'],
                  category: skill['category'],
                  duration: skill['duration'].toString(),
                  totalDays: skill['duration'],
                  tasks: tasks,
                        ),
                      ),
                    );
                  },
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
