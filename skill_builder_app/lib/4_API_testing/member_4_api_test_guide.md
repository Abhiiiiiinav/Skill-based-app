# 🌐 API, Leaderboard & Testing - Member 4 Guide

## 📌 Overview
This folder handles all third-party API integration (motivational quotes), leaderboard logic based on skills completed, and app testing. Your goal is to create a dashboard-enhancing quote feature, build a leaderboard from Firestore, and ensure basic app reliability with tests.

---

## 📂 Folder Structure and File Purpose
```
member4_api_test/
├── leaderboard.dart
├── api_service.dart
├── quote_screen.dart
├── test/
│   └── sample_test.dart
└── readme.md
```

### 1. `leaderboard.dart`
- Displays ranked users by number of completed skills
- Pulls data from Firestore and processes into a sorted list

### 2. `api_service.dart`
- Handles HTTP GET requests to fetch motivational quotes from APIs like `https://api.quotable.io/random`
- Returns quote and author as strings

### 3. `quote_screen.dart`
- Displays a quote when user is behind schedule
- Called on dashboard or as a modal
- Uses `FutureBuilder` to display API result

### 4. `test/sample_test.dart`
- Contains simple widget and API test cases
- Confirms UI renders properly and quote API returns data

---

## 🧠 Responsibilities
- Fetch motivational content from external API
- Design quote display (card, modal, banner)
- Create leaderboard from Firestore data
- Sort and rank users visually
- Write unit/widget tests for the app

---

## ✅ Task Checklist

### 🔹 Task 1: Setup HTTP Package
- [ ] Add `http` to `pubspec.yaml`
```yaml
dependencies:
  http: ^0.13.5
```
- [ ] Create `api_service.dart`
- [ ] Write `Future<String> getDailyQuote()` using `http.get()`

### 🔹 Task 2: Create Quote Display Widget
- [ ] Design `quote_screen.dart` to show fetched quote
- [ ] Use `FutureBuilder` to wait for API data
- [ ] Add a loading indicator and fallback message
- [ ] Connect it to `home_screen.dart` from Member 2

### 🔹 Task 3: Build Leaderboard
- [ ] Create `leaderboard.dart` screen
- [ ] Fetch all skills from Firestore
- [ ] Count how many skills are 100% complete per user
- [ ] Sort and display rankings using `ListView`
- [ ] Highlight current user

### 🔹 Task 4: Write Tests
- [ ] Add `flutter_test` to `dev_dependencies`
- [ ] Create widget test for `quote_screen.dart`
- [ ] Create mock test for API response

---

## ⚙️ Code Tips
```dart
final response = await http.get(Uri.parse("https://api.quotable.io/random"));
final data = jsonDecode(response.body);
return "\"${data['content']}\" — ${data['author']}";
```

```dart
ListView.builder(
  itemCount: leaderboard.length,
  itemBuilder: (ctx, i) => ListTile(
    title: Text(leaderboard[i].name),
    trailing: Text("${leaderboard[i].score} Skills"),
  ),
);
```

```dart
testWidgets('Quote appears', (tester) async {
  await tester.pumpWidget(MaterialApp(home: QuoteScreen()));
  expect(find.byType(Text), findsWidgets);
});
```

---

## 💡 Suggestions
- Use caching to avoid API calls on every app open
- Add error messages and retry button for quote fetch
- Display quote only when a user falls behind (ask team)
- Consider a `LeaderboardProvider` for future scalability

---

## 🏁 Final Output
- [ ] API integrated to fetch quotes
- [ ] Quote shown on dashboard or popup
- [ ] Leaderboard screen ranks users
- [ ] At least 1 test runs successfully

