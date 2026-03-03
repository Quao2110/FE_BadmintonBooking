import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_notification.dart';
import 'login_page.dart';
import 'home_screen.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final bool is2fa;
  const OtpVerifyPage({super.key, required this.email, this.is2fa = false});
  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  void _verify(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final code = _otpCtrl.text.trim();
    if (widget.is2fa) {
      context
          .read<AuthBloc>()
          .add(Verify2faLoginEvent(email: widget.email, code: code));
    } else {
      context
          .read<AuthBloc>()
          .add(VerifyOtpEvent(email: widget.email, otp: code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.is2fa ? 'Xác thực đăng nhập' : 'Xác thực email',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            if (widget.is2fa) {
              AppNotification.showSuccess('Xác thực thành công! Chào mừng 👋');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => HomeScreen(user: state.user)),
                (route) => false,
              );
            } else {
              context.read<AuthBloc>().add(const LogoutEvent());
              AppNotification.showSuccess(
                  'Đăng ký thành công! Vui lòng đăng nhập 🎉');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          } else if (state is AuthFailure) {
            AppNotification.showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.is2fa
                              ? Icons.lock_clock_outlined
                              : Icons.mark_email_read_outlined,
                          size: 40,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      widget.is2fa ? 'Xác thực 2 bước' : 'Nhập mã xác nhận',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Mã${widget.is2fa ? ' xác thực' : ' OTP'} đã được gửi tới\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          height: 1.6),
                    ),
                    const SizedBox(height: 36),

                    // OTP field
                    TextFormField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: Validators.otp,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        letterSpacing: 14,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '------',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 30,
                          letterSpacing: 14,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: cs.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Verify button
                    FilledButton(
                      onPressed: isLoading ? null : () => _verify(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              widget.is2fa
                                  ? 'Xác nhận đăng nhập'
                                  : 'Xác nhận',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Resend hint
                    Text(
                      'Không nhận được mã? Kiểm tra hộp thư spam hoặc thử lại.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
