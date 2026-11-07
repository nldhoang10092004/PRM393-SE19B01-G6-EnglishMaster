import '../l10n/app_strings.dart';

/// Form field validators shared by auth and profile forms.
/// Each returns an error message, or null when the value is valid.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? required(String? value, {String field = AppStrings.field}) =>
      (value == null || value.trim().isEmpty)
      ? AppStrings.requiredField(field)
      : null;

  static String? email(String? value) {
    final empty = required(value, field: AppStrings.email);
    if (empty != null) return empty;
    return _emailRegex.hasMatch(value!.trim()) ? null : AppStrings.invalidEmail;
  }

  static String? password(String? value) {
    final empty = required(value, field: AppStrings.password);
    if (empty != null) return empty;
    return value!.length < 6 ? AppStrings.shortPassword : null;
  }

  static String? confirmPassword(String? value, String original) =>
      value != original ? AppStrings.passwordMismatch : null;

  static String? otp(String? value) {
    final empty = required(value, field: AppStrings.otp);
    if (empty != null) return empty;
    return RegExp(r'^\d{4,8}$').hasMatch(value!.trim())
        ? null
        : AppStrings.invalidOtp;
  }
}
