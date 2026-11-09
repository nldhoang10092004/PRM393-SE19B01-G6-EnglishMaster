import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../flashcard/presentation/screens/flashcard_sets_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../quiz/presentation/screens/quiz_list_screen.dart';
import 'home_screen.dart';
import '../../../course/presentation/screens/course_list_screen.dart';
import '../../../../core/theme/app_palette.dart';

/// Main scaffold after login: bottom navigation between the five tabs.
/// [IndexedStack] keeps each tab's state (scroll position, loaded data)
/// when switching tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _showCourses() => setState(() => _index = 1);
  late final _tabs = <Widget>[
    HomeScreen(onViewCourses: _showCourses),
    const CourseListScreen(),
    const FlashcardSetsScreen(),
    const QuizListScreen(),
    const ProfileScreen(),
  ];

  static const _destinations = [
    (Icons.home_outlined, Icons.home, AppStrings.home),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, AppStrings.course),
    (Icons.style_outlined, Icons.style, AppStrings.flashcards),
    (Icons.quiz_outlined, Icons.quiz, AppStrings.quiz),
    (Icons.person_outline, Icons.person, AppStrings.profile),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final outline = BorderSide(color: AppPalette.of(context).outline, width: 2);
    final body = IndexedStack(index: _index, children: _tabs);
    // Unfolded foldables and tablets: a side rail instead of the bottom bar.
    if (Breakpoints.isWide(context)) {
      final extended =
          MediaQuery.sizeOf(context).width >= Breakpoints.expanded + 200;
      return Scaffold(
        body: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(border: Border(right: outline)),
              child: SafeArea(
                right: false,
                child: NavigationRail(
                  groupAlignment: 0.0,
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  extended: extended,
                  labelType: extended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: [
                    for (final (icon, selected, label) in _destinations)
                      NavigationRailDestination(
                        icon: Icon(icon),
                        selectedIcon: Icon(selected),
                        label: Text(label),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: outline)),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            for (final (icon, selected, label) in _destinations)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selected),
                label: label,
              ),
          ],
        ),
      ),
    );
  }
}
