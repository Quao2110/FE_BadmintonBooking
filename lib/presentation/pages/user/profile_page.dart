import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/user.dart';
import '../../../main.dart';
import '../../../shared/widgets/app_notification.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../../data/models/user/update_user_request.dart';
import '../../../data/models/user/change_password_request.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/colors.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc.create()..add(GetUserByIdEvent(userId)),
      child: _ProfileView(userId: userId),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final String userId;
  const _ProfileView({required this.userId});
  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneColor, // Use the shared palette background
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            final updated = state.updatedUser;
            if (updated != null) {
              context.read<AuthBloc>().add(UpdateAuthUserEvent(User(
                id: updated.id,
                email: updated.email,
                fullName: updated.fullName,
                role: updated.role,
                avatarUrl: updated.avatarUrl,
                token: (context.read<AuthBloc>().state is AuthSuccess)
                    ? (context.read<AuthBloc>().state as AuthSuccess).user.token
                    : null,
              )));
            }
            AppNotification.showInfo(state.message, userId: widget.userId);
            if (state.updatedUser != null) {
              context.read<UserBloc>().add(GetUserByIdEvent(widget.userId));
            }
          } else if (state is UserError) {
            AppNotification.showError(state.message, userId: widget.userId);
          }
        },
        builder: (context, state) {
          if (state is UserLoading) return const Center(child: CircularProgressIndicator(color: kombuGreen));
          
          final user = state is UserLoaded 
              ? state.user 
              : (state is UserActionSuccess ? state.updatedUser : null);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  floating: false,
                  backgroundColor: kombuGreen,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      innerBoxIsScrolled ? 'Hồ sơ cá nhân' : '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Decoration
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [kombuGreen, mossGreen],
                            ),
                          ),
                        ),
                        // Circular decoration
                        Positioned(
                          right: -50,
                          top: -50,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        // Avatar Section in Header
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ProfileAvatar(
                                user: user,
                                onPickImage: user != null ? () {} : null, // Handled inside tab
                              ),
                              const SizedBox(height: 12),
                              if (user != null)
                                Text(
                                  user.fullName ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (user != null)
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: kombuGreen,
                      unselectedLabelColor: cafeNoir.withOpacity(0.5),
                      indicatorColor: kombuGreen,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'THÔNG TIN'),
                        Tab(text: 'MẬT KHẨU'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _EditProfileTab(userId: widget.userId, user: user),
                _ChangePasswordTab(userId: widget.userId),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _ProfileAvatar extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback? onPickImage;
  final String? selectedImagePath;

  const _ProfileAvatar({this.user, this.onPickImage, this.selectedImagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundColor: boneColor,
            child: _buildImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (selectedImagePath != null) {
      return Image.file(File(selectedImagePath!), fit: BoxFit.cover, width: 90, height: 90);
    }
    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      return Image.network(
        ApiConstants.getFullImageUrl(user!.avatarUrl),
        fit: BoxFit.cover,
        width: 90,
        height: 90,
        errorBuilder: (context, error, stackTrace) => _buildLetterAvatar(),
      );
    }
    return _buildLetterAvatar();
  }

  Widget _buildLetterAvatar() {
    return Center(
      child: Text(
        (user?.fullName?.isNotEmpty == true ? user!.fullName![0] : '?').toUpperCase(),
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: kombuGreen),
      ),
    );
  }
}

class _EditProfileTab extends StatefulWidget {
  final String userId;
  final UserEntity? user;
  const _EditProfileTab({required this.userId, this.user});
  @override
  State<_EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<_EditProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: widget.user?.phoneNumber ?? '');
  }

  @override
  void didUpdateWidget(_EditProfileTab old) {
    super.didUpdateWidget(old);
    if (widget.user != old.user && widget.user != null) {
      _nameCtrl.text = widget.user!.fullName ?? '';
      _phoneCtrl.text = widget.user!.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  void _save(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<UserBloc>().add(UpdateUserEvent(
          id: widget.userId,
          request: UpdateUserRequest(
            fullName: _nameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            avatarPath: _selectedImagePath,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserBloc>().state is UserLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Avatar Update Section
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: kombuGreen.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _ProfileAvatar(
                      user: widget.user,
                      selectedImagePath: _selectedImagePath,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ảnh đại diện',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thay đổi ảnh cá nhân của bạn',
                            style: TextStyle(color: cafeNoir.withOpacity(0.6), fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('CHỌN ẢNH'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kombuGreen,
                              side: const BorderSide(color: kombuGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Form Section
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: kombuGreen.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Thông tin cá nhân',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kombuGreen),
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      controller: _nameCtrl,
                      label: 'Họ và tên',
                      icon: Icons.person_outline,
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _phoneCtrl,
                      label: 'Số điện thoại',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phoneNumber,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _save(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kombuGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('LƯU THAY ĐỔI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kombuGreen),
        labelStyle: TextStyle(color: cafeNoir.withOpacity(0.6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: boneColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: boneColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kombuGreen, width: 2)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }
}

class _ChangePasswordTab extends StatefulWidget {
  final String userId;
  const _ChangePasswordTab({required this.userId});
  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureOld = true, _obscureNew = true, _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<UserBloc>().add(ChangePasswordEvent(
          id: widget.userId,
          request: ChangePasswordRequest(oldPassword: _oldPassCtrl.text, newPassword: _newPassCtrl.text),
        ));
    _oldPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserBloc>().state is UserLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: kombuGreen.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kombuGreen),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bảo mật tài khoản của bạn bằng mật khẩu mạnh',
                  style: TextStyle(color: cafeNoir.withOpacity(0.6), fontSize: 13),
                ),
                const SizedBox(height: 32),
                _buildPasswordField(
                  controller: _oldPassCtrl,
                  label: 'Mật khẩu cũ',
                  obscure: _obscureOld,
                  onToggle: () => setState(() => _obscureOld = !_obscureOld),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _newPassCtrl,
                  label: 'Mật khẩu mới',
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmCtrl,
                  label: 'Xác nhận mật khẩu mới',
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                    if (v != _newPassCtrl.text) return 'Mật khẩu xác nhận không khớp';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kombuGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('CẬP NHẬT MẬT KHẨU', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ?? Validators.password,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: kombuGreen),
        labelStyle: TextStyle(color: cafeNoir.withOpacity(0.6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: boneColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: boneColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kombuGreen, width: 2)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: kombuGreen.withOpacity(0.7)),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
