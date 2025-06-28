import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

class SkillDetailScreen extends StatefulWidget {
  final String uid;
  final String skillId;
  final String title;
  final String category;
  final String duration;
  final int totalDays;
  final List<Task> tasks;

  const SkillDetailScreen({
    super.key,
    required this.uid,
    required this.skillId,
    required this.title,
    required this.category,
    required this.duration,
    required this.totalDays,
    required this.tasks,
  });

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  final TextEditingController _task = TextEditingController();
  late List<Task> taskList;

  @override
  void initState() {
    super.initState();
    taskList = List.from(widget.tasks); // Copy
  }

  Future<void> updateTasksToFirebase() async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("Skills")
        .doc(widget.skillId);

    await ref.update({
      "tasks": taskList.map((t) => t.toMap()).toList(),
    });
  }

  void addTask() async {
    final String title = _task.text.trim();
    if (title.isEmpty) return;

    setState(() {
      taskList.add(Task(title: title));
      _task.clear();
    });
    await updateTasksToFirebase();
  }

  void toggleTask(int index) async {
    setState(() {
      taskList[index].isCompleted = !taskList[index].isCompleted;
    });
    await updateTasksToFirebase();
  }

  void deleteTask(int index) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Task?"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => taskList.removeAt(index));
      await updateTasksToFirebase();
    }
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                setState(() {
                  taskList[index].title = controller.text.trim();
                });
                Navigator.pop(context);
                await updateTasksToFirebase();
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Task
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _task,
                    decoration: const InputDecoration(
                      hintText: "Enter task title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addTask, child: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 20),

            // List of Tasks
            Expanded(
              child: ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  final task = taskList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => toggleTask(index),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => editTask(index)),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteTask(index)),
                        ],
                      ),
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
