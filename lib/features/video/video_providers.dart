import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/video_repository.dart';

/// Dependency registration of the video feature.
class VideoProviders {
  VideoProviders._();

  /// Providers to add to the app-level `MultiProvider`.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, VideoRepository>(
      update: (_, api, _) => VideoRepository(api),
    ),
  ];
}
