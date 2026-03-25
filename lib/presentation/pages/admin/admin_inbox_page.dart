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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return _buildMobileLayout();
        }
        return _buildDesktopLayout();
      },
    );
  }

  // ─── Mobile: Full-screen list, tap -> full-screen chat ─────────────────────

  Widget _buildMobileLayout() {
    // If a room is selected, show chat panel with back button
    if (_selectedRoom != null) {
      return Column(
        children: [
          // Header with back
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => setState(() => _selectedRoom = null),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 16,
                  child: Text(
                    (_selectedRoom!.userName?.isNotEmpty == true
                            ? _selectedRoom!.userName![0]
                            : '?')
                        .toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedRoom!.userName ?? 'User',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Chat area
          Expanded(
            child: _ChatArea(
              room: _selectedRoom!,
              scrollController: _scrollController,
            ),
          ),
          // Reply bar
          _ReplyBar(
            room: _selectedRoom!,
            controller: _replyController,
            onSend: () => _sendReply(context),
          ),
        ],
      );
    }

    // Show room list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: const Text(
            'Hop thu CSKH',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        Expanded(
          child: _ChatRoomList(
            selectedRoom: _selectedRoom,
            onRoomSelected: (room) => setState(() => _selectedRoom = room),
          ),
        ),
      ],
    );
  }

  // ─── Desktop: Side-by-side layout ──────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hop thu CSKH',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  // Room list
                  SizedBox(
                    width: 280,
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
                                Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Chon mot cuoc hoi thoai', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Chat header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: AppColors.border)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      radius: 16,
                                      child: Text(
                                        (_selectedRoom!.userName?.isNotEmpty == true
                                                ? _selectedRoom!.userName![0]
                                                : '?')
                                            .toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _selectedRoom!.userName ?? 'User',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: _ChatArea(
                                  room: _selectedRoom!,
                                  scrollController: _scrollController,
                                ),
                              ),
                              _ReplyBar(
                                room: _selectedRoom!,
                                controller: _replyController,
                                onSend: () => _sendReply(context),
                              ),
                            ],
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
                color: Colors.grey.withOpacity(0.05),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tim kiem...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => context.read<InboxBloc>().add(LoadAdminChatRoomsEvent()),
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
                      child: Text('Chua co tin nhan', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.separated(
                    itemCount: state.rooms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final room = state.rooms[index];
                      final isSelected = selectedRoom?.chatRoomId == room.chatRoomId;
                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withOpacity(0.08),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (room.userName?.isNotEmpty == true ? room.userName![0] : '?').toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        title: Text(
                          room.userName ?? 'User ${room.userId.substring(0, 6)}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          room.lastMessage ?? 'Chua co tin nhan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: room.lastMessageAt != null
                            ? Text(
                                _formatTime(room.lastMessageAt!),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              )
                            : null,
                        onTap: () => onRoomSelected(room),
                      );
                    },
                  );
                }
                return const Center(
                  child: Text('Dang tai...', style: TextStyle(color: Colors.grey)),
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

// ─── Chat Area ────────────────────────────────────────────────────────────────

class _ChatArea extends StatelessWidget {
  final ChatRoomEntity room;
  final ScrollController scrollController;

  const _ChatArea({required this.room, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Hoi thoai voi ${room.userName ?? 'khach hang'}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
          if (room.lastMessage != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(room.lastMessage!, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Reply Bar ────────────────────────────────────────────────────────────────

class _ReplyBar extends StatelessWidget {
  final ChatRoomEntity room;
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ReplyBar({
    required this.room,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxBloc, InboxState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Nhan tin...',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 36,
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: state is InboxLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 16),
                    onPressed: state is InboxLoading ? null : onSend,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
