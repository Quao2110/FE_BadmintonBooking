import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../main.dart';
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
    final cs = Theme.of(context).colorScheme;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Lấy user từ state mới nhất để đảm bảo đồng bộ khi sửa ở Profile
          final currentUser = (state is AuthSuccess) ? state.user : user;

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F7),
            body: CustomScrollView(
              slivers: [
                // ── App bar ────────────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    title: Text(
                      'Xin chào, ${currentUser.fullName?.split(' ').last ?? 'bạn'} 👋',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [cs.primary, cs.secondary],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    if (currentUser.id != null)
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        tooltip: 'Hồ sơ cá nhân',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProfilePage(userId: currentUser.id!)),
                        ),
                      ),
                    if (state is AuthLoading)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        tooltip: 'Đăng xuất',
                        onPressed: () =>
                            context.read<AuthBloc>().add(const LogoutEvent()),
                      ),
                  ],
                ),

                // ── Body ───────────────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Profile card
                      _ProfileCard(user: currentUser, cs: cs),
                      const SizedBox(height: 20),

                      // Section title
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, left: 2),
                        child: Text(
                          'Chức năng',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: cafeNoir),
                        ),
                      ),

                      // Menu items
                      _MenuTile(
                        icon: Icons.person_outline,
                        iconColor: cs.primary,
                        title: 'Hồ sơ cá nhân',
                        subtitle: 'Xem và chỉnh sửa thông tin',
                        onTap: currentUser.id != null
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ProfilePage(userId: currentUser.id!)),
                                )
                            : null,
                      ),
                      const SizedBox(height: 10),

                      _MenuTile(
                        icon: Icons.sports_tennis,
                        iconColor: mossGreen,
                        title: 'Đặt sân',
                        subtitle: 'Tìm và đặt sân cầu lông',
                        onTap: () {}, // TODO: navigate to booking
                      ),

                      if (currentUser.role?.toLowerCase() == 'admin') ...[
                        const SizedBox(height: 10),
                        _MenuTile(
                          icon: Icons.admin_panel_settings_outlined,
                          iconColor: cafeNoir,
                          title: 'Quản lý người dùng',
                          subtitle: 'Xem, chỉnh sửa và xoá tài khoản',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.admin),
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final User user;
  final ColorScheme cs;
  const _ProfileCard({required this.user, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: user.id != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfilePage(userId: user.id!)),
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: cs.primaryContainer,
                backgroundImage:
                    (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(
                            ApiConstants.getFullImageUrl(user.avatarUrl))
                        : null,
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? Text(
                        (user.fullName?.isNotEmpty == true
                                ? user.fullName![0]
                                : '?')
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: cs.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'Người dùng',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(user.email,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                    if (user.role != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cs.primary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu tile ─────────────────────────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
