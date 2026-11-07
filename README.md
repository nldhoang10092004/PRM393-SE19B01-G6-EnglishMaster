# EnglishMaster (PRM393 – SE19B01 – Group 6)

Flutter mobile app for students of the EnglishMaster platform: courses with video lessons,
flashcards, quizzes, saved vocabulary, learning streak and daily study reminders.
The backend REST API is reused from the team's earlier OJT project (EasyEnglish API) and is
deployed separately; it is not part of this repository.

## Tech stack
Flutter 3.47 / Dart 3.13 · Provider · Dio (+ cookie jar, token refresh) · flutter_secure_storage ·
shared_preferences · video_player + chewie · flutter_local_notifications · mocktail (tests)

## Run
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5213   # API on the host, Android emulator
```

## Test & build
```bash
flutter analyze
flutter test
flutter build apk --release --dart-define=API_BASE_URL=https://<api-host>
```

## Docs
- [ARCHITECTURE.md](ARCHITECTURE.md) – layers, folder structure, coding rules
- [DESIGN.md](DESIGN.md) – UI guide per screen
- [PLAN.md](PLAN.md) – scope and timeline
