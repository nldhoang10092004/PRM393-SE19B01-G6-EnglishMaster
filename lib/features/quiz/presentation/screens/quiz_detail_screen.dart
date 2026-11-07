import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../data/quiz_repository.dart';
import '../providers/quiz_provider.dart';
import 'quiz_taking_screen.dart';

/// Quiz overview with an explicit start action and a route-scoped attempt.
class QuizDetailScreen extends StatelessWidget {
  const QuizDetailScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        QuizTakingProvider(context.read<QuizRepository>())..load(quizId),
    child: Consumer<QuizTakingProvider>(
      builder: (context, state, _) => Scaffold(
        appBar: AppBar(title: Text(state.quiz?.title ?? 'Quiz detail')),
        body: AsyncView(
          status: state.status,
          error: state.error,
          onRetry: () => state.load(quizId),
          builder: (_) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                state.quiz!.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(state.quiz!.description),
              const SizedBox(height: 16),
              Text('${state.questions.length} questions'),
              const SizedBox(height: 8),
              const Text('You can review earlier answers before submitting.'),
              if (state.questions.isEmpty)
                const MessageView(
                  icon: Icons.quiz_outlined,
                  message: 'This quiz has no questions yet.',
                ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.busy || state.questions.isEmpty
                    ? null
                    : () async {
                        if (!await state.start() || !context.mounted) return;
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: state,
                              child: const QuizTakingScreen(),
                            ),
                          ),
                        );
                        if (context.mounted && state.result != null) {
                          Navigator.of(context).pop();
                        }
                      },
                child: Text(
                  state.busy
                      ? 'Starting…'
                      : state.attemptId == null
                      ? 'Start quiz'
                      : 'Resume quiz',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
