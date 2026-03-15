import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_notification.dart';
import '../../../routes/app_router.dart';
import 'register_page.dart';
import 'home_screen.dart';
import 'otp_verify_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginEvent(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        ));
  }

  void _googleLogin(BuildContext context) =>
      context.read<AuthBloc>().add(const GoogleLoginEvent());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            AppNotification.showSuccess('Đăng nhập thành công! Chào mừng bạn trở lại 👋', userId: state.user.id);
            
            // Redirect dựa vào role
            if (AppRouter.checkAdminAccess(state.user)) {
              // Admin -> Admin Dashboard
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.adminDashboard,
                (route) => false,
                arguments: state.user,
              );
            } else {
              // User thường -> Home Screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(user: state.user)),
                (route) => false,
              );
            }
          } else if (state is AuthOtpRequired) {
            AppNotification.showInfo('Vui lòng xác thực OTP để tiếp tục');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OtpVerifyPage(email: state.email, is2fa: state.is2fa)),
            );
          } else if (state is AuthFailure) {
            AppNotification.showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary, cs.secondary],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Header hero ──────────────────────────────────────────
                  SizedBox(
                    height: size.height * 0.28,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.sports_tennis,
                                size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Badminton App',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đặt sân – Chơi thể thao – Kết nối bạn bè',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Form card ────────────────────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nhập thông tin tài khoản của bạn',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                            //    validator: Validators.email,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon:
                                      Icon(Icons.email_outlined, color: cs.primary),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: cs.primary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscurePass,
                                validator: Validators.password,
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu',
                                  prefixIcon:
                                      Icon(Icons.lock_outline, color: cs.primary),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePass
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: cs.primary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Login button
                              FilledButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _login(context),
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
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text(
                                        'Đăng nhập',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                              const SizedBox(height: 16),

                              // Divider
                              Row(children: [
                                Expanded(
                                    child: Divider(color: Colors.grey.shade300)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('hoặc',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13)),
                                ),
                                Expanded(
                                    child: Divider(color: Colors.grey.shade300)),
                              ]),
                              const SizedBox(height: 16),

                              // Google button
                              OutlinedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => _googleLogin(context),
                                icon: const Icon(Icons.g_mobiledata,
                                    size: 26, color: Colors.red),
                                label: const Text('Tiếp tục với Google',
                                    style: TextStyle(fontSize: 14)),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Register link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Chưa có tài khoản?',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14)),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const RegisterScreen()),
                                            ),
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6)),
                                    child: const Text('Đăng ký ngay',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
