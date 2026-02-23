import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../core/utils/validators.dart';
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
  void dispose() { _otpCtrl.dispose(); super.dispose(); }

  void _verify(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final code = _otpCtrl.text.trim();
    if (widget.is2fa) {
      context.read<AuthBloc>().add(Verify2faLoginEvent(email: widget.email, code: code));
    } else {
      context.read<AuthBloc>().add(VerifyOtpEvent(email: widget.email, otp: code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.is2fa ? 'Xác thực đăng nhập' : 'Xác thực OTP'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            if (widget.is2fa) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(user: state.user)), (route) => false);
            } else {
              context.read<AuthBloc>().add(const LogoutEvent());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Flexible(child: Text('Đăng ký thành công! Vui lòng đăng nhập.'))]), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), duration: const Duration(seconds: 3)));
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(widget.is2fa ? Icons.lock_clock : Icons.mark_email_read_outlined, size: 72, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(widget.is2fa ? 'Xác thực 2 bước' : 'Nhập mã OTP', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Mã${widget.is2fa ? ' xác thực' : ' OTP'} đã được gửi tới\n${widget.email}', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
                  const SizedBox(height: 32),
                  TextFormField(controller: _otpCtrl, keyboardType: TextInputType.number, maxLength: 6, validator: Validators.otp, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, letterSpacing: 10, fontWeight: FontWeight.bold), decoration: InputDecoration(labelText: 'Mã 6 chữ số', counterText: '', border: const OutlineInputBorder(), hintText: '••••••', hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 10))),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _verify(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(widget.is2fa ? 'XÁC NHẬN ĐĂNG NHẬP' : 'XÁC NHẬN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
