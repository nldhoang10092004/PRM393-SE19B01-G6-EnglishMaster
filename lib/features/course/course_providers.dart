import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/course_repository.dart';
import 'presentation/providers/course_list_provider.dart';

/// Dependency registration of the course feature.
///
/// The per-screen `CourseDetailProvider` is created by `CourseDetailScreen`.
class CourseProviders {
  CourseProviders._();

  /// Providers to add to the app-level `MultiProvider`.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, CourseRepository>(
      update: (_, api, _) => CourseRepository(api),
    ),
    ChangeNotifierProvider<CourseListProvider>(
      create: (ctx) => CourseListProvider(ctx.read<CourseRepository>()),
    ),
  ];
}
