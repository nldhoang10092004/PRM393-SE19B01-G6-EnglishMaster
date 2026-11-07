import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ai_exam_strings.dart';
import '../../data/ai_exam_repository.dart';
import '../providers/ai_exam_provider.dart';
import '../widgets/ai_exam_body.dart';
import '../widgets/ai_prompt_card.dart';
import '../widgets/ai_score_card.dart';
import '../widgets/ai_teacher_switch.dart';

/// A fresh writing session per route, with a retained draft during submission.
class AiWritingScreen extends StatelessWidget {
  const AiWritingScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        AiWritingProvider(context.read<AiExamRepository>())..generate(),
    child: Consumer<AiWritingProvider>(
      builder: (context, state, _) => Scaffold(
        appBar: AppBar(title: const Text(AiExamStrings.writing)),
        body: AiExamBody(
          status: state.status,
          error: state.error,
          hasPrompt: state.prompt != null,
          busy: state.busy,
          canGenerate: state.canGenerate,
          onGenerate: state.generate,
          submitting: state.answer.isNotEmpty,
          children: [
            if (state.prompt case final prompt?) ...[
              AiPromptCard(title: prompt.title, content: prompt.content),
              const SizedBox(height: 16),
              TextFormField(
                key: ObjectKey(prompt),
                initialValue: state.answer,
                minLines: 8,
                maxLines: 16,
                readOnly: state.busy || state.result != null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: AiExamStrings.answer,
                  hintText: AiExamStrings.writingHint,
                  alignLabelWithHint: true,
                ),
                onChanged: state.setAnswer,
              ),
              const SizedBox(height: 8),
              Text(
                AiExamStrings.wordCount(state.wordCount),
                key: const ValueKey('ai-writing-word-count'),
              ),
              const Text(AiExamStrings.minimumWords),
              const SizedBox(height: 16),
              if (state.result == null) ...[
                AiTeacherSwitch(
                  value: state.sendToTeacher,
                  onChanged: state.busy ? null : state.setSendToTeacher,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: state.canSubmit ? state.submit : null,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text(AiExamStrings.submit),
                ),
              ],
              if (state.result case final result?) ...[
                const SizedBox(height: 16),
                AiScoreCard(score: result),
              ],
            ],
          ],
        ),
      ),
    ),
  );
}
