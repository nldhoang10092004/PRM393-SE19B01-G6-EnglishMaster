import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Single HTTP entry point of the app (wraps Dio).
///
/// Responsibilities:
/// * attaches `Authorization: Bearer <token>` to every request;
/// * keeps the refresh-token cookie (`emt_rt`) set by the API in a cookie jar;
/// * on HTTP 401 calls `/api/auth/refresh` once and retries the request;
/// * converts every failure into an [ApiException].
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    CookieJar? cookieJar,
    Dio? dio,
    String? baseUrl,
  }) : _tokens = tokenStorage,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
               connectTimeout: AppConfig.requestTimeout,
               receiveTimeout: AppConfig.requestTimeout,
               contentType: Headers.jsonContentType,
             ),
           ) {
    _dio.interceptors.add(CookieManager(cookieJar ?? CookieJar()));
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _attachToken, onError: _refreshOn401),
    );
  }

  final Dio _dio;
  final TokenStorage _tokens;

  /// Called when the session cannot be refreshed (e.g. to navigate to login).
  void Function()? onSessionExpired;

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokens.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _refreshOn401(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final isAuthCall = request.path.startsWith('/api/auth/');
    final alreadyRetried = request.extra['retried'] == true;
    if (error.response?.statusCode != 401 || isAuthCall || alreadyRetried) {
      return handler.next(error);
    }
    final refreshed = await _tryRefresh();
    if (!refreshed) {
      await _tokens.clear();
      onSessionExpired?.call();
      return handler.next(error);
    }
    try {
      request.extra['retried'] = true;
      final token = await _tokens.readAccessToken();
      request.headers['Authorization'] = 'Bearer $token';
      handler.resolve(await _dio.fetch(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Exchanges the expired access token + refresh cookie for a new token.
  Future<bool> _tryRefresh() async {
    try {
      final res = await _dio.post('/api/auth/refresh');
      final data = res.data as Map<String, dynamic>;
      final accountId = await _tokens.readAccountId();
      await _tokens.save(
        accessToken: data['accessToken'] as String,
        accountId: (data['accountID'] as num?)?.toInt() ?? accountId ?? 0,
        role: await _tokens.readRole(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) => _send(() => _dio.post(path, data: body, queryParameters: query));

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => _dio.put(path, data: body));

  Future<dynamic> delete(String path) => _send(() => _dio.delete(path));

  /// Uploads a file (e.g. a recorded answer) as `multipart/form-data`.
  /// [fields] are extra form fields sent next to the file.
  Future<dynamic> postMultipart(
    String path, {
    required String fileField,
    required String filePath,
    String? fileName,
    Map<String, dynamic>? fields,
    Duration? timeout,
  }) async {
    final form = FormData.fromMap({
      ...?fields,
      fileField: await MultipartFile.fromFile(filePath, filename: fileName),
    });
    return _send(
      () => _dio.post(
        path,
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: timeout ?? const Duration(seconds: 90),
          sendTimeout: timeout ?? const Duration(seconds: 90),
        ),
      ),
    );
  }

  /// POST with a longer timeout for slow AI endpoints (generation / grading).
  Future<dynamic> postSlow(
    String path, {
    Object? body,
    Duration timeout = const Duration(seconds: 90),
  }) => _send(
    () => _dio.post(
      path,
      data: body,
      options: Options(receiveTimeout: timeout, sendTimeout: timeout),
    ),
  );

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      final res = await call();
      return res.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
