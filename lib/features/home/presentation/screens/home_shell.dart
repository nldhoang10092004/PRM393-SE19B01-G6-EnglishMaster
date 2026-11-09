import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppPalette.of(context).outline, width: 2),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: AppStrings.home,
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: AppStrings.course,
            ),
            NavigationDestination(
              icon: Icon(Icons.style_outlined),
              selectedIcon: Icon(Icons.style),
              label: AppStrings.flashcards,
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined),
              selectedIcon: Icon(Icons.quiz),
              label: AppStrings.quiz,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
