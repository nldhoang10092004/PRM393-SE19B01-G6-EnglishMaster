import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../providers/course_detail_provider.dart';

/// Dialog to write a review: star selector, optional comment, submit.
/// Closes itself on success; shows the server error inline otherwise.
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key, required this.provider});

  final CourseDetailProvider provider;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _comment = TextEditingController();
  int _rating = 5;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await widget.provider.submitFeedback(_rating, _comment.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = widget.provider.actionError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text(AppStrings.rateCourse),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: AppStrings.starCount(i),
                  onPressed: _busy ? null : () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: scheme.tertiary,
                    size: 32,
                  ),
                ),
            ],
          ),
          TextField(
            controller: _comment,
            enabled: !_busy,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(hintText: AppStrings.reviewHint),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: scheme.error)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.submit),
        ),
      ],
    );
  }
}
