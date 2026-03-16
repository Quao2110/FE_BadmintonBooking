import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../core/theme/colors.dart';
import '../../../routes/app_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../auth/login_page.dart';

/// Admin Dashboard Layout với Sidebar
/// Dùng để wrap các trang admin (Users, Courts, Products...)
class AdminLayout extends StatefulWidget {
  final User user;
  final Widget child;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.user,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

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
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // Main content luôn có margin left 70px
              Positioned.fill(
                left: 70,
                child: Column(
                  children: [
                    _buildTopBar(context, isMobile: isMobile),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
              // Backdrop khi sidebar expanded
              if (_isSidebarExpanded)
                Positioned.fill(
                  left: 70,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSidebarExpanded = false;
                      });
                    },
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),
              // Sidebar overlay (luôn ở trên cùng)
              _buildSidebar(
                context,
                isMobile: isMobile,
                screenWidth: screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Top Bar
  Widget _buildTopBar(BuildContext context, {required bool isMobile}) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(widget.currentRoute),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
                arguments: HomeArgs(widget.user),
              );
            },
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Về User'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar content
  Widget _buildSidebar(
    BuildContext context, {
    required bool isMobile,
    required double screenWidth,
  }) {
    final isExpanded = _isSidebarExpanded;
    final sidebarWidth = isExpanded ? (screenWidth * 0.75) : 70.0;

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: sidebarWidth,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  if (!isExpanded) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSidebarExpanded = true;
                          });
                        },
                        tooltip: 'Mở rộng',
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSidebarExpanded = false;
                          });
                        },
                        tooltip: 'Thu gọn',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _MenuItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Trang chủ',
                    route: AppRoutes.adminDashboard,
                    currentRoute: widget.currentRoute,
                    isExpanded: isExpanded,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.adminDashboard,
                        arguments: widget.user,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.people_outline_rounded,
                    label: 'Quản lý Users',
                    route: AppRoutes.admin,
                    currentRoute: widget.currentRoute,
                    isExpanded: isExpanded,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.admin,
                        arguments: widget.user,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.sports_tennis_rounded,
                    label: 'Quản lý Sân',
                    route: AppRoutes.adminCourts,
                    currentRoute: widget.currentRoute,
                    isExpanded: isExpanded,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.adminCourts,
                        arguments: widget.user,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Quản lý Sản phẩm',
                    route: AppRoutes.adminProducts,
                    currentRoute: widget.currentRoute,
                    isExpanded: isExpanded,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.adminProducts,
                        arguments: widget.user,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.store_rounded,
                    label: 'Cài đặt Shop',
                    route: AppRoutes.adminShop,
                    currentRoute: widget.currentRoute,
                    isExpanded: isExpanded,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.adminShop,
                        arguments: widget.user,
                      );
                    },
                  ),
                ],
              ),
            ),

            // User Info & Logout
            Container(
              padding: EdgeInsets.all(isExpanded ? 16 : 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Column(
                children: [
                  if (isExpanded) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            widget.user.fullName
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.fullName ?? 'Admin',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.user.role ?? 'Administrator',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.home,
                                (route) => false,
                                arguments: HomeArgs(widget.user),
                              );
                            },
                            icon: const Icon(Icons.home_rounded, size: 16),
                            label: const Text(
                              'User',
                              style: TextStyle(fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<AuthBloc>().add(const LogoutEvent());
                            },
                            icon: const Icon(Icons.logout_rounded, size: 16),
                            label: const Text(
                              'Out',
                              style: TextStyle(fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Collapsed sidebar: chỉ hiện các icon buttons
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        widget.user.fullName?.substring(0, 1).toUpperCase() ??
                            'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                          arguments: HomeArgs(widget.user),
                        );
                      },
                      tooltip: 'Về trang User',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(const LogoutEvent());
                      },
                      tooltip: 'Đăng xuất',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case AppRoutes.adminDashboard:
        return 'Trang chủ';
      case AppRoutes.admin:
        return 'Users';
      case AppRoutes.adminCourts:
        return 'Sân';
      case AppRoutes.adminProducts:
        return 'Sản phẩm';
      case AppRoutes.adminShop:
        return 'Shop';
      default:
        return 'Admin';
    }
  }
}

/// Menu Item Widget
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final bool isExpanded;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentRoute == route;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 4,
        vertical: 4,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16 : 8,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              if (isExpanded) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
