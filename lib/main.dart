import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_repository.dart';

/// Entry point: builds the long-lived services, then starts the widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStorage = SecureTokenStorage();
  // Date symbols and the documents directory are independent: load in parallel.
  // (Notification plugin init is lazy, it never runs before the first frame.)
  final (_, docsDir) = await (
    initializeDateFormatting('vi'),
    // Cookies (refresh token) survive app restarts.
    getApplicationDocumentsDirectory(),
  ).wait;
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${docsDir.path}/.cookies/'),
  );

  final apiClient = ApiClient(tokenStorage: tokenStorage, cookieJar: cookieJar);
  final authRepository = AuthRepository(api: apiClient, storage: tokenStorage);

  runApp(
    EnglishMasterApp(apiClient: apiClient, authRepository: authRepository),
  );
}
