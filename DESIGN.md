# EnglishMaster – UI design guide

Own design, using patterns common to language-learning app UI kits (dashboard with streak,
learning path, flip flashcards, quiz with progress). No third-party template code or assets.

## Visual language
* Material 3, seed color indigo `#3D5AFE` (`AppTheme`). Accent colors from `colorScheme`
  (`primary`, `tertiary`, `secondaryContainer`); success = `Colors.green`, error = `colorScheme.error`.
* Rounded corners: cards 16, buttons/inputs 12, chips full pill.
* Spacing scale 4 / 8 / 12 / 16 / 24; screen padding 16 horizontally.
* Typography: `headlineSmall` for screen hero, `titleMedium` for card titles, `bodyMedium` text.
* Icons: Material rounded/outlined. Empty and error states use `MessageView`.
* Support light and dark mode (never hard-code white/black backgrounds).

## Screen patterns
* **Home (dashboard):** greeting header with avatar initial; gradient "streak card"
  (fire icon, current streak days, `NeedsActivityToday` hint); horizontal "Continue learning" row;
  vertical "All courses" list of course cards (colored leading block with course initials,
  name, teacher, rating stars).
* **Course detail:** `SliverAppBar` hero header with course name, teacher, rating; tabs or
  sections for Chapters (expandable list of videos with completed check), Quizzes, Flashcards,
  Reviews.
* **Video lesson:** player on top (16:9), title, progress saved automatically, "Mark as completed".
* **Flashcard sets:** grid of set cards (2 columns, count of items, progress bar).
* **Flashcard study:** large card with 3D flip animation (front term / back meaning + example),
  "Again / Got it" buttons, progress `LinearProgressIndicator` at top, bookmark icon to save to
  vocabulary, summary screen at the end.
* **Quiz list:** cards with quiz title, number of questions, time, best score chip.
* **Quiz taking:** top progress bar + "Question 3/10", question text card, option tiles
  (outlined, selected = primaryContainer), bottom "Next / Submit"; confirm dialog before submit.
* **Quiz result:** big circular score, correct/total, "Review answers", "Back to quizzes".
* **Vocabulary:** searchable list, swipe-to-delete with undo SnackBar.
* **Profile:** header with avatar circle + name + email, stats row (streak, attempts, words),
  list tiles: Edit profile, Change password, Saved vocabulary, Study reminder (switch + time),
  Quiz history, Log out.

## Motion
* `AnimatedSwitcher` for state changes, `Hero` for course card -> detail header,
  flip animation for flashcards, implicit animations (≤ 300 ms). Keep it smooth on release mode.
