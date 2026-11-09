---
name: EnglishMaster
description: Tactile botanical study ledger and IELTS AI practice companion for Vietnamese learners
colors:
  primary: "#1B6E66"
  primary-edge: "#104943"
  primary-soft: "#D8F0EC"
  on-primary: "#FFFFFF"
  on-primary-soft: "#0C3B36"
  reward: "#F2911B"
  on-reward: "#3B1C00"
  page: "#F6F7F4"
  surface: "#FFFFFF"
  muted: "#EAF0EC"
  outline: "#D2DDD6"
  ink: "#15201C"
  ink-muted: "#475750"
  speaking-bg: "#FCE4D2"
  speaking-ink: "#5C2D12"
  speaking-edge: "#E6B99C"
  listening-bg: "#D4F0E2"
  listening-ink: "#0F5238"
  listening-edge: "#94CFB2"
  writing-bg: "#E6E0FA"
  writing-ink: "#3D2C7A"
  writing-edge: "#BEB2ED"
  reading-bg: "#DAE9FA"
  reading-ink: "#17427A"
  reading-edge: "#9BC0EE"
  error: "#B42318"
typography:
  display:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "28px"
    fontWeight: 800
    lineHeight: 1.15
    letterSpacing: "-0.6px"
    fontFeature: "'tnum' 1"
  headline:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "26px"
    fontWeight: 800
    lineHeight: 1.18
    letterSpacing: "-0.5px"
    fontFeature: "'tnum' 1"
  title:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "21px"
    fontWeight: 800
    lineHeight: 1.24
    letterSpacing: "-0.3px"
    fontFeature: "'tnum' 1"
  body:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "16px"
    fontWeight: 800
    lineHeight: 1.2
    fontFeature: "'tnum' 1"
rounded:
  icon: "14px"
  control: "16px"
  card: "24px"
  hero: "28px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  gutter: "20px"
  auth-gutter: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "14px 24px"
    height: "56px"
  button-outlined:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    padding: "14px 20px"
    height: "56px"
  card-skill-specimen:
    backgroundColor: "{colors.speaking-bg}"
    textColor: "{colors.speaking-ink}"
    rounded: "{rounded.card}"
    padding: "14px"
    height: "116px"
  card-outlined:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.card}"
    padding: "16px"
  chip-pill:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.on-primary-soft}"
    rounded: "{rounded.pill}"
    padding: "8px 14px"
  input-field:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    padding: "16px 18px"
---

# Design System: EnglishMaster

## Overview

**Creative North Star: "The Botanical Study Ledger"**

EnglishMaster is crafted as a tactile botanical study ledger and modern language press (`seed:01227d6839ee6b47` × `editorial-greeting` `seed:2143727940`). Rather than noisy neon gamification or sterile corporate SaaS gray, the app rests on warm herbarium vellum paper (`#F6F7F4`) paired with deep pine-charcoal ink (`#15201C`), anchored by Botanical Emerald (`#1B6E66`) for primary study actions and Warm Amber Seal (`#F2911B`) for streaks and rewards.

Every screen honors the discipline of a physical specimen notebook: each of the four English skills owns a dedicated natural pigment family (Terracotta Clay for Speaking, Eucalyptus Mint for Listening, Iris Vellum for Writing, and Mineral Cobalt for Reading), framed by `2dp` pigment borders and `3–4dp` mechanical bottom edges. There are no linear gradients, no glassmorphic blurs, and no diffused drop shadows anywhere in the interface.

**Key Characteristics:**
- Warm herbarium vellum ground (`#F6F7F4` light / `#0E1412` dark) with ≥ 4.5:1 WCAG AA contrast across all 12 semantic text-on-surface pairs.
- Strict four-skill natural pigment color-coding (`SkillColors`) with matching `2dp` borders and `4dp` bottom edges.
- Mechanical tactile depth (`ChunkyButton`, `ChunkyOutlinedButton`, `OutlinedCard`, `SkillTile`, `FlatHeroCard`) with zero blurred shadows or gradients.
- Locally bundled `Be Vietnam Pro` typography (weights 400–800) with tabular figures (`tnum`) enabled on all scores, counters, timers, and VND prices.

## Colors

`AppTheme` maps Material 3 roles and registers `AppPalette`, a `ThemeExtension` carrying semantic surface, primary, reward, and `SkillColors` tokens so screens never contain literal hex colors.

### Primary
- **Botanical Emerald** (`#1B6E66` light / `#5DCAC0` dark): Primary action face, active selection indicator, section-header ledger bar, and navigation focus. Paired with **Deep Forest Edge** (`#104943` light / `#2B8F85` dark) for the `4dp` mechanical button edge and **Celadon Wash** (`#D8F0EC` light / `#133834` dark) with **Deep Pine Ink** (`#0C3B36` light / `#D8F5F1` dark) for soft selected pills and navigation indicators.

### Secondary
- **Warm Amber Seal** (`#F2911B` light / `#FFB03A` dark) with **Espresso Seal Ink** (`#3B1C00` light / `#261200` dark): Reserved exclusively for daily study streaks, reward stat tiles, and the recommended membership badge.

### Tertiary
- **Terracotta Clay — Speaking** (`#FCE4D2` bg / `#5C2D12` ink / `#E6B99C` edge in light; `#311B0F` / `#FFDCC4` / `#5C341E` in dark): Identifies Speaking practice, course hero headers, and speaking benefit chips.
- **Eucalyptus Mint — Listening** (`#D4F0E2` bg / `#0F5238` ink / `#94CFB2` edge in light; `#132E22` / `#C4F5DD` / `#255942` in dark): Identifies Listening practice, vocabulary settings, and audio exercises.
- **Iris Vellum — Writing** (`#E6E0FA` bg / `#3D2C7A` ink / `#BEB2ED` edge in light; `#241C38` / `#E2D9FF` / `#473870` in dark): Identifies Writing practice, AI grading criteria, and writing prompts.
- **Mineral Cobalt — Reading** (`#DAE9FA` bg / `#17427A` ink / `#9BC0EE` edge in light; `#14273D` / `#D4E6FF` / `#294E78` in dark): Identifies Reading quizzes, full-test simulation cards, and comprehension blocks.

### Neutral
- **Herbarium Vellum** (`#F6F7F4` light / `#0E1412` dark): Primary scaffold and page background.
- **Pure Study Sheet** (`#FFFFFF` light / `#161F1C` dark): Card, input, and bottom-bar surface.
- **Sage Wash** (`#EAF0EC` light / `#202B27` dark): Muted container fill for unselected chips and progress tracks.
- **Pressed Rule** (`#D2DDD6` light / `#2E3D37` dark): `2dp` structural border and `3dp` card bottom edge.
- **Pine Charcoal Ink** (`#15201C` light / `#ECF3EF` dark) & **Lichen Muted Ink** (`#475750` light / `#9FB0A8` dark): Primary and secondary typography.
- **Crimson Stamp** (`#B42318` light / `#FFB4AB` dark): Validation errors and destructive actions.
- **QR Scanner Paper & Ink** (`#FFFFFF` / `#171923`): Invariant across both Light and Dark themes so PayOS QR codes scan reliably.

### Named Rules
**The Four-Pigment Canon Rule.** Speaking is always Terracotta Clay, Listening is always Eucalyptus Mint, Writing is always Iris Vellum, and Reading is always Mineral Cobalt. Never mix skill pigments or embed literal color values in feature widgets.

## Typography

**Display Font:** Be Vietnam Pro (bundled locally, weights 700–800)
**Body Font:** Be Vietnam Pro (bundled locally, weights 400–600)
**Label/Mono Font:** Be Vietnam Pro with `FontFeature.tabularFigures()` (`tnum`)

**Character:** Engineered for Vietnamese diacritics with generous x-height, crisp geometric terminals, and authoritative ExtraBold (`w800`) ledger headings that contrast cleanly against regular (`w400`, line-height `1.5`) study prose.

### Hierarchy
- **Display** (`w800`, `28px`, line-height `1.15`, letter-spacing `-0.6px`, `tnum`): Hero score numerals and primary dashboard banners.
- **Headline** (`w800`, `26px`, line-height `1.18`, letter-spacing `-0.5px`, `tnum`): Top-level screen headers (`Khóa học`, `Thẻ ghi nhớ`, `Hồ sơ`, `Luyện thi AI`).
- **Title** (`w800`–`w700`, `16px`–`21px`, line-height `1.24`–`1.3`, `tnum`): Section headers, course cards, and skill specimen tiles.
- **Body** (`w400`–`w500`, `15px`–`16px`, line-height `1.5`): Lesson descriptions, reading passages, quiz stems, and AI feedback.
- **Label** (`w600`–`w800`, `12px`–`16px`, `tnum`): ChunkyButton labels, PillChip badges, streak counters, and navigation labels.

### Named Rules
**The Tabular Ledger Rule.** Every numeric score, IELTS band, countdown timer, streak day counter, flashcard mastery ratio, and VND price uses `FontFeature.tabularFigures()` so digits align vertically and never jitter during state updates.

## Layout

Material 3 window size classes in `lib/core/layout/responsive.dart` govern spatial adaptation:
- **Compact (`< 600dp` — phones and folded 344dp cover screens):** Bottom `NavigationBar` with 5 state-preserving `IndexedStack` tabs (`Trang chủ`, `Khóa học`, `Thẻ ghi nhớ`, `Bài kiểm tra`, `Hồ sơ`), `20dp` screen gutters (`24dp` on auth), and single-column lists.
- **Medium / Expanded (`>= 600dp` — unfolded foldables ~673dp, tablets 800dp–1280dp):** Left `NavigationRail` (labels under icons; extended rail from `1040dp`) separated by a `2dp` vertical rule, multi-column course and flashcard grids, and 3–5 column AI exam hub cards.
- **Readable Width & Frame:** `ResponsiveFrame` (`MaterialApp.builder`) caps the application at `1100dp` and centers it; `readablePadding` and `ReadableWidth` keep forms, quizzes, AI exercises, profile, and checkout between `480dp` and `720dp`.
- `test/widget/design/responsive_screens_test.dart` renders every screen at `360dp` (light/dark), `344dp`, `673dp`, `800dp`, and `1280dp` and fails on any layout overflow.

## Elevation & Depth

Surfaces are strictly flat: no linear/radial gradients and no blurred drop shadows. Depth is mechanical and structural, conveyed through `2dp` borders (`#D2DDD6` or `colors.edge`) paired with crisp, unblurred `3dp`–`4dp` bottom edges.

### Shadow Vocabulary
- **Tactile Button Edge** (`BoxShadow(color: primaryEdge, offset: Offset(0, 4), blurRadius: 0)`): Rest state of `ChunkyButton`; collapses to `Offset.zero` while the button face translates `4dp` downward on press.
- **Tactile Outlined Edge** (`BoxShadow(color: outline, offset: Offset(0, 4), blurRadius: 0)`): Rest state of `ChunkyOutlinedButton`.
- **Specimen Card Edge** (`BoxShadow(color: colors.edge, offset: Offset(0, 4), blurRadius: 0)`): Used on `SkillTile`, `FlatHeroCard`, `AiPromptCard`, `AiScoreCard`, and `AiExamHubScreen` cards.
- **Ledger Card Edge** (`BoxShadow(color: outline, offset: Offset(0, 3), blurRadius: 0)`): Used on `OutlinedCard` (`StreakCard`, `CourseCard`, daily review card) and `StatTile`.

### Named Rules
**The Mechanical Edge Rule.** Surfaces never cast blurred drop shadows or gradients. Every elevated control or specimen card pairs a `2dp` structural border with a `3–4dp` zero-blur bottom edge.

## Shapes

- **Hero Blocks & Course Headers:** `28dp`–`32dp` radius with `2dp`–`3dp` pigment borders.
- **Study Cards & Specimen Tiles:** `24dp` radius with `2dp` border and `3–4dp` solid bottom edge.
- **Buttons & Input Fields:** `16dp` radius with `2dp` outline (`primary` on focus).
- **Icon Square Controls & Framed Specimen Icons:** `12dp`–`14dp` radius with `1.5dp`–`2dp` border.
- **Pill Chips & Navigation Indicators:** `999dp` stadium radius with `1.5dp` structural border.
- **Section Headers:** Anchored by a `4×20dp` rounded vertical `primary` ledger bar to the left of the section title.

## Components

### Buttons
- **Shape:** Rounded rectangle (`16dp` radius), minimum `56dp` height (`52dp` face + `4dp` bottom edge).
- **Primary (`ChunkyButton`):** `primary` (`#1B6E66`) face, `onPrimary` (`#FFFFFF`) ExtraBold label, `4dp` `primaryEdge` (`#104943`) bottom edge. Pressing translates the face down `4dp` over `90ms` and collapses the edge while retaining Material keyboard, focus, disabled, and semantics behavior.
- **Secondary (`ChunkyOutlinedButton`):** `surface` (`#FFFFFF`) face, `2dp` `outline` (`#D2DDD6`) border and `4dp` bottom edge, `ink` (`#15201C`) label, identical `4dp` press physics.

### Chips
- **Style (`PillChip`):** Stadium (`999dp`) pill with `1.5dp` border (`primaryEdge` when selected, `outline` when unselected).
- **State:** Unselected uses `muted` fill and `ink` text; selected uses `primary` fill and `onPrimary` text; semantic badges pass explicit `color` and `foreground`.

### Cards / Containers
- **Corner Style:** `24dp` radius (`28dp` on `FlatHeroCard`).
- **Background:** `surface` (`#FFFFFF`) for `OutlinedCard` and `StatTile`; `SkillColors.background` for `SkillTile`, `FlatHeroCard`, `FlashcardSetTile`, `AiPromptCard`, and `AiScoreCard`.
- **Shadow Strategy:** `3dp`–`4dp` zero-blur solid bottom edge (`edgeColor`).
- **Border:** `2dp` solid `outline` or `SkillColors.edge`.
- **Internal Padding:** `14dp`–`20dp`.

### Inputs / Fields
- **Style:** Filled `surface` background, `16dp` radius, `2dp` `outline` border, `18×16dp` internal padding.
- **Focus:** `2dp` `primary` (`#1B6E66`) border.
- **Error / Disabled:** `2dp` `error` (`#B42318`) border with error caption.

### Navigation
- **Compact (`NavigationBar`):** `72dp` height, `surface` background with top `2dp` `outline` border, `primarySoft` stadium indicator, `primary` selected label (`w700`), `inkMuted` unselected label (`w600`).
- **Medium/Expanded (`NavigationRail`):** Left rail on `surface` with `primarySoft` indicator and `2dp` vertical `Divider`.

### Skill Specimen Tile & Score Ring
- **`SkillTile`:** `116dp` specimen block with `2dp` `colors.edge` border, `4dp` bottom edge, framed `40×40dp` icon badge (`surface` at 65% alpha with `1.5dp` `colors.edge` border), top-right `Icons.north_east_rounded` cue, and `colors.ink` title.
- **`ScoreRing`:** Custom circular arc painted in `primary` over `muted` track with scalable tabular numerals; used for overall scores and compact flashcard mastery counts.

## Do's and Don'ts

### Do:
- **Do** read every color from `AppPalette.of(context)` and every string from `AppStrings` / feature `*Strings`.
- **Do** frame skill cards (`SkillTile`, `FlatHeroCard`, `FlashcardSetTile`, AI prompt/score cards) with their `2dp` `colors.edge` border and `4dp` bottom edge.
- **Do** keep `qrPaper` (`#FFFFFF`) and `qrInk` (`#171923`) invariant across themes for PayOS QR scanning and `QrGallery` 1024px PNG export.
- **Do** verify changes with `flutter analyze` and `flutter test` (including `chunky_button_test.dart` 4.5:1 contrast gates and `responsive_screens_test.dart` across all 6 viewports).

### Don't:
- **Don't** use linear/radial gradients, glassmorphic blurs, or blurred drop shadows anywhere in the app.
- **Don't** invent progress percentages, countdown timers, elapsed durations, or synthetic activity totals not provided by the API.
- **Don't** hardcode hex colors in screen or widget files or break the 5-tab state-preserving `IndexedStack` shell.
