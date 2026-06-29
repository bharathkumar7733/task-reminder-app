# Task Reminder App ⏰✨

A premium, highly interactive, and beautiful task management & reminder application built with **Flutter and Dart**. It enables users to organize their daily schedule, set exact time-based reminders, receive native local push notifications, persist tasks locally, and enjoy a seamless transition between light and dark modes.

---

## 🌟 Key Features

- **🔔 Native Local Notifications**: Automatically schedules and triggers high-priority alerts using `flutter_local_notifications` integrated with the `timezone` package.
- **💾 Local Data Persistence**: Saves and loads all task items (title, reminder time, completion status) across app launches using `shared_preferences`.
- **🎨 Curated Neon Color Theme**:
  - **Light Mode**: Deep purple accents with clean, high-contrast surfaces (`#9A48D0`).
  - **Dark Mode**: Soft neon lavender and purple theme designed for comfortable night-time reading (`#E4B7E5`).
- **🔄 Smooth Interactive Transitions**: Incorporates `AnimatedSwitcher` to create elegant, fade-in transitions when navigating between screen views.
- **📱 Clean Modern Layout**: Designed with a notched floating action button, bottom app navigation bar, and clean interactive lists.

---

## 🛠️ Tech Stack & Libraries

- **Framework**: [Flutter SDK](https://flutter.dev/) (target Dart SDK: `^3.9.2`)
- **State Management**: Stateful widgets with optimized layout lifecycle hooks (`initState`, `setState`).
- **External Dependencies**:
  - `shared_preferences` - For offline key-value storage.
  - `flutter_local_notifications` - For native scheduling of notifications on Android & iOS.
  - `timezone` - For accurate cross-timezone alert scheduling.
  - `cupertino_icons` - For clean, iOS-style vector design assets.

---

## 📂 File Architecture

The core application code is structured clean and compact:
```
├── lib/
│   └── main.dart           # App entry, state management, screens, and models
├── pubspec.yaml            # Project metadata, assets, and package dependencies
├── android/                # Native Android resources (notification permissions, launcher icons)
└── ios/                    # Native iOS configuration files
```

### Main Code Components inside `lib/main.dart`
- **`AppColors`**: A dedicated palette manager defining custom light and dark mode colors.
- **`Task`**: The data model representing tasks, storing titles, scheduling dates, and completion status.
- **`TaskReminderApp`**: State initialization, notification triggers, timezone setup, and overall routing wrapper.
- **`HomeScreen`**: Lists all active tasks, toggles task completion, and deletes tasks with swipe/click actions.
- **`AddTaskScreen`**: Interactive task creation containing text fields and Date/Time picker modals.
- **`SettingsScreen`**: App personalization suite hosting the theme toggle switch.

---

## 🚀 Getting Started & Setup

### Prerequisites
Make sure you have Flutter installed and configured on your machine. You can verify this by running:
```bash
flutter doctor
```

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/bharathkumar7733/flutter.git
   cd flutter
   ```

2. **Get all package dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify devices connected**:
   ```bash
   flutter devices
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---
Developed with ❤️ by [bharathkumar7733](https://github.com/bharathkumar7733)
