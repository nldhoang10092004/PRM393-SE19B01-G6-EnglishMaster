import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';

/// Makes teacher sharing and its history side effect explicit before submission.
class AiTeacherSwitch extends StatelessWidget {
  const AiTeacherSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    value: value,
    onChanged: onChanged,
    title: const Text(AiExamStrings.sendToTeacher),
    subtitle: const Text(AiExamStrings.teacherNote),
  );
}
