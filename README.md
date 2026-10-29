# Bondly — Flutter + Firebase

Bondly is a modern, cross-platform Flutter application built with direct **Firebase** integration:
- ⚡ **Cloud Firestore**: Real-time NoSQL database with live stream subscriptions
- 📁 **Firebase Storage**: Secure file and image storage with download URLs
- 🔐 **Firebase Auth**: User identity management and secure access
- 🎨 **Material 3 UI**: Clean dashboard with 1-click test upload, file picker, and real-time feed

---

## 🏗️ Architecture

```
Bondly/
├── lib/
│   ├── firebase_options.dart      # Platform FirebaseOptions (Web, Android, iOS, Windows, macOS)
│   ├── models/
│   │   └── file_item.dart         # File item model with Firestore document serialization
│   ├── services/
│   │   └── firebase_service.dart  # Firestore streams, Storage uploads, Auth, & offline simulator
│   └── main.dart                  # Material 3 UI with live Firestore StreamBuilder
├── test/
│   └── widget_test.dart           # Automated Flutter widget test suite
├── web/                           # Flutter Web support
├── android/                       # Android native project
├── ios/                           # iOS native project
├── windows/                       # Windows Desktop support
└── pubspec.yaml                   # Flutter dependencies
```

---

## 🚀 Quick Start

### 1. Run the App Immediately (Demo / Simulator Mode)
The app is configured to compile and run out of the box with zero setup:
```bash
# Run on Web (Chrome):
flutter run -d chrome

# Or run on Windows Desktop:
flutter run -d windows
```

You can test the full upload and real-time UI by clicking the **"1-Click Demo Upload"** button or selecting any file.

---

### 2. Connect to Your Firebase Console Project

To link this app to your live Firebase project:

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. **Configure your project**:
   ```bash
   flutterfire configure
   ```
   Select your Firebase project and platforms. This will automatically update `lib/firebase_options.dart` with your real production API keys and project settings.

4. **Enable Services in [Firebase Console](https://console.firebase.google.com)**:
   - **Authentication**: Enable *Anonymous* or *Email/Password* provider.
   - **Cloud Firestore**: Create database in production or test mode.
   - **Firebase Storage**: Create storage bucket.

---

## 🧪 Verification & Testing

- **Static Analysis**:
  ```bash
  flutter analyze
  ```
  *(0 issues found)*

- **Widget & Unit Tests**:
  ```bash
  flutter test
  ```
  *(All tests passed)*

- **Production Web Build**:
  ```bash
  flutter build web
  ```
