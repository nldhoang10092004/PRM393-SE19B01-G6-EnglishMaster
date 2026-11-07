import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../flashcard/presentation/screens/flashcard_sets_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../quiz/presentation/screens/quiz_list_screen.dart';
import 'home_screen.dart';

/// Main scaffold after login: bottom navigation between the four tabs.
/// [IndexedStack] keeps each tab's state (scroll position, loaded data)
/// when switching tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    FlashcardSetsScreen(),
    QuizListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.home,
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
    );
  }
}
