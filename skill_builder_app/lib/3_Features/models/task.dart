// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  String? id; // Add this
  String title;
  bool isCompleted;

  Task({
    this.id  ,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include ID
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '', // Handle ID
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class AddTaskPage extends StatefulWidget {
  final String skillId; // Passed from previous screen
  final String uid;
  
   final String? taskId;

  const AddTaskPage({super.key, required this.skillId, required this.uid, this.taskId});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskTitleController = TextEditingController();

  Future<void> addTaskToFirestore() async {
    if (_taskTitleController.text.trim().isEmpty) return;

    final task = Task(title: _taskTitleController.text.trim());

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("Skills")
        .doc(widget.skillId)
        .collection("Tasks")
        .doc(widget.taskId);

    final snapshot = await docRef.get();
    final currentTasks = (snapshot.data()?['tasks'] as List<dynamic>? ?? []) //! Might not work
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    currentTasks.add(task.toMap());

    await docRef.update({'tasks': currentTasks});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Task added")));

    _taskTitleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _taskTitleController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTaskToFirestore,
              child: const Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }
}
