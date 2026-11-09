import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../data/quiz_repository.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_history_list.dart';

/// Standalone history route opened from the profile.
class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        QuizProvider(context.read<QuizRepository>())..loadHistory(),
    child: const Scaffold(
      appBar: AppTopBar(title: Text(AppStrings.quizHistory)),
      body: QuizHistoryList(),
    ),
  );
}
