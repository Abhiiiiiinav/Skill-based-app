import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart'; // Your Task model

class SkillDetailScreen extends StatefulWidget {
  final String uid;
  final String skillId;
  final String title;
  final String category;
  final String duration;
  final int totalDays;
  final List<Task> tasks;

  const SkillDetailScreen({
    required this.uid,
    required this.skillId,
    required this.title,
    required this.category,
    required this.duration,
    required this.totalDays,
    required this.tasks,
    super.key,
  });

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  TextEditingController _task = TextEditingController();
  late List<Task> taskList;

  @override
  void initState() {
    super.initState();
    taskList = List.from(widget.tasks); // Make a local mutable copy
  }

  Future<void> updateTasksToFirebase() async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("Skills")
        .doc(widget.skillId);

    await ref.update({
      "tasks": taskList
          .map((t) => {"title": t.title, "isCompleted": t.isCompleted})
          .toList(),
    });
  }

  void toggleTask(int index) async {
    setState(() {
      taskList[index].isCompleted = !taskList[index].isCompleted;
    });
    await updateTasksToFirebase();
  }

  void editTask(int index) {
    final controller = TextEditingController(text: taskList[index].title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() {
                taskList[index].title = controller.text;
              });
              Navigator.pop(context);
              await updateTasksToFirebase();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          TextField(
            controller: _task,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final String task = _task.text.trim();
              taskList.add(task as Task);
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
