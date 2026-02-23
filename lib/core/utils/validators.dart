/// Validators cho dữ liệu nhập liệu
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Email không đúng định dạng';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên';
    if (value.trim().length < 2) return 'Họ và tên quá ngắn';
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
    final phone = value.trim().replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^(0|\+84)[3-9][0-9]{8}$');
    if (!phoneRegex.hasMatch(phone)) return 'Số điện thoại không hợp lệ';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập mã OTP';
    if (value.trim().length != 6) return 'Mã OTP gồm 6 chữ số';
    return null;
  }

  static String? required(String? value, {String label = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) return '$label không được để trống';
    return null;
  }
}
