# EnglishMaster — UI design guide

## Brand and accessibility

EnglishMaster uses its own learning-app identity: indigo `#3D5AFE` for learning and
navigation, with a warm orange/amber seed `#FF9B26` for streaks, rewards and plans.
All colors are defined in `AppTheme`. Screens consume Material `colorScheme`
roles, including their matching `on*` foregrounds. Never add literal colors to
feature widgets. The QR paper/ink pair is also centralized in the theme and stays
scan-friendly in dark mode.

Both light and dark themes use tonal surface layers: `surface` for the page,
`surfaceContainerLow` for cards, and container colors for highlighted learning
content. Borders are subtle; only the study flashcard uses a soft shadow.
Indigo hero gradients keep a dominant primary color for reliable foreground
contrast. Warm hero gradients use `secondaryContainer`/`onSecondaryContainer`.

## Typography and spacing

- Be Vietnam Pro is used for headings and body via `google_fonts`. Regular,
  Medium, SemiBold and Bold files and the OFL license are bundled in
  `assets/fonts/`; font loading does not require a network connection.
- Headings use weight 700, card titles 600; body copy uses a relaxed 1.5 line
  height. `headlineSmall` introduces a page, `titleLarge` a section,
  `titleMedium` a card, and `labelMedium` a compact statistic.
- Spacing scale: 4 / 8 / 12 / 16 / 24 / 32 dp. Standard screen gutters are 16 dp;
  authentication forms use 24 dp and a maximum width of 420 dp.
- Card radius is 20 dp; buttons, inputs and option tiles use 14 dp. Chips and
  navigation indicators use pill shapes. Bottom sheets have a 28 dp top radius.
- Buttons have a 50 dp minimum height. Use Expanded/Flexible and wrapping for
  variable-length Vietnamese text. Catalog titles may use a two-line ellipsis;
  learning content remains scrollable and readable. Avoid fixed-width text.
- Every interface string lives in `AppStrings` or the feature's `*Strings`.
  Server-provided learning content keeps its source language.

## Shared components

- `SectionHeader`: section title and optional “Xem tất cả” action.
- `StatTile`: a value with an optional icon and a wrapping label.
- `GradientHeroCard`: tonal gradient, icon illustration, title and supporting copy.
- `UserAvatar`: cached image with safe URL resolution and a name-initial fallback;
  the profile and home greeting share this renderer and `ProfileProvider` state.
- `ScoreRing`: a large circular result visualization with a scalable score label.
- `AsyncView`: consistent loading/error/empty/content handling. Loading uses
  `SkeletonLoading`, a simple animated-opacity placeholder. Empty/error states
  use `MessageView`, with an icon inside a tinted circle and an optional retry.
- NavigationBar uses a tonal selected indicator; AppBars have clear left-aligned
  titles and no abrupt scroll elevation. Inputs and paired buttons share shapes.

## Screen patterns

- **Authentication:** icon hero and short introduction above the existing forms.
  Forms scroll when the keyboard opens; field validation and OTP flow are retained.
- **Home:** avatar greeting, warm streak hero, AI practice shortcut, horizontal
  “Tiếp tục học” course discovery carousel and full course catalog. Carousel
  entries open the existing course-detail route; no invented progress or ratings.
  Course list covers rotate among theme container colors.
- **Course detail:** pinned, collapsing gradient SliverAppBar with name, teacher
  and real rating; numbered expandable chapter cards, quizzes and reviews.
- **Video:** inset rounded 16:9 player, clear lesson heading, preview/completion
  chips and the existing completion action. Playback and progress remain intact.
- **Flashcards:** colored set grid with mastery rings and explicit loading/error
  labels. Study uses a shadowed tonal flip face, bounded progress dots, readable
  front/back content and the existing navigation, save and mastery controls.
- **Quiz:** icon-led catalog cards with best-score chips beneath descriptions;
  detail hero, tonal question card, outlined selectable answers and progress.
  Result uses a large warm score ring, correct/wrong/pending statistics and the
  expandable submitted-answer review.
- **AI:** two-column hub for speaking, listening, writing and saved history
  (the existing four destinations). Tonal prompt cards distinguish source content;
  feedback cards show the overall score, score progress and criterion chips.
  Generation and grading retain `AiGeneratingView` and existing audio controls.
- **Membership:** reward hero, current membership, recommended plan badge, selected
  plan border and clearly separated price. QR payment uses a rounded paper frame,
  amount, countdown and the existing payment/check-status actions.
- **Profile:** identity card with tappable camera-badged avatar, upload progress
  ring and three statistics; membership and grouped account settings follow.
  Picking requests `maxWidth: 512`, `imageQuality: 85`; upload uses PUT multipart
  field `File`. Cancel leaves the current avatar unchanged. Errors use friendly
  Vietnamese copy. Android lost-picker data is recovered when profile loads.
- **Vocabulary:** search field and icon-led word cards; swipe removal and undo
  are unchanged. **Reminders:** warm introduction and grouped enable/time controls.

## Motion and verification

Animations are restrained: the existing 280 ms perspective flashcard flip,
250 ms section scrolling and 120 ms cached-image fade. Skeleton opacity uses a
900 ms ease-in/out cycle and stops when the platform requests reduced motion.
Lazy list/grid builders and const children keep repeated content inexpensive.

Widget tests exercise these layouts at 360 dp in light and dark themes, including
long Vietnamese names, course titles, prices and scrollable content. Optional
review PNGs can be generated with:

    flutter test test/widget/design/responsive_screens_test.dart --dart-define=UPDATE_DESIGN_PREVIEWS=true

Previews are written under `build/design-review/` and are not source assets.
Run `flutter analyze` and `flutter test` after changes. Integration tests are a
separate, explicitly requested step.
