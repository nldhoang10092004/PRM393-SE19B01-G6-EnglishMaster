# EnglishMaster — Khối màu tươi

The approved source is `docs/design/claude-design/*.dc.html`. Main defines the
components; the 390 × 844 screen references define hierarchy, spacing and copy.
Flutter screens adapt to 360dp, longer API content, keyboards and text scaling.

## Tokens and typography

AppTheme maps Material 3 roles and registers AppPalette, a ThemeExtension with
semantic surface, primary, reward and SkillColors tokens. Screens never contain
literal colours. All UI copy lives in AppStrings or the feature Strings class.

| Role | Light tokens |
| --- | --- |
| Page / surface / muted | #FFFBF6 / #FFFFFF / #F3ECE3 |
| Outline / ink / muted ink | #EADFD2 / #1C1B2E / #5B5870 |
| Primary / edge / soft / soft ink | #3D5AFE / #2638C9 / #E3E8FF / #1C2A8F |
| Reward / reward ink | #FF9B26 / #3D1E00 |
| Speaking background / ink / edge | #FFE3C2 / #6B3300 / #F2C48F |
| Listening background / ink / edge | #CFF3DA / #0E5A2B / #9ED9B1 |
| Writing background / ink / edge | #E6DCFF / #4B2A9E / #C4B2F2 |
| Reading quiz background / ink / edge | #D6E6FF / #123F8C / #A9C6F5 |
| Error text | #B3261E |

Primary is the action, selection and navigation colour. Orange is reserved for
streaks, rewards and the recommended-plan badge. Reading blue identifies reading
quizzes; Home has exactly three AI shortcuts: speaking, listening and writing.
Dark mode uses warm dark surfaces and lighter matching hues. Semantic text pairs
are checked for at least 4.5:1 contrast in both themes. QR paper and ink remain
white and #171923 for scanning in either theme.

Be Vietnam Pro is bundled locally at weights 400, 500, 600, 700 and 800; the
ExtraBold font shares the existing OFL license. Titles are 28/800, sections 20–22/800,
body 15–16 with 1.5 line height, captions 12–13. No runtime font fetch is required.

## Geometry and shared widgets

Cards use radius 24, hero blocks 28, inputs/buttons 16, icon controls 14, pills 999.
Outlines are 2dp. Screen gutters are normally 20dp, authentication gutters 24dp.
Spacing follows 4/8/12/16/24/32dp. Surfaces are flat: no gradients or blurred shadows.
Solid bottom edges may distinguish raised controls and study cards.

- ChunkyButton: primary face at least 56dp tall, 4dp primary-edge bottom; pressing
  moves the face down 4dp and removes the edge. Material keyboard, focus, disabled,
  semantics and cancellation behaviour are retained. Radius can support recording.
- ChunkyOutlinedButton: white/surface secondary face, 2dp outline and solid outline
  edge, with the same pressed geometry.
- SkillTile: 116dp skill block with icon, title and semantic solid edge.
- OutlinedCard: configurable flat bordered card, optional solid edge and tap action.
- IconSquareButton and AppTopBar: 44dp square navigation controls and compact headers.
- ScoreRing: primary score arc, scalable label and optional denominator; also used
  compactly with real flashcard mastery counts.
- PillChip: filters, selected states and semantic badges.
- MascotMimi: local CustomPainter speech-bubble mascot for Login and AI generation.
- FlatHeroCard replaces the old gradient hero; SectionHeader, StatTile, UserAvatar,
  AsyncView, MessageView and SkeletonLoading share the same system.

## Screens and behaviour

The state-preserving IndexedStack shell has five tabs: Trang chủ, Khóa học,
Thẻ ghi nhớ, Bài kiểm tra, Hồ sơ. The selected destination uses a primary-soft
pill and primary icon/label. Home's Xem tất cả selects the course tab. The separate
CourseListScreen shares CourseListProvider, searches names and teachers locally,
supports pull-to-refresh, and opens the existing course-detail flow.

Course summaries expose no progress percentage, so catalog rows render real API
names, teachers and coloured initials without fabricated progress. Course detail
keeps chapters, completion checks, videos, quizzes and reviews, plus a lesson CTA.
Daily goal blocks use the actual current streak; no synthetic activity total is shown.

Login has the brand and Mimi above the existing validated form. Profile retains
avatar picking, Android lost-data recovery, upload feedback and membership renewal.
Account forms, history, vocabulary, reminders and video use the shared controls.

Flashcards show real mastered/total rings and all/studying/mastered filters. Study
retains flip/swipe, explicit previous/next, Học lại, Đã thuộc, restart, saved words,
progress and pending/error states. Content can scroll inside the study face.

Quiz audio stays above the question scroll view; its controller belongs to the
attempt provider and is reused across questions. Answers use bordered selectable
blocks. Results show server scores, correct/wrong/pending counts and answer review.
The API exposes no quiz countdown or elapsed result duration, so neither is invented.

AI screens use speaking/listening/writing prompt blocks, primary recording controls,
pinned listening audio and bottom submit actions. AiGeneratingView shows Mimi,
estimated steps and progress, elapsed time, rotating tips and cancel. Estimates
never claim server completion. AI feedback shows the real IELTS score out of 9
and criterion cards; writing still requires the existing 150-word minimum.

Membership uses real plan prices, primary selection, an orange recommendation badge,
current membership, voucher controls and PayOS checkout. QR supports both Lưu mã QR
về máy and a long press. QrGallery creates a 1024px PNG with a white quiet zone,
requests gallery access using gal, and reports Đã lưu mã QR only after saving.
Android legacy WRITE_EXTERNAL_STORAGE is restricted to API ≤29; modern Android
uses MediaStore. The existing polling/status and external payment link remain.
Hủy đơn dismisses the local QR view; the repository has no server cancel endpoint.

## Verification

Run flutter analyze and flutter test; integration tests require a separate request.
Tests cover real provider/repository contracts, button press/release/cancel/disabled
states, semantic contrast, course search/navigation, five-tab state retention,
QR PNG export/permission refusal and both save gestures. Responsive tests render
at 360dp in light/dark mode and include the shell, new course list and AI states.

Optional previews (local bundled fonts loaded by the test):

    flutter test test/widget/design/responsive_screens_test.dart --dart-define=UPDATE_DESIGN_PREVIEWS=true

Review images are written to build/design-review and remain outside source assets.
