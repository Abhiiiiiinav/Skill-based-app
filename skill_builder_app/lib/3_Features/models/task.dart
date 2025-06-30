// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';

class Task {
  String? id;
  String title;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class AddTaskPage extends StatefulWidget {
  final String skillId;
  final String uid;
  final String? taskId;
  final String? skillTitle; // Add skill title for better context

  const AddTaskPage({
    super.key,
    required this.skillId,
    required this.uid,
    this.taskId,
    this.skillTitle,
  });

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> with TickerProviderStateMixin {
  final TextEditingController _taskTitleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
    
    // Auto-focus on the text field after animation
    Future.delayed(const Duration(milliseconds: 400), () {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _taskTitleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> addTaskToFirestore() async {
    if (_taskTitleController.text.trim().isEmpty) {
      _showSnackBar(
        'Please enter a task title',
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final task = Task(title: _taskTitleController.text.trim());

      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .collection("Skills")
          .doc(widget.skillId);

      final snapshot = await docRef.get();
      final currentTasks = (snapshot.data()?['tasks'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      currentTasks.add(task.toMap());

      await docRef.update({'tasks': currentTasks});

      _showSnackBar(
        'Task added successfully!',
        Colors.green,
        Icons.check_circle_outline,
      );

      _taskTitleController.clear();
      _titleFocusNode.requestFocus();
    } catch (e) {
      _showSnackBar(
        'Failed to add task. Please try again.',
        Colors.red,
        Icons.error_outline,
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  Widget _buildTaskInputCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorPalette.deepTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.task_alt_rounded,
                      color: ColorPalette.deepTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New Task",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.primaryNavy,
                          ),
                        ),
                        if (widget.skillTitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            "for ${widget.skillTitle}",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: ColorPalette.primaryNavy.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Task title input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Task Title",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorPalette.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _taskTitleController,
                    focusNode: _titleFocusNode,
                    decoration: InputDecoration(
                      hintText: "Enter what you want to accomplish...",
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.assignment_outlined,
                        color: Colors.grey.shade500,
                      ),
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
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: ColorPalette.primaryNavy,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : addTaskToFirestore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.deepTeal,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: ColorPalette.deepTeal.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Add Task",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
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
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      "Break down complex goals into smaller, actionable steps",
      "Be specific about what you want to achieve",
      "Set measurable outcomes when possible",
      "Focus on one task at a time for better results",
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        color: ColorPalette.aquaMint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ColorPalette.deepTeal.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: ColorPalette.deepTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Tips for Great Tasks",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette.deepTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 8, right: 12),
                          decoration: BoxDecoration(
                            color: ColorPalette.deepTeal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: ColorPalette.deepTeal.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
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
          "Add Task",
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
              children: [
                const SizedBox(height: 8),
                _buildTaskInputCard(),
                const SizedBox(height: 16),
                _buildTipsCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}