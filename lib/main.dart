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
  await initializeDateFormatting('vi');

  final tokenStorage = SecureTokenStorage();
  // Cookies (refresh token) survive app restarts.
  final docsDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${docsDir.path}/.cookies/'),
  );

  final apiClient = ApiClient(tokenStorage: tokenStorage, cookieJar: cookieJar);
  final authRepository = AuthRepository(api: apiClient, storage: tokenStorage);

  runApp(
    EnglishMasterApp(apiClient: apiClient, authRepository: authRepository),
  );
}
