# ⚙️ Logic & Features - Member 3 Guide

## 📌 Overview
This folder contains the core logic of the app: the data models (Skill, Task), the state management using Provider, and the main feature screens like Add Skill and Skill Detail. Your job is to make sure skills and tasks are tracked, updated, and synced with Firebase in real-time.

---

## 📂 Folder Structure and File Purpose
```
member3_features/
├── models/
│   ├── skill.dart
│   └── task.dart
├── providers/
│   └── skill_provider.dart
├── add_skill.dart
├── skill_detail.dart
└── readme.md
```

### 1. `models/skill.dart`
- A Dart class for Skill with fields like title, description, tasks, taskStatus, userId
- Has `toMap()` and `fromMap()` for Firestore use

### 2. `models/task.dart`
- Optional class if you want to expand tasks as individual objects
- Contains task title, isCompleted

### 3. `providers/skill_provider.dart`
- A `ChangeNotifier` class that manages:
  - Adding, editing, deleting skills
  - Toggling task status
  - Notifies listeners on updates

### 4. `add_skill.dart`
- UI to input a new skill title, description, and tasks
- On submit, adds skill to Firestore via provider

### 5. `skill_detail.dart`
- UI to display all tasks for a skill
- Checkboxes to mark task complete/incomplete
- Updates Firestore and state via provider

---

## 🧠 Responsibilities
- Define clean and usable models
- Implement state management with Provider
- Connect UI to the logic (add/edit/delete/toggle tasks)
- Maintain live sync with Firestore using Member 1’s functions

---

## ✅ Task Checklist

### 🔹 Task 1: Create Models
- [ ] Define `Skill` class with:
  - id, title, description, List<String> tasks, List<bool> taskStatus, userId
- [ ] Add `toMap()` and `fromMap()` methods
- [ ] Optional: Create separate `Task` class (advanced)

### 🔹 Task 2: Implement Provider
- [ ] Create `SkillProvider` class
- [ ] Define methods: `addSkill()`, `toggleTaskStatus()`, `deleteSkill()`
- [ ] Use `notifyListeners()` after state changes
- [ ] Connect to `FirestoreService` from Member 1

### 🔹 Task 3: Add Skill Screen
- [ ] TextFields for title, description
- [ ] TextField + button to add multiple tasks
- [ ] Submit button to send skill to Firestore
- [ ] Validate empty fields

### 🔹 Task 4: Skill Detail Screen
- [ ] Show skill title and list of tasks
- [ ] Use `CheckboxListTile` for task completion
- [ ] Toggle task status via Provider and Firestore

---

## ⚙️ Code Tips

```dart
class Skill {
  String id;
  String title;
  String description;
  List<String> tasks;
  List<bool> taskStatus;
  String userId;
}
```

```dart
void toggleTask(int skillIndex, int taskIndex) {
  _skills[skillIndex].taskStatus[taskIndex] = !_skills[skillIndex].taskStatus[taskIndex];
  notifyListeners();
}
```

```dart
TextField(
  controller: taskController,
  onSubmitted: (value) => addTask(value),
)
```

---

## 💡 Suggestions
- Test Provider methods in isolation
- Keep model classes clean and readable
- Use `StreamBuilder` in UI to listen for real-time updates
- Add animations/transitions for task completion

---

## 🏁 Final Output
- [ ] Models for `Skill` and optional `Task`
- [ ] Provider managing skills and tasks
- [ ] Add Skill screen working with validations
- [ ] Skill Detail screen with progress tracker

