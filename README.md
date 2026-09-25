# JobMate 💼

JobMate is a Flutter-based job and internship application tracker designed to help users discover opportunities, save jobs, apply for them, and track their application status in one place.

## 📱 About the Project

JobMate combines job discovery with application management.

Users can browse jobs fetched through a REST API, search and filter opportunities, save interesting jobs, apply for them, and track their application progress from:

**Applied → Shortlisted → Interview → Selected / Rejected**

The application uses Firebase for authentication, database storage, and notification management.

## ✨ Features

* 🔐 Firebase Email/Password Authentication
* 📝 User Signup & Login
* 🔑 Forgot Password
* 👤 User Profile
* 🔎 Job Search
* 🎯 Job Filters
* 💼 Job & Internship Listings
* 📌 Save / Unsave Jobs
* 📄 Job Details
* 🚀 Apply for Jobs
* 📊 Application Tracker
* 🔄 Application Status Updates
* 🔔 Application Notifications
* 📢 Notification Center
* 🟢 Unread Notification Badge
* 🗑️ Delete Notifications
* 💡 Recommended Jobs based on Skills
* 🔗 LinkedIn & GitHub Profile Links
* 🚪 Secure Logout
* 📱 Responsive Flutter UI

## 🛠️ Tech Stack

### Frontend

* Flutter
* Dart
* Material 3

### Backend & Services

* Firebase Authentication
* Cloud Firestore
* Firebase Cloud Messaging
* Flutter Local Notifications

### APIs & Data

* REST API
* HTTP
* JSON

### Development Tools

* Android Studio
* Git
* GitHub

## 🏗️ Project Architecture

```text
lib/
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
```

## 🔥 Firebase

JobMate uses Firebase for:

* Email and password authentication
* User profile data
* Saved jobs
* Job applications
* Application status tracking
* In-app notification records
* Firebase Cloud Messaging

## 🔔 Notification System

JobMate provides notifications for important application events, including:

* Application submitted
* Application shortlisted
* Interview stage
* Application selected
* Application rejected
* Application status updates

The app also supports local Android notifications for application-related updates.

## 🌐 REST API

Job listings are fetched using a REST API.

The application uses:

* HTTP requests
* JSON data
* Dart model classes
* Error handling
* API-to-model data conversion

## 📊 Application Tracking

Users can track their application progress through:

**Applied → Shortlisted → Interview → Selected / Rejected**

This allows users to manage multiple job applications from one place.

## 🎯 Job Recommendations

JobMate includes a basic skill-based recommendation system.

Users can add their skills to their profile, and the application compares those skills with available job information to provide relevant job recommendations.

## 🚀 Getting Started

### Prerequisites

Make sure you have installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Git

### Clone the Repository

```bash
git clone https://github.com/aryanikhil2812/jobmate.git
```

### Open the Project

```bash
cd jobmate
```

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

## 📸 Screenshots

### 🔐 Login

![Login Screen](https://raw.githubusercontent.com/aryanikhil2812/jobmate/aa7cb41bcd2682abf695287a648e3730519f6775/Screenshot_2026-09-25-13-26-07-54_93dde8a4984b3eb6ef5d741ad47f8280.jpg)


### 🏠 Home

![Home Screen](https://raw.githubusercontent.com/aryanikhil2812/jobmate/aa7cb41bcd2682abf695287a648e3730519f6775/Screenshot_2026-09-25-13-26-25-80_93dde8a4984b3eb6ef5d741ad47f8280.jpg)

### 📄 Job Details

![Job Details](https://raw.githubusercontent.com/aryanikhil2812/jobmate/aa7cb41bcd2682abf695287a648e3730519f6775/Screenshot_2026-09-25-13-26-39-76_93dde8a4984b3eb6ef5d741ad47f8280.jpg)

### 📌 Saved Jobs

![Saved Jobs](https://raw.githubusercontent.com/aryanikhil2812/jobmate/aa7cb41bcd2682abf695287a648e3730519f6775/Screenshot_2026-09-25-13-26-46-99_93dde8a4984b3eb6ef5d741ad47f8280.jpg)

### 📊 Applications

![Applications](https://raw.githubusercontent.com/aryanikhil2812/jobmate/aa7cb41bcd2682abf695287a648e3730519f6775/Screenshot_2026-09-25-13-27-03-56_93dde8a4984b3eb6ef5d741ad47f8280.jpg)

### 🔔 Notifications

![Notifications](https://raw.githubusercontent.com/aryanikhil2812/jobmate/aa7cb41bcd2682abf695287a648e3730519f6775/Screenshot_2026-09-25-13-27-12-62_93dde8a4984b3eb6ef5d741ad47f8280.jpg)

### 👤 Profile

![Profile](https://raw.githubusercontent.com/aryanikhil2812/jobmate/aa7cb41bcd2682abf695287a648e3730519f6775/Screenshot_2026-09-25-13-27-22-00_93dde8a4984b3eb6ef5d741ad47f8280.jpg)


## 🔮 Future Improvements

* Profile photo upload
* Resume upload
* Advanced job recommendation system
* Employer/company accounts
* Admin dashboard
* Real-time employer application updates
* More job APIs
* Release APK/AAB

## 👨‍💻 Developer

**Nikhil Arya**

B.Tech Computer Science & Engineering

GitHub: https://github.com/aryanikhil2812

LinkedIn: https://linkedin.com/in/nikhil-arya-5199372a

## 📄 License

This project is created for learning, portfolio, and educational purposes.

