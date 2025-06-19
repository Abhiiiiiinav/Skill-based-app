# 🎨 UI & Layout - Member 2 Guide

## 📌 Overview
This folder contains all the UI design and layout-related files. Your goal is to make the app clean, easy to use, responsive across all screen sizes, and visually appealing. You will handle login and home screens, theming, and reusable components like buttons and cards.

---

## 📂 Folder Structure and File Purpose

```
member2_ui/
├── theme.dart
├── home_screen.dart
├── login_screen.dart
├── widgets/
│   ├── button.dart
│   └── card.dart
└── readme.md
```

### 1. `theme.dart`
Defines color palette, text styles, and visual theme.

- Export `ThemeData`
- Define light/dark colors
- Store fonts and text sizes in `TextStyle`

### 2. `home_screen.dart`
Dashboard screen after login.

- Shows welcome message
- Progress card (overall percentage)
- Buttons to Add Skill and View Leaderboard
- Optionally show a motivational quote (API)

### 3. `login_screen.dart`
Screen for email/password login.

- Input fields (TextFormField)
- Login button (connect to Member 1 logic)
- Optional: Forgot Password or Register link

### 4. `widgets/button.dart`
Reusable button widget for consistent design.

```dart
CustomButton(text: "Add Skill", onPressed: () {})
```

### 5. `widgets/card.dart`
Reusable card widget to show skills or progress.

```dart
SkillCard(title: "Learn Flutter", progress: 70%)
```

---

## 🧠 Responsibilities
- Build responsive screens for Login and Home
- Create a visual theme used by the whole app
- Style the progress cards and action buttons
- Ensure layout looks good on phones and tablets

---

## ✅ Task Checklist

### 🔹 Task 1: Setup Theme
- [ ] Create `theme.dart` with `ThemeData`
- [ ] Add color variables (primary, accent, background)
- [ ] Add `TextStyle` for headings, buttons, etc.

### 🔹 Task 2: Build Login Screen
- [ ] Add email and password input fields
- [ ] Add login button
- [ ] Style with padding, colors, and fonts
- [ ] Connect to `auth.signIn()` from Member 1

### 🔹 Task 3: Build Home Screen
- [ ] Add welcome message
- [ ] Add progress summary card
- [ ] Add 2 buttons: Add Skill, Leaderboard
- [ ] Layout: Column with spacing or use Grid
- [ ] Optionally: Show a motivational quote from API

### 🔹 Task 4: Create Shared Widgets
- [ ] Create `CustomButton` with color and text style
- [ ] Create `SkillCard` widget with title and progress bar

---

## ⚙️ Code Tips

```dart
ThemeData appTheme = ThemeData(
  primaryColor: Colors.blue,
  textTheme: TextTheme(
    headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    bodyText2: TextStyle(fontSize: 16),
  ),
);
```

```dart
ElevatedButton(
  onPressed: onPressed,
  child: Text(text),
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
)
```

---

## 💡 Suggestions
- Use `MediaQuery` and `LayoutBuilder` for responsiveness
- Use `fluttertoast` or `SnackBar` to show messages
- Keep UI code modular and reusable
- Stick to Material 3 design patterns

---

## 🏁 Final Output
- [ ] `theme.dart` with fonts and colors
- [ ] `login_screen.dart` that logs the user in
- [ ] `home_screen.dart` with progress and buttons
- [ ] `CustomButton` and `SkillCard` widgets for reuse

