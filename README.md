# 🌙 Crescent Gate

A premium, modern Society Management System built with **Flutter** & **Firebase**.

## ✨ Features
*   **Role-Based Access**: Residents, Guards, and Admins.
*   **Digital Gate Pass**: Holographic QR codes for guest entry.
*   **Visitor Management**: Real-time approvals with glassmorphic UI.
*   **SOS Alert**: Instant emergency notifications for security.
*   **Notice Board**: Admin announcements pushed to all residents.

## 🚀 Setup Instructions (Important)
This project uses Firebase for the backend. To run it, you must provide your own Firebase configuration.

### 1. Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
*   [Firebase Account](https://firebase.google.com/).

### 2. Configure Firebase
1.  Create a **New Project** in [Firebase Console](https://console.firebase.google.com/).
2.  **Android Setup**:
    *   Add an Android App with package name: `com.crescentgate.app`
    *   Download `google-services.json`.
    *   Place it in: `app/android/app/google-services.json`.
3.  **iOS Setup** (Optional):
    *   Add an iOS App with Bundle ID: `com.crescentgate.app`
    *   Download `GoogleService-Info.plist`.
    *   Place it in: `app/ios/Runner/GoogleService-Info.plist`.
4.  **FlutterFire Configuration**:
    *   Run this command in the `app` folder to generate the Dart config:
        ```bash
        flutterfire configure
        ```
    *   This will create `lib/firebase_options.dart`.

### 3. Run the App
```bash
cd app
flutter pub get
flutter run
```

## 👥 Usage
Please refer to [USER_MANUAL.md](USER_MANUAL.md) for detailed instructions on how to use the app, create the first admin user, and manage the society.

---
*Built with Flutter 3.x*
