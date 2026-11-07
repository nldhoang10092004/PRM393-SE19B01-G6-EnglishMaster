import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/ai_exam_repository.dart';

/// Registers shared dependencies. Exam and review state is owned by each route.
class AiExamProviders {
  AiExamProviders._();

  /// Spread after the existing ApiClient provider in the app's MultiProvider.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, AiExamRepository>(
      update: (_, api, previous) =>
          previous != null && identical(previous.api, api)
          ? previous
          : AiExamRepository(api),
    ),
  ];
}
