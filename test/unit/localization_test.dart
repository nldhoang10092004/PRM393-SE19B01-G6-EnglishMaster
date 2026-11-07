import 'package:dio/dio.dart';
import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/features/auth/data/auth_repository.dart';
import 'package:english_master/features/auth/presentation/providers/auth_provider.dart';
import 'package:english_master/features/home/presentation/widgets/home_greeting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _AuthRepository extends Mock implements AuthRepository {}

void main() {
  test('server errors are preserved verbatim in every supported envelope', () {
    const message = '  Mật khẩu hiện tại không đúng.  ';
    final request = RequestOptions(path: '/test');
    for (final body in [
      message,
      {'message': message},
      {'title': message},
      {'error': message},
    ]) {
      final error = ApiException.fromDio(
        DioException(
          requestOptions: request,
          response: Response(
            requestOptions: request,
            statusCode: 400,
            data: body,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(error.message, message);
      expect(error.statusCode, 400);
    }
  });

  test('network errors without a server message use Vietnamese fallbacks', () {
    final request = RequestOptions(path: '/test');
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      expect(
        ApiException.fromDio(DioException(requestOptions: request, type: type))
            .message,
        AppStrings.timeout,
      );
    }
    expect(
      ApiException.fromDio(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      ).message,
      AppStrings.connectionError,
    );
    final expired = ApiException.fromDio(
      DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 401),
        type: DioExceptionType.badResponse,
      ),
    );
    expect(expired.message, AppStrings.sessionExpired);
    expect(expired.isUnauthorized, isTrue);
  });

  test('authentication preserves server messages and localizes unexpected failures', () async {
    final repository = _AuthRepository();
    final auth = AuthProvider(repository);
    addTearDown(auth.dispose);
    const message = 'Email hoặc mật khẩu không đúng.';
    when(() => repository.login(any(), any())).thenThrow(ApiException(message));
    expect(await auth.login('student', 'password'), isFalse);
    expect(auth.error, message);
    when(() => repository.login(any(), any()))
        .thenThrow(StateError('Internal details'));
    expect(await auth.login('student', 'password'), isFalse);
    expect(auth.error, AppStrings.unexpectedError);
  });

  test('greetings switch to Vietnamese at midday and evening', () {
    expect(HomeGreeting.greetingFor(0), AppStrings.morning);
    expect(HomeGreeting.greetingFor(11), AppStrings.morning);
    expect(HomeGreeting.greetingFor(12), AppStrings.afternoon);
    expect(HomeGreeting.greetingFor(17), AppStrings.afternoon);
    expect(HomeGreeting.greetingFor(18), AppStrings.evening);
    expect(HomeGreeting.greetingFor(23), AppStrings.evening);
  });
}
