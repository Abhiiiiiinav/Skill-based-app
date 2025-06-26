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
      "tasks": taskList.map((t) => {
            "title": t.title,
            "isCompleted": t.isCompleted,
          }).toList(),
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${widget.category}", style: const TextStyle(fontSize: 16)),
            Text("Duration: ${widget.duration}", style: const TextStyle(fontSize: 16)),
            Text("Total Days: ${widget.totalDays}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text("Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: taskList.isEmpty
                  ? const Center(child: Text("No tasks found"))
                  : ListView.builder(
                      itemCount: taskList.length,
                      itemBuilder: (context, index) {
                        final task = taskList[index];
                        return CheckboxListTile(
                          title: Text(task.title),
                          value: task.isCompleted,
                          onChanged: (_) => toggleTask(index),
                          secondary: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editTask(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
