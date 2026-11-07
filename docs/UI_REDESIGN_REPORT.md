# Avatar and visual redesign report

Implemented the requested avatar flow and visual refresh while retaining
Screen → Provider → Repository → ApiClient, existing provider APIs and feature
navigation. Interface copy remains in Vietnamese localization classes.

## Avatar

- Camera-badged avatar opens “Chọn ảnh từ thư viện” / “Chụp ảnh”. Both paths
  request maxWidth 512 and imageQuality 85. Canceling leaves the current photo.
- ProfileRepository uploads to PUT /api/user/profile/avatar with multipart field
  File, matching the read-only backend DTO. A missing avatarUrl is treated as a
  failed response. Dio supplies the image MIME type from the picked filename.
- ProfileProvider publishes upload progress and the new URL; both ProfileScreen
  and HomeGreeting observe the shared state. Failures keep the old photo and
  display friendly Vietnamese copy. Duplicate uploads are ignored.
- Multipart streams are cloned when the API client retries after token refresh.
  An Android picker result interrupted by activity destruction is recovered.
- The [image_picker README](https://pub.dev/packages/image_picker#android)
  requires no additional Android configuration/permissions. The manifest records
  that decision; no broad media/storage or camera permission was introduced.

## Visual changes

Indigo #3D5AFE, warm reward tones, bundled Be Vietnam Pro, tonal surfaces,
20 dp cards, 14 dp controls, navigation indicators, shared hero/stat/section
components, tinted empty/error illustrations and opacity skeleton loading.
The course catalog carousel opens existing details and uses available catalog
data; it does not invent resume positions, ratings or progress.

Writing/speaking AI pages, quiz list and existing history/forms also inherit the
new theme and their shared widgets. No feature or meaningful test was removed.

## New direct dependencies

- [image_picker](https://pub.dev/packages/image_picker): ^1.2.4.
- [google_fonts](https://pub.dev/packages/google_fonts/versions/8.2.1): ^8.2.1.
  Version 8.2.1 retains compatibility with the app's flutter/material.dart types;
  version 9 migrated to the separate material_ui package. Four local font
  weights and their SIL Open Font License are bundled for offline use.

## Verification

- flutter analyze: No issues found.
- flutter test: 143 tests passed.
- New coverage: 5 avatar API/provider unit tests, 5 avatar picker widget tests,
  and 42 layout tests (21 page/state layouts × light/dark at 360 dp).
- Avatar tests cover PUT field/MIME/auth, multipart retry after 401, invalid
  response, busy/duplicate/disposal behavior, failure retention, gallery/camera
  resizing, cancellation, permissions, Android recovery and shared greeting sync.
- Existing membership assertions now scroll to the checkout button before
  locating it. Existing behavior assertions remain in place.
- Rendered review PNGs are available in build/design-review; checked long names,
  course titles, prices, flashcard faces, AI screens and payment contrast.
- git diff --check: clean (with CRLF-aware whitespace handling).

## Local verification environment

The installed Flutter SDK is read-only to this session. Checks used a workspace
copy of the same Flutter 3.47.6 / Dart 3.13.5 SDK and a temporary drive alias to
avoid the native-hook runner's Windows path-with-spaces issue. The original
Android SDK configuration was restored after verification. Automatic approval
review rejected removal of the temporary SDK with “blocked by policy”, so the
copy and helper scripts remain under the Git-ignored .dart_tool directory.

## Not exercised

Native camera/photo-picker interaction, live backend/storage upload, and real
video/audio playback were not run on a physical device. Picker/API behavior was
verified with mocks and an in-memory Dio adapter. No integration tests were run.
No backend files were changed. No git commit or push was made.

## Changed files by screen/group

### Theme, shared widgets, fonts and copy

- [assets/fonts/BeVietnamPro-Bold.ttf](../assets/fonts/BeVietnamPro-Bold.ttf)
- [assets/fonts/BeVietnamPro-Medium.ttf](../assets/fonts/BeVietnamPro-Medium.ttf)
- [assets/fonts/BeVietnamPro-Regular.ttf](../assets/fonts/BeVietnamPro-Regular.ttf)
- [assets/fonts/BeVietnamPro-SemiBold.ttf](../assets/fonts/BeVietnamPro-SemiBold.ttf)
- [assets/fonts/OFL.txt](../assets/fonts/OFL.txt)
- [lib/core/l10n/app_strings.dart](../lib/core/l10n/app_strings.dart)
- [lib/core/network/api_client.dart](../lib/core/network/api_client.dart)
- [lib/core/theme/app_theme.dart](../lib/core/theme/app_theme.dart)
- [lib/core/widgets/async_view.dart](../lib/core/widgets/async_view.dart)
- [lib/core/widgets/gradient_hero_card.dart](../lib/core/widgets/gradient_hero_card.dart)
- [lib/core/widgets/score_ring.dart](../lib/core/widgets/score_ring.dart)
- [lib/core/widgets/section_header.dart](../lib/core/widgets/section_header.dart)
- [lib/core/widgets/skeleton_loading.dart](../lib/core/widgets/skeleton_loading.dart)
- [lib/core/widgets/stat_tile.dart](../lib/core/widgets/stat_tile.dart)
- [lib/core/widgets/user_avatar.dart](../lib/core/widgets/user_avatar.dart)

### Authentication: login, registration, password reset

- [lib/features/auth/presentation/screens/forgot_password_screen.dart](../lib/features/auth/presentation/screens/forgot_password_screen.dart)
- [lib/features/auth/presentation/screens/login_screen.dart](../lib/features/auth/presentation/screens/login_screen.dart)
- [lib/features/auth/presentation/screens/register_screen.dart](../lib/features/auth/presentation/screens/register_screen.dart)

### Home and streak

- [lib/features/home/presentation/screens/home_screen.dart](../lib/features/home/presentation/screens/home_screen.dart)
- [lib/features/home/presentation/widgets/home_greeting.dart](../lib/features/home/presentation/widgets/home_greeting.dart)
- [lib/features/streak/presentation/widgets/streak_card.dart](../lib/features/streak/presentation/widgets/streak_card.dart)

### Courses: carousel, list and course detail

- [lib/features/course/presentation/screens/course_detail_screen.dart](../lib/features/course/presentation/screens/course_detail_screen.dart)
- [lib/features/course/presentation/widgets/course_card.dart](../lib/features/course/presentation/widgets/course_card.dart)
- [lib/features/course/presentation/widgets/course_preview_card.dart](../lib/features/course/presentation/widgets/course_preview_card.dart)

### Video lesson

- [lib/features/video/presentation/screens/video_lesson_screen.dart](../lib/features/video/presentation/screens/video_lesson_screen.dart)

### Flashcard catalog and study

- [lib/features/flashcard/presentation/screens/flashcard_sets_screen.dart](../lib/features/flashcard/presentation/screens/flashcard_sets_screen.dart)
- [lib/features/flashcard/presentation/screens/flashcard_study_screen.dart](../lib/features/flashcard/presentation/screens/flashcard_study_screen.dart)
- [lib/features/flashcard/presentation/widgets/flashcard_set_tile.dart](../lib/features/flashcard/presentation/widgets/flashcard_set_tile.dart)

### Quiz list, detail, taking and result

- [lib/features/quiz/presentation/screens/quiz_detail_screen.dart](../lib/features/quiz/presentation/screens/quiz_detail_screen.dart)
- [lib/features/quiz/presentation/screens/quiz_result_screen.dart](../lib/features/quiz/presentation/screens/quiz_result_screen.dart)
- [lib/features/quiz/presentation/screens/quiz_taking_screen.dart](../lib/features/quiz/presentation/screens/quiz_taking_screen.dart)
- [lib/features/quiz/presentation/widgets/quiz_catalog.dart](../lib/features/quiz/presentation/widgets/quiz_catalog.dart)

### AI hub, listening and shared exercise/result cards

- [lib/features/ai_exam/presentation/screens/ai_exam_hub_screen.dart](../lib/features/ai_exam/presentation/screens/ai_exam_hub_screen.dart)
- [lib/features/ai_exam/presentation/screens/ai_listening_screen.dart](../lib/features/ai_exam/presentation/screens/ai_listening_screen.dart)
- [lib/features/ai_exam/presentation/widgets/ai_prompt_card.dart](../lib/features/ai_exam/presentation/widgets/ai_prompt_card.dart)
- [lib/features/ai_exam/presentation/widgets/ai_score_card.dart](../lib/features/ai_exam/presentation/widgets/ai_score_card.dart)

### Membership plans and payment QR

- [lib/features/membership/presentation/screens/membership_screen.dart](../lib/features/membership/presentation/screens/membership_screen.dart)
- [lib/features/membership/presentation/screens/payment_qr_screen.dart](../lib/features/membership/presentation/screens/payment_qr_screen.dart)

### Profile and avatar upload

- [lib/features/profile/data/profile_repository.dart](../lib/features/profile/data/profile_repository.dart)
- [lib/features/profile/presentation/providers/profile_provider.dart](../lib/features/profile/presentation/providers/profile_provider.dart)
- [lib/features/profile/presentation/screens/profile_screen.dart](../lib/features/profile/presentation/screens/profile_screen.dart)

### Vocabulary

- [lib/features/vocabulary/presentation/screens/vocabulary_screen.dart](../lib/features/vocabulary/presentation/screens/vocabulary_screen.dart)

### Reminder settings

- [lib/features/notifications/presentation/screens/reminder_settings_screen.dart](../lib/features/notifications/presentation/screens/reminder_settings_screen.dart)

### Android and dependencies

- [android/app/src/main/AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml)
- [pubspec.lock](../pubspec.lock)
- [pubspec.yaml](../pubspec.yaml)

### Tests

- [test/unit/profile/avatar_test.dart](../test/unit/profile/avatar_test.dart)
- [test/widget/design/responsive_screens_test.dart](../test/widget/design/responsive_screens_test.dart)
- [test/widget/membership/membership_screen_test.dart](../test/widget/membership/membership_screen_test.dart)
- [test/widget/profile/avatar_picker_test.dart](../test/widget/profile/avatar_picker_test.dart)

### Design documentation and report

- [DESIGN.md](../DESIGN.md)
- [docs/UI_REDESIGN_REPORT.md](../docs/UI_REDESIGN_REPORT.md)
