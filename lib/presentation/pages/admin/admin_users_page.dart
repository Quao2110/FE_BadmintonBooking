import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../data/models/user/update_user_request.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/loading_widget.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc.create()..add(const GetAllUsersEvent()),
      child: const _AdminUsersView(),
    );
  }
}

class _AdminUsersView extends StatefulWidget {
  const _AdminUsersView();
  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), tooltip: 'Làm mới', onPressed: () => context.read<UserBloc>().add(const GetAllUsersEvent()))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(hintText: 'Tìm theo email, tên...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
            ),
          ),
          Expanded(
            child: BlocConsumer<UserBloc, UserState>(
              listener: (context, state) {
                if (state is UserActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Text(state.message)]), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
                  context.read<UserBloc>().add(const GetAllUsersEvent());
                } else if (state is UserError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))));
                }
              },
              builder: (context, state) {
                if (state is UserLoading) return const LoadingWidget(message: 'Đang tải danh sách...');
                if (state is UserError) return EmptyWidget(message: state.message, icon: Icons.error_outline, actionLabel: 'Thử lại', onAction: () => context.read<UserBloc>().add(const GetAllUsersEvent()));
                List<UserEntity> users = [];
                if (state is UserListLoaded) users = state.users;
                final filtered = _search.isEmpty ? users : users.where((u) => u.email.toLowerCase().contains(_search) || (u.fullName?.toLowerCase().contains(_search) ?? false)).toList();
                if (filtered.isEmpty) return const EmptyWidget(message: 'Không tìm thấy người dùng nào', icon: Icons.people_outline);
                return RefreshIndicator(
                  onRefresh: () async => context.read<UserBloc>().add(const GetAllUsersEvent()),
                  child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), itemCount: filtered.length, separatorBuilder: (_, __) => const SizedBox(height: 6), itemBuilder: (context, index) => _UserTile(user: filtered[index])),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserEntity user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive = user.isActive;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.indigo.shade50 : Colors.grey.shade200,
          backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              ? NetworkImage(ApiConstants.getFullImageUrl(user.avatarUrl))
              : null,
          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
              ? Text((user.fullName?.isNotEmpty == true ? user.fullName![0] : user.email[0]).toUpperCase(), style: TextStyle(color: isActive ? Colors.indigo : Colors.grey, fontWeight: FontWeight.bold))
              : null,
        ),
        title: Row(children: [
          Expanded(child: Text(user.fullName ?? '(Chưa đặt tên)', style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          _RoleBadge(role: user.role),
        ]),
// ...
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 2),
          Text(user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          if (user.phoneNumber != null) Text(user.phoneNumber!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          Row(children: [
            Icon(isActive ? Icons.check_circle : Icons.block, size: 12, color: isActive ? Colors.green : Colors.red),
            const SizedBox(width: 4),
            Text(isActive ? 'Hoạt động' : 'Đã khoá', style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.red)),
            if (user.isTwoFactorEnabled) ...[const SizedBox(width: 8), const Icon(Icons.lock, size: 12, color: Colors.orange), const SizedBox(width: 2), const Text('2FA', style: TextStyle(fontSize: 11, color: Colors.orange))],
          ]),
        ]),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (value) { if (value == 'edit') _showEditDialog(context, user); if (value == 'delete') _showDeleteDialog(context, user); },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, color: Colors.blue, size: 20), SizedBox(width: 8), Text('Chỉnh sửa')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 20), SizedBox(width: 8), Text('Xoá', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserEntity user) {
    showDialog(context: context, builder: (ctx) => _EditUserDialog(user: user, bloc: context.read<UserBloc>()));
  }

  void _showDeleteDialog(BuildContext context, UserEntity user) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Xác nhận xoá'),
      content: Text('Bạn có chắc muốn xoá tài khoản\n"${user.fullName ?? user.email}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () { Navigator.pop(ctx); context.read<UserBloc>().add(DeleteUserEvent(user.id)); }, child: const Text('Xoá')),
      ],
    ));
  }
}

class _EditUserDialog extends StatefulWidget {
  final UserEntity user;
  final UserBloc bloc;
  const _EditUserDialog({required this.user, required this.bloc});
  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  String? _selectedImagePath;

  @override
  void initState() { super.initState(); _nameCtrl = TextEditingController(text: widget.user.fullName ?? ''); _phoneCtrl = TextEditingController(text: widget.user.phoneNumber ?? ''); }
  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImagePath = image.path);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Chỉnh sửa: ${widget.user.email}'),
      content: SingleChildScrollView(
        child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.indigo.shade50,
                  backgroundImage: _selectedImagePath != null
                      ? FileImage(File(_selectedImagePath!))
                      : (widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty
                          ? NetworkImage(ApiConstants.getFullImageUrl(widget.user.avatarUrl))
                          : null),
                  child: (_selectedImagePath == null && (widget.user.avatarUrl == null || widget.user.avatarUrl!.isEmpty))
                      ? Text((widget.user.fullName?.isNotEmpty == true ? widget.user.fullName![0] : widget.user.email[0]).toUpperCase(), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.indigo))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _nameCtrl, validator: Validators.fullName, decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(controller: _phoneCtrl, validator: Validators.phoneNumber, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder())),
        ])),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), onPressed: () { if (!_formKey.currentState!.validate()) return; Navigator.pop(context); widget.bloc.add(UpdateUserEvent(id: widget.user.id, request: UpdateUserRequest(fullName: _nameCtrl.text.trim(), phoneNumber: _phoneCtrl.text.trim(), avatarPath: _selectedImagePath))); }, child: const Text('Lưu')),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String? role;
  const _RoleBadge({this.role});
  @override
  Widget build(BuildContext context) {
    final isAdmin = role?.toLowerCase() == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: isAdmin ? Colors.amber.shade100 : Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Text(role ?? 'Customer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isAdmin ? Colors.amber.shade800 : Colors.blue.shade700)),
    );
  }
}
