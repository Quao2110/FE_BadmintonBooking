import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/inbox_entity.dart';
import '../../../core/theme/colors.dart';
import '../../../presentation/bloc/inbox/inbox_bloc.dart';
import '../../../presentation/bloc/inbox/inbox_event.dart';
import '../../../presentation/bloc/inbox/inbox_state.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';

class AdminInboxPage extends StatelessWidget {
  final User user;

  const AdminInboxPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InboxBloc()..add(LoadAdminChatRoomsEvent()),
      child: AdminLayout(
        user: user,
        currentRoute: AppRoutes.adminInbox,
        child: _InboxBody(adminUser: user),
      ),
    );
  }
}

class _InboxBody extends StatefulWidget {
  final User adminUser;
  const _InboxBody({required this.adminUser});

  @override
  State<_InboxBody> createState() => _InboxBodyState();
}

class _InboxBodyState extends State<_InboxBody> {
  ChatRoomEntity? _selectedRoom;
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendReply(BuildContext context) {
    final text = _replyController.text.trim();
    if (text.isEmpty || _selectedRoom == null) return;
    context.read<InboxBloc>().add(AdminReplyEvent(
          chatRoomId: _selectedRoom!.chatRoomId,
          messageText: text,
        ));
    _replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hộp thư CSKH',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Sidebar – danh sách phòng chat
                  SizedBox(
                    width: 300,
                    child: _ChatRoomList(
                      selectedRoom: _selectedRoom,
                      onRoomSelected: (room) => setState(() => _selectedRoom = room),
                    ),
                  ),
                  VerticalDivider(width: 1, color: AppColors.border),
                  // Chat panel
                  Expanded(
                    child: _selectedRoom == null
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  'Chọn một cuộc hội thoại để xem tin nhắn',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : _ChatPanel(
                            room: _selectedRoom!,
                            replyController: _replyController,
                            scrollController: _scrollController,
                            onSend: () => _sendReply(context),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Room List ────────────────────────────────────────────────────────────

class _ChatRoomList extends StatelessWidget {
  final ChatRoomEntity? selectedRoom;
  final ValueChanged<ChatRoomEntity> onRoomSelected;

  const _ChatRoomList({
    required this.selectedRoom,
    required this.onRoomSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InboxBloc, InboxState>(
      listener: (context, state) {
        if (state is InboxError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
                color: Colors.grey.withValues(alpha: 0.05),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => context.read<InboxBloc>().add(LoadAdminChatRoomsEvent()),
                  tooltip: 'Làm mới',
                ),
              ]),
            ),
            // Room list
            Expanded(
              child: Builder(builder: (_) {
                if (state is InboxLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminChatRoomsLoaded) {
                  if (state.rooms.isEmpty) {
                    return const Center(
                      child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.separated(
                    itemCount: state.rooms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final room = state.rooms[index];
                      final isSelected = selectedRoom?.chatRoomId == room.chatRoomId;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (room.userName?.isNotEmpty == true
                                    ? room.userName![0]
                                    : '?')
                                .toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          room.userName ?? 'User ${room.userId.substring(0, 6)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          room.lastMessage ?? 'Chưa có tin nhắn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: room.lastMessageAt != null
                            ? Text(
                                _formatTime(room.lastMessageAt!),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              )
                            : null,
                        onTap: () => onRoomSelected(room),
                      );
                    },
                  );
                }
                // Initial / after send
                return const Center(
                  child: Text('Đang tải...', style: TextStyle(color: Colors.grey)),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inHours < 24 && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}

// ─── Chat Panel ───────────────────────────────────────────────────────────────

class _ChatPanel extends StatelessWidget {
  final ChatRoomEntity room;
  final TextEditingController replyController;
  final ScrollController scrollController;
  final VoidCallback onSend;

  const _ChatPanel({
    required this.room,
    required this.replyController,
    required this.scrollController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InboxBloc, InboxState>(
      listener: (context, state) {
        if (state is InboxMessageSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
                color: Colors.grey.withValues(alpha: 0.03),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 18,
                    child: Text(
                      (room.userName?.isNotEmpty == true ? room.userName![0] : '?').toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.userName ?? 'User',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text('Khách hàng', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            // Vùng chat – hiển thị placeholder (API GET messages riêng per room chưa có endpoint)
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Cuộc hội thoại với ${room.userName ?? 'khách hàng'}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (room.lastMessage != null) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(room.lastMessage!, style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Thanh reply
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      decoration: InputDecoration(
                        hintText: 'Nhập câu trả lời cho ${room.userName ?? 'khách'}...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: state is InboxLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: state is InboxLoading ? null : onSend,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
