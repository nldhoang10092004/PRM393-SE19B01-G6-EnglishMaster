import 'package:dio/dio.dart';

import '../l10n/app_strings.dart';

/// Error type exposed to repositories/providers so the UI never deals with
/// raw Dio errors.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  /// Premium content without an active membership (HTTP 403).
  bool get isForbidden => statusCode == 403;

  /// Converts a [DioException] into a user-friendly message.
  /// The API returns errors either as a plain string or as `{ message: ... }`.
  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? serverMessage;
    if (data is String && data.trim().isNotEmpty) {
      serverMessage = data;
    } else if (data is Map) {
      serverMessage = (data['message'] ?? data['title'] ?? data['error'])
          ?.toString();
    }
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return ApiException(serverMessage, statusCode: status);
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(AppStrings.timeout);
      case DioExceptionType.connectionError:
        return ApiException(AppStrings.connectionError);
      default:
        return ApiException(
          status == 401
              ? AppStrings.sessionExpired
              : AppStrings.serverError(status),
          statusCode: status,
        );
    }
  }

  @override
  String toString() => message;
}
