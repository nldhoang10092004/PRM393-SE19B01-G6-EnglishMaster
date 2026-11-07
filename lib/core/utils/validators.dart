import '../l10n/app_strings.dart';

/// Form field validators shared by auth and profile forms.
/// Each returns an error message, or null when the value is valid.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Returns an error message when the value is empty, otherwise null.
  static String? required(String? value, {String field = AppStrings.field}) =>
      (value == null || value.trim().isEmpty)
      ? AppStrings.requiredField(field)
      : null;

  /// Validates the email format and returns an error message when invalid.
  static String? email(String? value) {
    final empty = required(value, field: AppStrings.email);
    if (empty != null) return empty;
    return _emailRegex.hasMatch(value!.trim()) ? null : AppStrings.invalidEmail;
  }

  /// Validates that a password is present and at least 6 characters long.
  static String? password(String? value) {
    final empty = required(value, field: AppStrings.password);
    if (empty != null) return empty;
    return value!.length < 6 ? AppStrings.shortPassword : null;
  }

  /// Returns an error message when the confirmation does not match.
  static String? confirmPassword(String? value, String original) =>
      value != original ? AppStrings.passwordMismatch : null;

  /// Validates that the OTP code is 4 to 8 digits.
  static String? otp(String? value) {
    final empty = required(value, field: AppStrings.otp);
    if (empty != null) return empty;
    return RegExp(r'^\d{4,8}$').hasMatch(value!.trim())
        ? null
        : AppStrings.invalidOtp;
  }
}
