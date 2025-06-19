# 📁 Folder-Wise README Summary for Skill-Based Learning Tracker App

---

## 📁 member1\_firebase/README.md

### 🔧 Purpose

This folder contains everything related to Firebase setup, authentication, and basic database operations.

### 📄 File Breakdown

| File                 | Description                                                                      |
| -------------------- | -------------------------------------------------------------------------------- |
| `firebase_init.dart` | Initializes Firebase in the app using `Firebase.initializeApp()`                 |
| `auth.dart`          | Handles login, sign up, and logout functions using Firebase Auth                 |
| `database.dart`      | Basic CRUD operations for storing and retrieving skills and tasks from Firestore |

### ✅ Tasks

- Set up Firebase project and link to Flutter app
- Implement email/password login
- Store and fetch data from Firestore
- Secure data using Firestore rules

---

## 📁 member2\_ui/README.md

### 🎨 Purpose

This folder contains all screens, themes, and UI widgets.

### 📄 File Breakdown

| File                  | Description                                                              |
| --------------------- | ------------------------------------------------------------------------ |
| `theme.dart`          | Defines the color scheme, fonts, and text styles used throughout the app |
| `home_screen.dart`    | Main dashboard screen showing progress and quick actions                 |
| `login_screen.dart`   | Login screen layout with fields and buttons                              |
| `widgets/button.dart` | Reusable button widget with custom styling                               |
| `widgets/card.dart`   | Custom card to show skills or progress visually                          |

### ✅ Tasks

- Build login and home screen UIs
- Make UI responsive for all devices
- Use consistent themes and font styles
- Create reusable widgets (buttons, cards, headers)

---

## 📁 member3\_features/README.md

### 🧠 Purpose

This folder contains core logic — data models, state management, and functional screens like Add Skill or View Tasks.

### 📄 File Breakdown

| File                            | Description                                                               |
| ------------------------------- | ------------------------------------------------------------------------- |
| `models/skill.dart`             | Class to represent a learning skill (title, description, tasks, progress) |
| `models/task.dart`              | Represents a task or sub-step under a skill                               |
| `providers/skill_provider.dart` | Holds skill and task data, handles progress tracking using Provider       |
| `add_skill.dart`                | UI screen to input new skill, description, and tasks                      |
| `skill_detail.dart`             | Screen that shows skill info and lets users mark tasks as done            |

### ✅ Tasks

- Define models for Skill and Task
- Implement logic to calculate progress
- Use Provider to manage and update skill/task data
- Connect UI screens to the Provider

---

## 📁 member4\_api\_test/README.md

### 🌐 Purpose

This folder handles external APIs (quotes), leaderboard logic, and basic testing.

### 📄 File Breakdown

| File                    | Description                                                             |
| ----------------------- | ----------------------------------------------------------------------- |
| `leaderboard.dart`      | Screen that shows top users based on number of completed skills         |
| `api_service.dart`      | Fetches daily quotes or tips using an HTTP GET request from public APIs |
| `quote_screen.dart`     | Displays fetched motivational quote inside the UI                       |
| `test/sample_test.dart` | Simple test cases to check API response or widget rendering             |

### ✅ Tasks

- Connect to a motivational quote API like https\://api.quotable.io/random
- Display daily quotes when user is behind schedule
- Build and style leaderboard screen
- Write simple unit/widget test for the API fetch

---

## 📁 utils.dart (Shared)

### 🔍 Purpose

Holds helper functions like:

```dart
void showToast(String message) {
  Fluttertoast.showToast(msg: message);
}
```

Examples:

- Email validation
- Show toast/snackbar
- Time formatting

---

## 📁 routes.dart (Shared)

### 🗺️ Purpose

Central file to manage all screen routes:

```dart
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (_) => LoginScreen(),
  '/home': (_) => HomeScreen(),
  '/add-skill': (_) => AddSkillScreen(),
};
```

Use it in `MaterialApp` like:

```dart
MaterialApp(
  initialRoute: '/login',
  routes: appRoutes,
);
```

