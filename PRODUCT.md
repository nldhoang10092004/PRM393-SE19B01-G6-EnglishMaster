# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Vietnamese learners (students and self-learners) studying communicative English and practicing four IELTS-graded skills (Speaking, Listening, Reading, Writing) on Android phones, foldables, and tablets.

## Product Purpose

EnglishMaster helps learners build daily English proficiency through structured video and quiz courses, spaced flashcard study and personal saved vocabulary, course quizzes, and AI-generated & AI-graded practice across Speaking, Listening, Reading, and Writing, reinforced by daily streak tracking and study reminders.

## Positioning

Combines structured teacher-led Vietnamese-annotated English courses and flashcard vocabulary with on-demand AI-generated practice prompts and instant criterion-by-criterion IELTS band scoring (0–9 across Grammar, Fluency/Coherence, Lexical Resource) in a single responsive mobile/tablet study workspace.

## Operating Context

- Used daily in short to medium study sessions (10–45 minutes), primarily in light mode for long reading/writing/flashcard sessions, with full dark-mode parity (≥ 4.5:1 contrast).
- Five primary destinations in a state-preserving shell (`IndexedStack`): `Trang chủ` (Home), `Khóa học` (Courses), `Thẻ ghi nhớ` (Flashcards), `Bài kiểm tra` (Quizzes), and `Hồ sơ` (Profile), adapting from a bottom `NavigationBar` on compact screens (< 600dp) to a side `NavigationRail` on foldables and tablets (≥ 600dp).
- Real-time audio recording for AI Speaking, pinned audio playback for Listening (AI & Quiz), 150-word minimum composition for AI Writing, flip/swipe cards for Flashcard study, and PayOS QR checkout (`#FFFFFF` paper / `#171923` ink) with gallery export for Membership.

## Capabilities and Constraints

- Connects to live backend API (`https://em-api.ondevora.shop`).
- No fabricated metrics: course summaries do not expose progress percentages; quizzes do not expose server countdowns or elapsed result durations; streak cards use only the real server `currentStreak`.
- All UI copy is Vietnamese-first and centralized in `AppStrings` and `AiExamStrings`.
- Bundled local `Be Vietnam Pro` font family (weights 400, 500, 600, 700, 800) with no runtime font fetching.
- Must preserve all existing routes, providers, repositories, widget keys, tactile `ChunkyButton` / `ChunkyOutlinedButton` 4dp press physics, and pass all 279 unit and widget tests across 344dp, 360dp (light & dark), 673dp, 800dp, and 1280dp viewports.

## Brand Commitments

- Product name: `EnglishMaster`
- Mascot: `MascotMimi` (custom-painted speech-bubble mascot used on Login and AI generation states)
- Tactile, flat, zero-gradient, zero-blur surface language with semantic skill coding for Speaking, Listening, Writing, and Reading.

## Evidence on Hand

- Existing Flutter application under `lib/` with 10 feature modules (`auth`, `home`, `course`, `flashcard`, `quiz`, `ai_exam`, `membership`, `profile`, `notifications`, `streak`, `vocabulary`, `video`).
- Automated responsive preview & verification suite in `test/widget/design/responsive_screens_test.dart` and `test/widget/design/chunky_button_test.dart`.

## Product Principles

1. **Honest Learning Data:** Show only real server scores, real streak counts, real mastery ratios, and real course metadata—never invent progress bars, timers, or vanity numbers.
2. **Task-First Study Clarity:** Reading passages, audio players, flashcards, and quiz options must lead every screen with distraction-free legibility and clear state feedback.
3. **Tactile & Responsive Consistency:** Every interactive control gives crisp physical feedback (`4dp` press travel, `48×48dp` minimum touch targets) and adapts seamlessly from 344dp foldable covers to 1280dp tablets.

## Accessibility & Inclusion

- All semantic text/background pairs in both Light and Dark themes must maintain at least `4.5:1` WCAG AA contrast (enforced by automated test).
- Supports text scaling and responsive reflow without clipping or overflow across all 6 tested viewport classes.

