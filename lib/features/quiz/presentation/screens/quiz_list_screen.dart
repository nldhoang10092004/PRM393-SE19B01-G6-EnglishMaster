import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_catalog.dart';
import '../widgets/quiz_history_list.dart';

/// System quizzes and attempt history, with independent loading states.
class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});
  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final state = context.read<QuizProvider>();
        state.load();
        state.loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppTopBar(
          large: true,
          title: Text(AppStrings.quizzes),
          bottom: TabBar(
            tabs: [
              Tab(text: AppStrings.systemQuizzes),
              Tab(text: AppStrings.attemptHistory),
            ],
          ),
        ),
        body: TabBarView(children: [QuizCatalog(), QuizHistoryList()]),
      ),
    );
  }
}
