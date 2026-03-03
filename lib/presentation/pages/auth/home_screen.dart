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
import '../../../core/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
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
          final currentUser = (state is AuthSuccess) ? state.user : user;

          return Scaffold(
            backgroundColor: boneColor,
            body: CustomScrollView(
              slivers: [
                // ── Modern AppBar ─────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: kombuGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    title: Text(
                      'Xin chào, ${currentUser.fullName?.split(' ').last ?? 'bạn'} 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kombuGreen, mossGreen],
                            ),
                          ),
                        ),
                        // Decorative elements
                        Positioned(
                          top: -20,
                          right: -20,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 20,
                          child: Icon(
                            Icons.sports_tennis,
                            size: 100,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    _NotificationButton(),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () => context.read<AuthBloc>().add(const LogoutEvent()),
                    ),
                  ],
                ),

                // ── Content ──────────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Sleek Profile Snippet
                      _HomeProfileSnippet(user: currentUser),
                      const SizedBox(height: 28),
                      
                      // Section Header
                      const _SectionHeader(title: 'Dịch vụ chính'),
                      const SizedBox(height: 16),

                      // Quick Actions Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            children: [
                              Expanded(
                                child: _FeatureCard(
                                  title: 'Đặt sân ngay',
                                  icon: Icons.calendar_today_rounded,
                                  color: kombuGreen,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FeatureCard(
                                  title: 'Cửa hàng',
                                  icon: Icons.shopping_bag_outlined,
                                  color: mossGreen,
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.storeList),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              title: 'Dịch vụ',
                              icon: Icons.cleaning_services_outlined,
                              color: tanColor,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.serviceList),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FeatureCard(
                              title: 'Lịch sử',
                              icon: Icons.history_rounded,
                              color: cafeNoir,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      const _SectionHeader(title: 'Tài khoản'),
                      const SizedBox(height: 16),

                      // Account options
                      _MenuListItem(
                        label: 'Thông tin cá nhân',
                        icon: Icons.person_outline_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage(userId: currentUser.id ?? '')),
                        ),
                      ),
                      
                      if (currentUser.role?.toLowerCase() == 'admin') ...[
                        const SizedBox(height: 12),
                        _MenuListItem(
                          label: 'Quản lý hệ thống (Admin)',
                          icon: Icons.admin_panel_settings_outlined,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
                        ),
                      ],
                      const SizedBox(height: 40),
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

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: tanColor,
              shape: BoxShape.circle,
            ),
          ),
        )
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kombuGreen,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Xem tất cả', style: TextStyle(color: mossGreen, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _HomeProfileSnippet extends StatelessWidget {
  final User user;
  const _HomeProfileSnippet({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kombuGreen.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _AvatarSmall(user: user),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'Quý khách',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  user.email,
                  style: TextStyle(color: cafeNoir.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: mossGreen),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage(userId: user.id ?? '')),
            ),
          )
        ],
      ),
    );
  }
}

class _AvatarSmall extends StatelessWidget {
  final User user;
  const _AvatarSmall({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: boneColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
          ? Image.network(
              ApiConstants.getFullImageUrl(user.avatarUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _letterAvatar(),
            )
          : _letterAvatar(),
    );
  }

  Widget _letterAvatar() {
    return Container(
      color: mossGreen.withOpacity(0.1),
      child: Center(
        child: Text(
          (user.fullName?.isNotEmpty == true ? user.fullName![0] : '?').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kombuGreen),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuListItem({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: boneColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kombuGreen, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right_rounded, color: boneColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
