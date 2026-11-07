import 'package:dio/dio.dart';

/// Error type exposed to repositories/providers so the UI never deals with
/// raw Dio errors.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  /// Converts a [DioException] into a user-friendly message.
  /// The API returns errors either as a plain string or as `{ message: ... }`.
  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? serverMessage;
    if (data is String && data.trim().isNotEmpty) {
      serverMessage = data;
    } else if (data is Map) {
      serverMessage = (data['message'] ?? data['title'] ?? data['error'])?.toString();
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException('The server took too long to respond. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException('Cannot connect to the server. Check your internet connection.');
      default:
        return ApiException(
          serverMessage ?? (status == 401 ? 'Your session has expired. Please log in again.' : 'Something went wrong ($status).'),
          statusCode: status,
        );
    }
  }

  @override
  String toString() => message;
}
