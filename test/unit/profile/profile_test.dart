import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/core/widgets/async_view.dart';
import 'package:english_master/features/profile/data/models/user_profile.dart';
import 'package:english_master/features/profile/data/profile_repository.dart';
import 'package:english_master/features/profile/presentation/providers/profile_provider.dart';

class _Repository extends Mock implements ProfileRepository {}

class _Api extends Mock implements ApiClient {}

void main() {
  const profile = UserProfile(
    accountId: 4,
    fullName: 'Anna Nguyen',
    email: 'anna@example.test',
    address: 'HCMC',
    phone: '0912345678',
  );
  setUpAll(() => registerFallbackValue(profile));

  test('profile and membership parse nullable actual DTO fields', () {
    final user = UserProfile.fromJson({
      'accountID': 4,
      'fullName': 'Anna Nguyen',
      'email': 'anna@example.test',
      'dob': '2003-05-14',
      'address': null,
      'phone': '0912345678',
    });
    expect(user.accountId, 4);
    expect(user.dob!.month, 5);
    expect(user.address, '');
    expect(user.toUpdateJson()['dob'], '2003-05-14');
    expect(user.toUpdateJson().containsKey('email'), isFalse);
    final membership = MembershipStatus.fromJson({
      'hasMembership': true,
      'startsAt': '2026-01-01T00:00:00Z',
      'endsAt': '2026-12-31T23:59:59Z',
      'planName': null,
      'status': 'ACTIVE',
    });
    expect(membership.hasMembership, isTrue);
    expect(membership.endsAt!.year, 2026);
    expect(membership.planName, '');
    expect(MembershipStatus.fromJson({'hasMembership': false}).endsAt, isNull);
  });

  test('secondary failures keep profile visible and update rereads normalized data', () async {
    final repository = _Repository();
    final state = ProfileProvider(repository);
    addTearDown(state.dispose);
    when(() => repository.detail()).thenAnswer((_) async => profile);
    when(() => repository.avatar()).thenThrow(ApiException('Avatar offline'));
    when(() => repository.membership())
        .thenThrow(ApiException('Membership offline'));
    when(() => repository.stats())
        .thenAnswer((_) async => (streak: 3, attempts: 2, words: 1));
    when(() => repository.update(any())).thenAnswer((_) async {});
    await state.load();
    expect(state.status, ViewStatus.success);
    expect(state.profile, profile);
    expect(state.membershipError, 'Membership offline');
    expect(state.stats!.streak, 3);
    expect(await state.update(profile), isTrue);
    verify(() => repository.detail()).called(2);
  });

  test('password failure is captured without escaping to widgets', () async {
    final repository = _Repository();
    final state = ProfileProvider(repository);
    addTearDown(state.dispose);
    when(() => repository.changePassword('old', 'new123', 'new123'))
        .thenThrow(ApiException('Current password is incorrect.'));
    expect(await state.changePassword('old', 'new123', 'new123'), isFalse);
    expect(state.busy, isFalse);
    expect(state.error, 'Current password is incorrect.');
  });

  test('repository sends DTO password names and DateOnly birthday', () async {
    final api = _Api();
    final repository = ProfileRepository(api);
    when(() => api.put(any(), body: any(named: 'body')))
        .thenAnswer((_) async => {'message': 'Updated'});
    await repository.changePassword('old', 'new123', 'new123');
    verify(
      () => api.put(
        '/api/user/profile/password',
        body: {
          'currentPassword': 'old',
          'newPassword': 'new123',
          'confirmNewPassword': 'new123',
        },
      ),
    ).called(1);
    await repository.update(
      UserProfile(accountId: 4, fullName: ' Anna ', dob: DateTime(2003, 5, 14)),
    );
    verify(
      () => api.put(
        '/api/user/profile/detail',
        body: {
          'fullName': 'Anna',
          'phone': '',
          'address': '',
          'dob': '2003-05-14',
        },
      ),
    ).called(1);
  });
}
