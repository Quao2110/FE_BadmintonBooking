import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'login_page.dart';
import '../user/profile_page.dart';
import '../../../routes/app_router.dart';
import '../../../core/constants/api_constants.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            if (user.id != null)
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Hồ sơ cá nhân',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: user.id!))),
              ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)));
                }
                return IconButton(icon: const Icon(Icons.logout), tooltip: 'Đăng xuất', onPressed: () => context.read<AuthBloc>().add(const LogoutEvent()));
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: user.id != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: user.id!))) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                              ? NetworkImage(ApiConstants.getFullImageUrl(user.avatarUrl))
                              : null,
                          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                              ? Text(
                                  (user.fullName?.isNotEmpty == true ? user.fullName![0] : '?').toUpperCase(),
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.fullName ?? 'Người dùng', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
                              if (user.role != null) ...[
                                const SizedBox(height: 4),
                                Chip(label: Text(user.role!, style: const TextStyle(fontSize: 12)), backgroundColor: Colors.blue.shade50, padding: EdgeInsets.zero),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Hồ sơ cá nhân',
                subtitle: 'Chỉnh sửa thông tin & đổi mật khẩu',
                onTap: user.id != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: user.id!))) : null,
              ),
              if (user.role?.toLowerCase() == 'admin') ...[
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Quản lý người dùng',
                  subtitle: 'Xem, chỉnh sửa và xoá tài khoản',
                  color: Colors.indigo,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? color;

  const _MenuItem({required this.icon, required this.title, required this.subtitle, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.blue;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: c.withOpacity(0.1), child: Icon(icon, color: c)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
