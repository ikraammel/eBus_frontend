# 🚌 eBus — Flutter Frontend

**eBus Frontend** is a cross-platform application built with **Flutter and Dart**, designed to provide an intuitive interface for a smart transportation management platform.

It allows passengers and administrators to access transportation services, manage subscriptions, track lost items, submit complaints, and interact with real-time information.

## 🛠️ Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-DD2C00?style=for-the-badge&logo=firebase&logoColor=white)
![BLoC](https://img.shields.io/badge/Flutter_BLoC-5A67D8?style=for-the-badge&logo=flutter&logoColor=white)
![Stripe](https://img.shields.io/badge/Stripe-635BFF?style=for-the-badge&logo=stripe&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Render](https://img.shields.io/badge/Render-000000?style=for-the-badge&logo=render&logoColor=white)

## 🔗 Repositories & Deployment

| Component | GitHub Repository | Deployment |
|---|---|---|
| ⚙️ Backend API | [eBus Backend](https://github.com/ikraammel/eBus_backend) | [Render API](https://ebus-backend-ao2u.onrender.com) |
| 📱 Flutter Frontend | [eBus Frontend](https://github.com/ikraammel/eBus_frontend) | [Live Application](https://ebus-frontend-1an4.onrender.com/) |
| 🧪 QA Automation | [eBus QA Automation](https://github.com/FATIMA-BOUSMITI/eBus-qa-automation) | Local & Automated Testing |

## ✨ Frontend Features

- **Authentication & User Profiles:** Login, registration, profile management, and role-based navigation.
- **Transportation Information:** Browse bus routes, stations, and schedules.
- **Subscriptions & Payments:** View subscription plans and access Stripe payment flows.
- **Lost & Found:** Report, browse, and track lost items.
- **Complaints Management:** Submit complaints and follow their status.
- **Interactive Maps:** Access transportation-related map views.
- **Admin Dashboard:** View operational statistics, KPIs, and recent activities.
- **Administrative Management:** Interfaces for managing buses, routes, schedules, complaints, and lost items.
- **Real-Time Integration:** Firebase Realtime Database connectivity.

## 🏗️ Architecture

The frontend follows the **BLoC (Business Logic Component)** pattern for state management, separating user interfaces from application logic.

```text
Flutter UI (Screens & Widgets)
             ↓
     BLoC State Management
             ↓
       Service Layer
             ↓
    ┌────────┴────────┐
    ↓                 ↓
Spring Boot API   Firebase Realtime
    ↓                 Database
PostgreSQL
```

**Additional integrations:** GetIt for dependency injection, SharedPreferences for local storage, and Stripe payment flows.

## 📁 Project Structure

```text
eBus_frontend/
├── lib/
│   ├── bloc/
│   ├── models/
│   ├── services/
│   ├── views/
│   ├── enums/
│   ├── firebase_options.dart
│   └── main.dart
├── android/
├── web/
├── pubspec.yaml
└── README.md
```

## 🚀 Getting Started

**Prerequisites:** Flutter SDK, Dart SDK, Git, and Chrome or an Android emulator/device.

**1. Clone the repository**

```bash
git clone https://github.com/ikraammel/eBus_frontend.git
cd eBus_frontend
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Configure the backend API**

Ensure the Spring Boot backend is running and accessible.

If your frontend reads `API_BASE_URL` through `String.fromEnvironment`, you can configure the backend address using `--dart-define`.

**4. Run the application**

For Web:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

For Android:

```bash
flutter devices
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

`10.0.2.2` allows the standard Android emulator to access the host machine's local backend.

**5. Build for production**

```bash
flutter build web --release --dart-define=API_BASE_URL=https://ebus-backend-ao2u.onrender.com
```

The generated Web application is available in `build/web/`.

## 🔥 Firebase Integration

The Flutter application integrates **Firebase Realtime Database** for real-time data connectivity.

Firebase is initialized through the official FlutterFire SDK using `firebase_options.dart`.

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Firebase database access is managed through Firebase security rules. Administrative service-account credentials are not required in the Flutter application.

## 🐳 Docker

Build the Flutter Web image:

```bash
docker build --build-arg API_BASE_URL=https://ebus-backend-ao2u.onrender.com -t ebus-frontend .
```

Run the container locally:

```bash
docker run -d --name ebus-frontend -p 8082:80 ebus-frontend
```

Open the application at `http://localhost:8082`.

These commands assume the repository's Dockerfile supports the `API_BASE_URL` build argument and serves Flutter Web on port 80.

## 🧪 Frontend Testing

Flutter provides tools for static analysis and automated testing.

Run static analysis:

```bash
flutter analyze
```

Run available Flutter tests:

```bash
flutter test
```

For end-to-end Web, Android, API, and performance testing, visit the [QA Automation Repository](https://github.com/FATIMA-BOUSMITI/eBus-qa-automation).

## 🔐 Security

- Role-based navigation for passengers and administrators.
- Backend authentication and authorization through Spring Boot.
- Firebase access controlled by database security rules.
- Sensitive credentials excluded from version control.
- API endpoints configured according to the target environment.
- HTTPS communication for deployed services.

## 📄 Related Projects

- [eBus Spring Boot Backend](https://github.com/ikraammel/eBus_backend)
- [eBus QA Automation](https://github.com/FATIMA-BOUSMITI/eBus-qa-automation)

---

**eBus — Smart Transportation Management System**
