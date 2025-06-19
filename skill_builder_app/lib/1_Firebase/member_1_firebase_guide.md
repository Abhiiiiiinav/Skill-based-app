# 🔥 Firebase & Auth - Member 1 Detailed Guide

## 📌 Overview

This module is the backbone of all data-related operations in the Skill-Based Learning Tracker app. You will set up Firebase, manage user authentication (login/register), and handle reading/writing of skills and tasks to Firestore. This guide gives you detailed steps, file explanations, and code organization tips.

---

## 📂 Folder Structure and File Purpose

```
member1_firebase/
├── firebase_init.dart
├── auth.dart
├── database.dart
└── readme.md
```

### 1. `firebase_init.dart`

**Purpose:** Initialize Firebase with platform-specific options.

- Called in `main.dart` before `runApp()`
- Ensures Firebase is ready for use across platforms (Android/iOS/Web)

```dart
Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
}
```

### 2. `auth.dart`

**Purpose:** Handles all authentication logic including:

- Email/password sign in
- Registration
- Sign out
- Retrieving current user

Functions to define:

- `Future<User?> signIn(String email, String password)`
- `Future<User?> signUp(String email, String password)`
- `Future<void> signOut()`
- `User? getCurrentUser()`

### 3. `database.dart`

**Purpose:** Interacts with Firestore to store and fetch skills and tasks.

CRUD functions to include:

- `Future<void> addSkill(Skill skill)`
- `Stream<List<Skill>> getSkills(String userId)`
- `Future<void> updateTask(String skillId, int taskIndex, bool done)`
- `Future<void> deleteSkill(String skillId)`

Use collection structure:

```
skills/
  skillId/
    - title
    - description
    - tasks: ["task 1", "task 2"]
    - taskStatus: [false, true]
    - userId
```

### 4. `readme.md`

**Purpose:** Contains this documentation.

---

## ✅ Detailed Task Checklist

### 🔹 Task 1: Setup Firebase Project

- Go to [https://console.firebase.google.com](https://console.firebase.google.com)
- Create a new project: `skill_tracker`
- Enable Firestore and Email/Password Auth
- Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) and add to Flutter project

### 🔹 Task 2: Initialize Firebase in App

- Add dependencies to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
```

- Create `firebase_init.dart` with `initializeFirebase()` function
- Modify `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(MyApp());
}
```

### 🔹 Task 3: Implement Authentication (`auth.dart`)

- Use `FirebaseAuth` to create `signIn`, `signUp`, `signOut`
- Handle errors (wrong password, user not found)
- Return `User?` so UI knows what to do
- Add `getCurrentUser()` to return currently logged in user

### 🔹 Task 4: Firestore Database Operations (`database.dart`)

- Create function to add a new skill:

```dart
Future<void> addSkill(Skill skill) async {
  await FirebaseFirestore.instance.collection('skills').add(skill.toMap());
}
```

- Use Stream to get real-time updates:

```dart
Stream<List<Skill>> getSkills(String userId) {
  return FirebaseFirestore.instance
    .collection('skills')
    .where('userId', isEqualTo: userId)
    .snapshots()
    .map((snap) => snap.docs.map((doc) => Skill.fromMap(doc.id, doc.data())).toList());
}
```

- Create update and delete functions

### 🔹 Task 5: Write Firestore Rules

In the Firebase Console → Firestore → Rules:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /skills/{skillId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

### 🔹 Task 6: Test Your Features

- Create a dummy login page and connect to `auth.dart`
- Test registration, login, and logout
- Use `StreamBuilder` to watch `getSkills()` output and print result
- Add/remove/edit skills and verify in Firestore Console

---

## 💡 Suggestions & Best Practices

- Wrap all `auth` and `firestore` calls in `try-catch`
- Use `fluttertoast` or `SnackBar` for error feedback
- Make sure `Skill` model has `toMap()` and `fromMap()` methods
- Use meaningful IDs for Firestore documents if needed

---

## 🏁 Final Output

You will deliver:

- ✅ A working Firebase-connected Flutter app
- ✅ Login and register flow
- ✅ Firestore with real-time skills tracking
- ✅ Properly secured Firestore rules
- ✅ Auth and database services ready to connect to UI

---

If you’ve completed this, you’re the team’s data hero 🏆

