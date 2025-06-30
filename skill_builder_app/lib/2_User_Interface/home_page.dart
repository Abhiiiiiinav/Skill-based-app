// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_builder_app/2_User_Interface/colorpallate.dart';
import 'package:skill_builder_app/3_Features/add_skills.dart';
import 'package:skill_builder_app/3_Features/models/skills.dart';
import 'package:skill_builder_app/3_Features/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> _allSkills = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String uid = FirebaseAuth.instance.currentUser!.uid;

  String _searchQuery = '';
  String? _selectedCategoryFilter;
  bool _isAscending = true;
  bool _isLoading = true;

  final List<String> _categories = ["Health", "Coding", "Self Improvement", "Others"];

  // Category colors for better visual hierarchy
  final Map<String, Color> _categoryColors = {
    "Health": const Color(0xFF4CAF50),
    "Coding": const Color(0xFF2196F3),
    "Self Improvement": const Color(0xFF9C27B0),
    "Others": const Color(0xFFFF9800),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchSkills();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchSkills() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("Skills")
          .get();

      _allSkills = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      applyFilters();
      _animationController.forward();
    } catch (e) {
      print("Error: $e");
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load skills. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int getRemainingDays(Map<String, dynamic> skill) {
    if (skill['createdAt'] == null || skill['duration'] == null) return 0;

    final createdAt = (skill['createdAt'] as Timestamp).toDate();
    final totalDays = skill['duration'] as int;

    final daysPassed = DateTime.now().difference(createdAt).inDays;
    final remainingDays = totalDays - daysPassed;

    return remainingDays < 0 ? 0 : remainingDays;
  }

  void applyFilters() {
    List<Map<String, dynamic>> filtered = _allSkills.where((skill) {
      final titleMatch = skill['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final categoryMatch = _selectedCategoryFilter == null ||
          skill['category'] == _selectedCategoryFilter;
      return titleMatch && categoryMatch;
    }).toList();

    filtered.sort((a, b) {
      return _isAscending
          ? a['title'].compareTo(b['title'])
          : b['title'].compareTo(a['title']);
    });

    setState(() => skills = filtered);
  }

  void deleteSkill(String docId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text("Delete Skill?"),
          ],
        ),
        content: const Text(
          "This will permanently delete the skill and all its tasks. This action cannot be undone.",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleting skill...')),
      );

      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("Skills")
            .doc(docId)
            .delete();

        fetchSkills(); // Refresh data
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Skill deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete skill. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void editSkill(Map<String, dynamic> skill) {
    final titleController = TextEditingController(text: skill['title']);
    String selectedCategory = skill['category'] ?? "Others";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: ColorPalette.deepTeal, size: 28),
            const SizedBox(width: 12),
            const Text("Edit Skill"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Skill Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _categoryColors[value],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) selectedCategory = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a skill title'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .collection("Skills")
                    .doc(skill['id'])
                    .update({
                  "title": titleController.text.trim(),
                  "category": selectedCategory,
                });

                Navigator.pop(context);
                fetchSkills();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Skill updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update skill. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.deepTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill, int index) {
    final remainingDays = getRemainingDays(skill);
    final category = skill['category'] ?? 'Others';
    final categoryColor = _categoryColors[category] ?? Colors.grey;
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SkillDetailScreen(
                  uid: uid,
                  skillId: skill['id'],
                  title: skill['title'],
                  category: skill['category'],
                  duration: remainingDays,
                  tasks: (skill['tasks'] as List<dynamic>? ?? [])
                      .map((t) => Task.fromMap(Map<String, dynamic>.from(t)))
                      .toList(),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with category badge and actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: categoryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => editSkill(skill),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => deleteSkill(skill['id']),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Skill title
                Text(
                  skill['title'],
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.primaryNavy,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Days remaining info
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: remainingDays > 7 ? Colors.green : 
                             remainingDays > 3 ? Colors.orange : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      remainingDays > 0 
                          ? "$remainingDays days remaining"
                          : "Expired",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: remainingDays > 7 ? Colors.green : 
                               remainingDays > 3 ? Colors.orange : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddSkillCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        color: ColorPalette.aquaMint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ColorPalette.deepTeal.withOpacity(0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSkill()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorPalette.deepTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
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
                        "Add a New Skill",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.ivory,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Start your learning journey",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: ColorPalette.ivory,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ColorPalette.deepTeal.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.ivory,
      body: Column(
        children: [
          // Enhanced header with better spacing and alignment
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black,
              //     blurRadius: 10,
              //     offset: const Offset(0, 2),
              //   ),
              
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome text
                Text(
                  "My Skills",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skills.isEmpty && !_isLoading 
                      ? "Start building your skills today!" 
                      : "${skills.length} skill${skills.length != 1 ? 's' : ''} in progress",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: ColorPalette.primaryNavy.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                // Search bar with improved styling
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search your skills...",
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    applyFilters();
                  },
                ),
                const SizedBox(height: 16),
                // Filter and sort row with better spacing
                Row(
                  children: [
                    // Category filter dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(
                              "All Categories",
                              style: GoogleFonts.inter(color: Colors.grey.shade600),
                            ),
                            value: _selectedCategoryFilter,
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(
                                  "All Categories",
                                  style: GoogleFonts.inter(),
                                ),
                              ),
                              ..._categories.map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: _categoryColors[cat],
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(cat, style: GoogleFonts.inter()),
                                      ],
                                    ),
                                  )),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedCategoryFilter = val);
                              applyFilters();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort button
                    Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.deepTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha,
                          color: ColorPalette.deepTeal,
                        ),
                        onPressed: () {
                          setState(() => _isAscending = !_isAscending);
                          applyFilters();
                        },
                        tooltip: _isAscending ? "Sort Z-A" : "Sort A-Z",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : skills.isEmpty && _searchQuery.isEmpty && _selectedCategoryFilter == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No skills yet!",
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add your first skill to get started",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildAddSkillCard(),
                          ],
                        ),
                      )
                    : skills.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No skills found",
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Try adjusting your search or filters",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 16),
                              itemCount: skills.length + 1,
                              itemBuilder: (context, index) {
                                if (index == skills.length) {
                                  return _buildAddSkillCard();
                                }
                                return _buildSkillCard(skills[index], index);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}