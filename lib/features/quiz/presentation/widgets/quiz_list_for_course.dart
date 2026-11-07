import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/quiz_repository.dart';
import '../providers/quiz_provider.dart';
import 'quiz_catalog.dart';

/// Embeddable course quizzes; it owns state so it cannot replace system quizzes.
/// Place inside the course's scroll view; no fixed height is required.
class QuizListForCourse extends StatelessWidget {
  const QuizListForCourse({super.key, required this.courseId});
  final int courseId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    key: ValueKey(courseId),
    create: (context) => QuizProvider(context.read<QuizRepository>())
      ..load(courseId: courseId)
      ..loadHistory(),
    child: Builder(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Refresh quizzes',
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<QuizProvider>().load(courseId: courseId),
            ),
          ),
          QuizCatalog(courseId: courseId, embedded: true),
        ],
      ),
    ),
  );
}
