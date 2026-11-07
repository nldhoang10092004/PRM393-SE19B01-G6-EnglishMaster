/// Form field validators shared by auth and profile forms.
/// Each returns an error message, or null when the value is valid.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? required(String? value, {String field = 'This field'}) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? value) {
    final empty = required(value, field: 'Email');
    if (empty != null) return empty;
    return _emailRegex.hasMatch(value!.trim()) ? null : 'Enter a valid email address';
  }

  static String? password(String? value) {
    final empty = required(value, field: 'Password');
    if (empty != null) return empty;
    return value!.length < 6 ? 'Password must be at least 6 characters' : null;
  }

  static String? confirmPassword(String? value, String original) =>
      value != original ? 'Passwords do not match' : null;

  static String? otp(String? value) {
    final empty = required(value, field: 'OTP');
    if (empty != null) return empty;
    return RegExp(r'^\d{4,8}$').hasMatch(value!.trim()) ? null : 'OTP must be digits';
  }
}
