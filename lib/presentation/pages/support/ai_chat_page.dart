import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../bloc/ai_chat/ai_chat_bloc.dart';
import '../../bloc/ai_chat/ai_chat_event.dart';
import '../../bloc/ai_chat/ai_chat_state.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(BuildContext context) {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    context.read<AiChatBloc>().add(SendAiMessageEvent(text));
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneColor,
      appBar: AppBar(
        backgroundColor: kombuGreen,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trợ lý AI Cầu Lông',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Luôn sẵn sàng hỗ trợ bạn',
                style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<AiChatBloc>().add(ResetAiChatEvent()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới hội thoại',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiChatBloc, AiChatState>(
              listener: (_, state) {
                if (state is AiChatLoaded ||
                    state is AiChatLoading ||
                    state is AiChatError) {
                  _scrollToBottom();
                }
              },
              builder: (_, state) {
                List<AiChatMessage> messages = [];
                bool isLoading = false;

                if (state is AiChatInitial) return _buildWelcome(context);
                if (state is AiChatLoading) {
                  messages = state.messages;
                  isLoading = true;
                } else if (state is AiChatLoaded) {
                  messages = state.messages;
                } else if (state is AiChatError) {
                  messages = state.messages;
                }

                if (messages.isEmpty && !isLoading) return _buildWelcome(context);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i < messages.length) {
                      return _Bubble(message: messages[i]);
                    }
                    return _buildTyping();
                  },
                );
              },
            ),
          ),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined, size: 80, color: kombuGreen),
            const SizedBox(height: 24),
            const Text('Chào mừng bạn!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kombuGreen)),
            const SizedBox(height: 12),
            const Text(
              'Tôi là trợ lý AI, có thể giúp bạn tìm sân, xem giá hoặc hướng dẫn đặt lịch.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cafeNoir),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                    text: 'Giá sân thế nào?',
                    onTap: () => _sendSuggestion(context, 'Giá sân hiện tại thế nào?')),
                _Chip(
                    text: 'Cách đặt sân?',
                    onTap: () => _sendSuggestion(context, 'Hướng dẫn tôi cách đặt sân.')),
                _Chip(
                    text: 'Giờ mở cửa?',
                    onTap: () => _sendSuggestion(context, 'Sân mở cửa từ mấy giờ đến mấy giờ?')),
                _Chip(
                    text: 'Rủ bạn gái đi đánh',
                    onTap: () => _sendSuggestion(context, 'Rủ bạn gái đi đánh cầu lông cần gì?')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendSuggestion(BuildContext context, String text) {
    _msgController.text = text;
    Future.delayed(const Duration(milliseconds: 100), () => _send(context));
  }

  Widget _buildTyping() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: boneColor),
        ),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: kombuGreen),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _send(context),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: kombuGreen,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _send(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final AiChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? kombuGreen : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
              border: isUser ? null : Border.all(color: boneColor),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : cafeNoir,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: const TextStyle(fontSize: 10, color: cafeNoir),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _Chip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      labelStyle: const TextStyle(fontSize: 12, color: kombuGreen),
      backgroundColor: kombuGreen.withOpacity(0.05),
      side: const BorderSide(color: kombuGreen, width: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}
