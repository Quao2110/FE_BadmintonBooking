import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../../../core/theme/colors.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';

/// Admin Dashboard - Trang tổng quan
class AdminDashboardPage extends StatelessWidget {
  final User user;

  const AdminDashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      user: user,
      currentRoute: AppRoutes.adminDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào mừng trở lại, ${user.fullName?.split(' ').last ?? 'Admin'}! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quản lý hệ thống đặt sân cầu lông',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Cards
            const Text(
              'Tổng quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return GridView.count(
                  crossAxisCount: isMobile ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isMobile ? 1.4 : 1.5,
                  children: [
                    _StatCard(
                      icon: Icons.people_rounded,
                      title: 'Users',
                      value: '150',
                      color: Colors.blue,
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.admin,
                        arguments: user,
                      ),
                    ),
                    _StatCard(
                      icon: Icons.sports_tennis_rounded,
                      title: 'Sân',
                      value: '12',
                      color: Colors.green,
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.adminCourts,
                        arguments: user,
                      ),
                    ),
                    _StatCard(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Sản phẩm',
                      value: '45',
                      color: Colors.orange,
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.adminProducts,
                        arguments: user,
                      ),
                    ),
                    _StatCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Bookings',
                      value: '89',
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Thao tác nhanh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickActionButton(
                      icon: Icons.person_add_rounded,
                      label: 'Thêm User',
                      isMobile: isMobile,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.admin,
                        arguments: user,
                      ),
                    ),
                    _QuickActionButton(
                      icon: Icons.add_business_rounded,
                      label: 'Thêm Sân',
                      isMobile: isMobile,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.adminCourts,
                        arguments: user,
                      ),
                    ),
                    _QuickActionButton(
                      icon: Icons.add_shopping_cart_rounded,
                      label: 'Thêm Sản phẩm',
                      isMobile: isMobile,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.adminProducts,
                        arguments: user,
                      ),
                    ),
                    _QuickActionButton(
                      icon: Icons.settings_rounded,
                      label: 'Cài đặt Shop',
                      isMobile: isMobile,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.adminShop,
                        arguments: user,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Action Button Widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isMobile;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.isMobile = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
