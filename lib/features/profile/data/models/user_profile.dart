import '../../../../core/utils/json_utils.dart';

/// Editable profile fields returned by the student detail endpoint.
class UserProfile {
  const UserProfile({
    required this.accountId,
    this.fullName = '',
    this.email = '',
    this.dob,
    this.address = '',
    this.phone = '',
  });
  final int accountId;
  final String fullName;
  final String email;
  final DateTime? dob;
  final String address;
  final String phone;
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    accountId: json.asInt('accountID'),
    fullName: json.asString('fullName'),
    email: json.asString('email'),
    dob: json.asDate('dob'),
    address: json.asString('address'),
    phone: json.asString('phone'),
  );

  /// DateOnly must be serialized as yyyy-MM-dd, without a timezone suffix.
  Map<String, dynamic> toUpdateJson() => {
    'fullName': fullName.trim(),
    'phone': phone.trim(),
    'address': address.trim(),
    'dob': dob == null
        ? null
        : '${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}',
  };
}

/// Membership status, including expiration when a plan is active.
class MembershipStatus {
  const MembershipStatus({
    required this.hasMembership,
    this.startsAt,
    this.endsAt,
    this.planName = '',
    this.status = '',
  });
  final bool hasMembership;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String planName;
  final String status;
  factory MembershipStatus.fromJson(Map<String, dynamic> json) =>
      MembershipStatus(
        hasMembership: json.asBool('hasMembership'),
        startsAt: json.asDate('startsAt'),
        endsAt: json.asDate('endsAt'),
        planName: json.asString('planName'),
        status: json.asString('status'),
      );
}
