import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../core/theme/colors.dart';
import '../../../routes/app_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../auth/login_page.dart';

/// Admin Dashboard Layout - Bottom Nav trên mobile, Sidebar trên tablet+
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
  bool _isDrawerOpen = false;

  static const _menuItems = <_MenuDef>[
    _MenuDef(Icons.dashboard_rounded, 'Dashboard', AppRoutes.adminDashboard),
    _MenuDef(Icons.people_outline_rounded, 'Users', AppRoutes.admin),
    _MenuDef(Icons.sports_tennis_rounded, 'Courts', AppRoutes.adminCourts),
    _MenuDef(Icons.shopping_bag_outlined, 'Products', AppRoutes.adminProducts),
    _MenuDef(Icons.store_rounded, 'Shop', AppRoutes.adminShop),
    _MenuDef(Icons.calendar_month_rounded, 'Bookings', AppRoutes.adminBookings),
    _MenuDef(Icons.local_shipping_rounded, 'Orders', AppRoutes.adminOrders),
    _MenuDef(Icons.inbox_rounded, 'Inbox', AppRoutes.adminInbox),
  ];

  int get _currentIndex {
    final idx = _menuItems.indexWhere((m) => m.route == widget.currentRoute);
    return idx >= 0 ? idx : 0;
  }

  void _navigateTo(String route) {
    if (route == widget.currentRoute) return;
    Navigator.pushReplacementNamed(context, route, arguments: widget.user);
  }

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Portrait phone -> bottom nav
          // Landscape or tablet -> sidebar
          final isPortrait = constraints.maxWidth < 600;
          if (isPortrait) {
            return _buildMobileLayout();
          }
          return _buildSidebarLayout(constraints.maxWidth);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT: AppBar + Content + BottomNav
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _getPageTitle(widget.currentRoute),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 22),
            tooltip: 'Về User',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
              arguments: HomeArgs(widget.user),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const LogoutEvent());
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  widget.user.fullName ?? 'Admin',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: SafeArea(child: widget.child),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    // Show 5 items max in bottom nav, rest go to "More" menu
    const maxBottomItems = 4;
    final mainItems = _menuItems.take(maxBottomItems).toList();
    final overflowItems = _menuItems.skip(maxBottomItems).toList();
    final hasOverflow = overflowItems.isNotEmpty;
    final isInOverflow = _currentIndex >= maxBottomItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Main nav items
              ...mainItems.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == i;
                return Expanded(
                  child: _BottomNavItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => _navigateTo(item.route),
                  ),
                );
              }),
              // "More" button for overflow items
              if (hasOverflow)
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.menu_rounded,
                    label: 'More',
                    isSelected: isInOverflow,
                    onTap: () => _showMoreSheet(overflowItems),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreSheet(List<_MenuDef> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...items.map((item) {
                final isSelected = widget.currentRoute == item.route;
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateTo(item.route);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIDEBAR LAYOUT: For landscape / tablet
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSidebarLayout(double screenWidth) {
    final sidebarCollapsedWidth = 64.0;
    final sidebarExpandedWidth = (screenWidth * 0.6).clamp(220.0, 280.0);
    final sidebarWidth = _isDrawerOpen ? sidebarExpandedWidth : sidebarCollapsedWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: sidebarWidth,
              child: _buildSidebar(sidebarWidth > 100),
            ),
            // Main content
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(widget.currentRoute),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
              arguments: HomeArgs(widget.user),
            ),
            icon: const Icon(Icons.home_rounded, size: 16),
            label: const Text('User'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isExpanded) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 0),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
            child: isExpanded
                ? Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Admin',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 22),
                        onPressed: () => setState(() => _isDrawerOpen = false),
                      ),
                    ],
                  )
                : Center(
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
                      onPressed: () => setState(() => _isDrawerOpen = true),
                    ),
                  ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _menuItems.map((item) {
                final isSelected = widget.currentRoute == item.route;
                return _SidebarItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  isExpanded: isExpanded,
                  onTap: () => _navigateTo(item.route),
                );
              }).toList(),
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(isExpanded ? 12 : 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: isExpanded
                ? Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              widget.user.fullName?.substring(0, 1).toUpperCase() ?? 'A',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.user.fullName ?? 'Admin',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => context.read<AuthBloc>().add(const LogoutEvent()),
                          icon: const Icon(Icons.logout_rounded, size: 16),
                          label: const Text('Logout', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          widget.user.fullName?.substring(0, 1).toUpperCase() ?? 'A',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                        onPressed: () => context.read<AuthBloc>().add(const LogoutEvent()),
                        tooltip: 'Logout',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case AppRoutes.adminDashboard:
        return 'Dashboard';
      case AppRoutes.admin:
        return 'Users';
      case AppRoutes.adminCourts:
        return 'Courts';
      case AppRoutes.adminProducts:
        return 'Products';
      case AppRoutes.adminShop:
        return 'Shop';
      case AppRoutes.adminBookings:
        return 'Bookings';
      case AppRoutes.adminOrders:
        return 'Orders';
      case AppRoutes.adminInbox:
        return 'Inbox';
      default:
        return 'Admin';
    }
  }
}

// ─── Data class for menu items ────────────────────────────────────────────────

class _MenuDef {
  final IconData icon;
  final String label;
  final String route;
  const _MenuDef(this.icon, this.label, this.route);
}

// ─── Bottom Nav Item ──────────────────────────────────────────────────────────

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Sidebar Item ─────────────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 8 : 4,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 12 : 0,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
