import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../../data/models/user/update_user_request.dart';
import '../../../data/models/user/change_password_request.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/api_constants.dart';

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
  void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(icon: Icon(Icons.person), text: 'Thông tin'), Tab(icon: Icon(Icons.lock), text: 'Mật khẩu')],
        ),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Text(state.message)]), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
            if (state.updatedUser != null) context.read<UserBloc>().add(GetUserByIdEvent(widget.userId));
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
          }
        },
        builder: (context, state) {
          if (state is UserLoading) return const Center(child: CircularProgressIndicator());
          if (state is UserError && state is! UserActionSuccess) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.read<UserBloc>().add(GetUserByIdEvent(widget.userId)), child: const Text('Thử lại')),
            ]));
          }
          final user = state is UserLoaded ? state.user : (state is UserActionSuccess ? state.updatedUser : null);
          return TabBarView(controller: _tabController, children: [_EditProfileTab(userId: widget.userId, user: user), _ChangePasswordTab(userId: widget.userId)]);
        },
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
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

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
    final user = widget.user;
    final isLoading = context.watch<UserBloc>().state is UserLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: _selectedImagePath != null
                        ? FileImage(File(_selectedImagePath!))
                        : (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                            ? NetworkImage(ApiConstants.getFullImageUrl(user.avatarUrl))
                            : null),
                    child: (_selectedImagePath == null && (user?.avatarUrl == null || user!.avatarUrl!.isEmpty))
                        ? Text(
                            (user?.fullName?.isNotEmpty == true ? user!.fullName![0] : '?').toUpperCase(),
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (user != null) ...[
              Center(child: Text(user.email, style: TextStyle(color: Colors.grey.shade600))),
              Center(child: Chip(label: Text(user.role ?? 'Customer'), backgroundColor: Colors.blue.shade50)),
            ],
            const SizedBox(height: 24),
            TextFormField(controller: _nameCtrl, validator: Validators.fullName, decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, validator: Validators.phoneNumber, decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(height: 48, child: ElevatedButton(onPressed: isLoading ? null : () => _save(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('LƯU THAY ĐỔI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
          ],
        ),
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
  void dispose() { _oldPassCtrl.dispose(); _newPassCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<UserBloc>().add(ChangePasswordEvent(id: widget.userId, request: ChangePasswordRequest(oldPassword: _oldPassCtrl.text, newPassword: _newPassCtrl.text)));
    _oldPassCtrl.clear(); _newPassCtrl.clear(); _confirmCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserBloc>().state is UserLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextFormField(controller: _oldPassCtrl, obscureText: _obscureOld, validator: Validators.password, decoration: InputDecoration(labelText: 'Mật khẩu cũ', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureOld = !_obscureOld)))),
            const SizedBox(height: 16),
            TextFormField(controller: _newPassCtrl, obscureText: _obscureNew, validator: Validators.password, decoration: InputDecoration(labelText: 'Mật khẩu mới', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureNew = !_obscureNew)))),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl, obscureText: _obscureConfirm,
              validator: (v) { if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu'; if (v != _newPassCtrl.text) return 'Mật khẩu xác nhận không khớp'; return null; },
              decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm))),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 48, child: ElevatedButton(onPressed: isLoading ? null : () => _submit(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('ĐỔI MẬT KHẨU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }
}
