FocusNFlow
A campus study organizer built with Flutter and Firebase for CSC 4360 — Mobile Application Development, Spring 2025 at Georgia State University.

What It Does
FocusNFlow helps students find available study rooms, form study groups by course, collaborate in real time, and plan their week around deadlines. The app replaces fragmented group chats and manual scheduling with a centralized, data-driven platform.

Features
Study Room Finder — Live occupancy tracking for campus rooms. Check in and check out using Firestore atomic transactions to prevent race conditions.
Study Groups — Create or join groups tied to a course code. Membership is enforced at the database level via Firestore security rules.
Group Chat — Real-time messaging through a Firestore messages subcollection. Only verified group members can read or write messages.
Shared Pomodoro Timer — A synchronized focus timer stored in Firestore. All group members see the same timer state in real time via a shared document listener.
Session Scheduling with FCM — Schedule study sessions and receive push notification reminders. FCM tokens are stored per user and updated on refresh.
Weekly Study Plan — A rule-based priority engine that scores tasks by deadline urgency, estimated effort, and course weight, then generates an editable 7-day schedule with conflict detection.

Tech Stack

Frontend: Flutter (Dart)
Auth: Firebase Authentication — campus email domain restricted to @student.gsu.edu
Database: Cloud Firestore — real-time listeners, atomic transactions, subcollections
Storage: Firebase Storage — profile photos and group file uploads
Notifications: Firebase Cloud Messaging (FCM)
State Management: Provider (ChangeNotifier)


Study Plan Priority Formula
Tasks are ranked using a transparent scoring formula shown directly in the UI:
score = (courseWeight × 0.4) + (urgencyScore × 0.4) + (effortScore × 0.2)

Urgency: 1.0 if due within 1 day, 0.8 within 3 days, 0.5 within 7 days, 0.2 otherwise
Effort: 1.0 if 5+ hours, 0.6 if 3+ hours, 0.3 otherwise
Course weight: set by the student from 0.1 to 1.0
Hard cap of 4 study hours per day
Conflict detection flags the same course scheduled twice on the same day


Project Structure
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   ├── room_model.dart
│   ├── group_model.dart
│   └── task_model.dart
├── services/
│   ├── auth_service.dart
│   ├── room_service.dart
│   ├── group_service.dart
│   ├── chat_service.dart
│   ├── timer_service.dart
│   ├── notification_service.dart
│   ├── study_plan_service.dart
│   └── storage_service.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── room_finder_screen.dart
│   ├── groups_screen.dart
│   ├── group_detail_screen.dart
│   ├── chat_screen.dart
│   ├── timer_screen.dart
│   ├── schedule_screen.dart
│   └── study_plan_screen.dart
├── widgets/
│   └── room_card.dart
└── utils/
    └── study_plan_engine.dart
test/
└── study_plan_test.dart
firestore.rules

Firebase Setup

Create a Firebase project at console.firebase.google.com
Enable Email/Password Authentication
Create a Firestore database
Enable Firebase Storage
Enable Firebase Cloud Messaging
Run flutterfire configure to generate lib/firebase_options.dart


Running the App
bashflutter pub get
flutter run -d chrome
To run tests:
bashflutter test

Firestore Collections
CollectionDescriptionusers/Student profiles created on registrationrooms/Campus room occupancy — updated via transactionsgroups/Study groups with messages/ subcollectiontasks/Per-user tasks queried by userIdsessions/FCM reminder documents with sessionTime and memberIds

Course
CSC 4360 — Mobile Application Development, Georgia State University, Spring 2025
