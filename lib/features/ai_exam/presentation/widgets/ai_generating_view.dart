import 'dart:async';

import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';
import '../../../../core/widgets/mascot_mimi.dart';
import '../../../../core/widgets/outlined_card.dart';
import '../../../../core/theme/app_palette.dart';

/// Which slow AI operation is running; selects the title and estimated steps.
enum AiGeneratingKind { speaking, listening, writing, grading }

/// Progress view for slow AI calls: pulse animation, estimated steps, elapsed
/// time, rotating tips and a cancel button. It owns no request, so a rebuild
/// can never restart generation.
class AiGeneratingView extends StatefulWidget {
  const AiGeneratingView({
    super.key,
    required this.kind,
    this.onCancel,
    this.stepSeconds = 6,
    this.tipSeconds = 5,
  });
  final AiGeneratingKind kind;

  /// Defaults to popping the current route.
  final VoidCallback? onCancel;
  final int stepSeconds, tipSeconds;

  @override
  State<AiGeneratingView> createState() => _AiGeneratingViewState();
}

class _AiGeneratingViewState extends State<AiGeneratingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  String get _title => switch (widget.kind) {
    AiGeneratingKind.speaking => AiExamStrings.generatingSpeaking,
    AiGeneratingKind.listening => AiExamStrings.generatingListening,
    AiGeneratingKind.writing => AiExamStrings.generatingWriting,
    AiGeneratingKind.grading => AiExamStrings.grading,
  };

  List<String> get _steps => switch (widget.kind) {
    AiGeneratingKind.speaking => AiExamStrings.stepSpeaking,
    AiGeneratingKind.listening => AiExamStrings.stepListening,
    AiGeneratingKind.writing => AiExamStrings.stepWriting,
    AiGeneratingKind.grading => AiExamStrings.stepGrading,
  };

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    // Estimate only: the last step stays pending until the response arrives.
    final active = (_elapsed ~/ widget.stepSeconds).clamp(0, steps.length - 2);
    final tip = AiExamStrings
        .tips[(_elapsed ~/ widget.tipSeconds) % AiExamStrings.tips.length];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => Transform.translate(
                key: const ValueKey('ai-generating-pulse'),
                offset: Offset(
                  0,
                  MediaQuery.disableAnimationsOf(context)
                      ? 0
                      : -3 * _pulse.value,
                ),
                child: const MascotMimi(thinking: true, width: 180),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${AiExamStrings.elapsedSeconds(_elapsed)} · ${AiExamStrings.estimateNote}',
              key: const ValueKey('ai-generating-elapsed'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            OutlinedCard(
              child: Column(
                children: [
                  for (var i = 0; i < steps.length; i++)
                    _StepRow(
                      label: steps[i],
                      state: i < active
                          ? _StepState.done
                          : i == active
                          ? _StepState.active
                          : _StepState.pending,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: ((active + 1) / steps.length).clamp(0, .9),
              minHeight: 12,
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Card(
                key: ValueKey(tip),
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: const Text(AiExamStrings.tipLabel),
                  subtitle: Text(tip),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onCancel ?? () => Navigator.maybePop(context),
              child: const Text(AiExamStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }
}

enum _StepState { done, active, pending }

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.state});
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: switch (state) {
              _StepState.done => Icon(
                Icons.check_circle,
                key: ValueKey('step-done-$label'),
                color: AppPalette.of(context).listening.ink,
                size: 22,
              ),
              _StepState.active => Padding(
                padding: const EdgeInsets.all(2),
                child: CircularProgressIndicator(
                  key: ValueKey('step-active-$label'),
                  strokeWidth: 2,
                ),
              ),
              _StepState.pending => Icon(
                Icons.radio_button_unchecked,
                key: ValueKey('step-pending-$label'),
                color: scheme.outline,
                size: 22,
              ),
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: state == _StepState.pending
                    ? scheme.onSurfaceVariant
                    : null,
                fontWeight: state == _StepState.active ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
