/// Formats currency amounts as "1,250" style strings.
class Formatters {
  Formatters._();

  static String number(num value) {
    final digits = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String amount(num value) => '${number(value)} د.ل';

  /// Whether [phone] is a valid Libyan mobile number.
  ///
  /// Libyan mobile numbers start with `09` followed by 8 digits
  /// (e.g. `091 234 5678`). Spaces and dashes are ignored.
  static bool isValidLibyanPhone(String? phone) {
    if (phone == null) return false;
    final digits = phone.replaceAll(RegExp(r'[\s\-]'), '');
    return RegExp(r'^09\d{8}$').hasMatch(digits);
  }
}
