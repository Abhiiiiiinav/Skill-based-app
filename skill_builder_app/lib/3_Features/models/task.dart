import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  String title;
  bool isCompleted;
 

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      

    );
  }
}

class AddTaskPage extends StatefulWidget {
  final String skillId; // Passed from previous screen
  final String uid;

  const AddTaskPage({super.key, required this.skillId, required this.uid});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskTitleController = TextEditingController();

  Future<void> addTaskToFirestore() async {
    if (_taskTitleController.text.trim().isEmpty) return;

    final task = Task(title: _taskTitleController.text.trim());

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("Skills")
        .doc(widget.skillId)
        .collection("Tasks")
        .add(task.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Task added")),
    );

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
            )
          ],
        ),
      ),
    );
  }
}

