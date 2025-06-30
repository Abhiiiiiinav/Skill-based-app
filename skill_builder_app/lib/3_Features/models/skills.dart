import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';
import 'task.dart';

class SkillDetailScreen extends StatefulWidget {
  final String uid;
  final String skillId;
  final String title;
  final String category;
  final int duration;
  final List<Task> tasks;

  const SkillDetailScreen({
    super.key,
    required this.uid,
    required this.skillId,
    required this.title,
    required this.category,
    required this.duration,
    required this.tasks,
  });

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> with TickerProviderStateMixin {
  final TextEditingController _task = TextEditingController();
  final FocusNode _taskFocusNode = FocusNode();
  late List<Task> taskList;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _showAddTaskField = false;

  @override
  void initState() {
    super.initState();
    taskList = widget.tasks;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _task.dispose();
    _taskFocusNode.dispose();
    super.dispose();
  }

  Future<void> updateTasksToFirebase() async {
    setState(() => _isLoading = true);
    
    try {
      final ref = FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .collection("Skills")
          .doc(widget.skillId);

      await ref.update({
        "tasks": taskList.map((t) => t.toMap()).toList(),
      });
    } catch (e) {
      _showSnackBar(
        'Failed to update tasks. Please try again.',
        Colors.red,
        Icons.error_outline,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void addTask() async {
    final String title = _task.text.trim();
    if (title.isEmpty) {
      _showSnackBar(
        'Please enter a task title',
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() {
      taskList.add(Task(title: title));
      _task.clear();
      _showAddTaskField = false;
    });
    
    await updateTasksToFirebase();
    
    _showSnackBar(
      'Task added successfully!',
      Colors.green,
      Icons.check_circle_outline,
    );
  }

  void toggleTask(int index) async {
    setState(() {
      taskList[index].isCompleted = !taskList[index].isCompleted;
    });
    await updateTasksToFirebase();
  }

  void deleteTask(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Task?",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: ColorPalette.primaryNavy,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this task? This action cannot be undone.",
          style: GoogleFonts.inter(
            color: ColorPalette.primaryNavy.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => taskList.removeAt(index));
      await updateTasksToFirebase();
      
      _showSnackBar(
        'Task deleted successfully',
        Colors.green,
        Icons.check_circle_outline,
      );
    }
  }

  void editTask(int index) {
    final controller = TextEditingController(text: taskList[index].title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Edit Task",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: ColorPalette.primaryNavy,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter task title...",
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorPalette.deepTeal, width: 2),
            ),
          ),
          style: GoogleFonts.inter(
            color: ColorPalette.primaryNavy,
          ),
          maxLines: 3,
          minLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  taskList[index].title = controller.text.trim();
                });
                Navigator.pop(context);
                await updateTasksToFirebase();
                
                _showSnackBar(
                  'Task updated successfully!',
                  Colors.green,
                  Icons.check_circle_outline,
                );
              }
            },
            child: Text(
              "Save",
              style: GoogleFonts.inter(
                color: ColorPalette.deepTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSkillInfoCard() {
    final completedTasks = taskList.where((task) => task.isCompleted).length;
    final totalTasks = taskList.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                ColorPalette.deepTeal,
                ColorPalette.deepTeal.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.category,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Progress section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Progress",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$completedTasks of $totalTasks tasks completed",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${(progress * 100).toInt()}%",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddTask() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _showAddTaskField
              ? Column(
                  children: [
                    TextField(
                      controller: _task,
                      focusNode: _taskFocusNode,
                      decoration: InputDecoration(
                        hintText: "Enter task title...",
                        hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorPalette.deepTeal, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color: ColorPalette.primaryNavy,
                      ),
                      maxLines: 2,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => addTask(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showAddTaskField = false;
                                _task.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : addTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.deepTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Add Task",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : InkWell(
                  onTap: () {
                    setState(() => _showAddTaskField = true);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _taskFocusNode.requestFocus();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorPalette.deepTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: ColorPalette.deepTeal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Add New Task",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ColorPalette.deepTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    if (taskList.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Tasks Yet",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start by adding your first task to begin building this skill!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              "Tasks (${taskList.length})",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorPalette.primaryNavy,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: taskList.length,
            itemBuilder: (context, index) {
              final task = taskList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Card(
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: task.isCompleted 
                          ? ColorPalette.deepTeal.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => toggleTask(index),
                      activeColor: ColorPalette.deepTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted 
                            ? Colors.grey.shade500
                            : ColorPalette.primaryNavy,
                        decoration: task.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          onPressed: () => editTask(index),
                          tooltip: "Edit task",
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          onPressed: () => deleteTask(index),
                          tooltip: "Delete task",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.ivory,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: ColorPalette.primaryNavy,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Skill Details",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ColorPalette.primaryNavy,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade200,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildSkillInfoCard(),
                const SizedBox(height: 8),
                _buildQuickAddTask(),
                const SizedBox(height: 16),
                _buildTasksList(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}