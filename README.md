# JobMate 💼

JobMate is a Flutter-based job and internship application tracker designed to help users discover opportunities, save jobs, apply for them, and track their application status in one place.

## 📱 About the Project

JobMate combines job discovery with application management.

Users can browse jobs fetched through a REST API, search and filter opportunities, save interesting jobs, apply for them, and track their application progress from:

**Applied → Shortlisted → Interview → Selected / Rejected**

The application uses Firebase for authentication, database storage, and notification management.

## ✨ Features

- 🔐 Firebase Email/Password Authentication
- 📝 User Signup & Login
- 🔑 Forgot Password
- 👤 User Profile
- 🔎 Job Search
- 🎯 Job Filters
- 💼 Job & Internship Listings
- 📌 Save / Unsave Jobs
- 📄 Job Details
- 🚀 Apply for Jobs
- 📊 Application Tracker
- 🔄 Application Status Updates
- 🔔 Application Notifications
- 📢 Notification Center
- 🟢 Unread Notification Badge
- 🗑️ Delete Notifications
- 💡 Recommended Jobs based on Skills
- 🔗 LinkedIn & GitHub Profile Links
- 🚪 Secure Logout
- 📱 Responsive Flutter UI

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart
- Material 3

### Backend & Services
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Flutter Local Notifications

### APIs & Data
- REST API
- HTTP
- JSON

### Development Tools
- Android Studio
- Git
- GitHub

## 🏗️ Project Architecture

```text
lib/
├── firebase/
├── models/
│   ├── job_model.dart
│   └── notification_model.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── job_details_screen.dart
│   ├── applications_screen.dart
│   ├── notifications_screen.dart
│   └── profile_screen.dart
│
├── services/
│   ├── job_service.dart
│   ├── saved_job_service.dart
│   ├── application_service.dart
│   ├── notification_service.dart
│   ├── profile_service.dart
│   └── recommendation_service.dart
│
└── main.dart
## 📸 Screenshots

### 🔐 Login

