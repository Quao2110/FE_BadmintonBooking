import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/ai_chat_service.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiChatService _aiChatService;
  final List<AiChatMessage> _messages = [];

  AiChatBloc({AiChatService? aiChatService})
      : _aiChatService = aiChatService ?? AiChatService(),
        super(AiChatInitial()) {
    on<LoadAiContextEvent>(_onLoadContext);
    on<SendAiMessageEvent>(_onSendMessage);
    on<ResetAiChatEvent>(_onResetChat);
  }

  Future<void> _onLoadContext(
    LoadAiContextEvent event,
    Emitter<AiChatState> emit,
  ) async {
    // Không truyền data mẫu — test Gemini trực tiếp
    _aiChatService.updateSystemInstruction(
      shopData: '',
      courtsData: '',
      servicesData: '',
    );
  }

  Future<void> _onSendMessage(
    SendAiMessageEvent event,
    Emitter<AiChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    _messages.add(AiChatMessage(text: event.message, isUser: true));
    emit(AiChatLoading(List.from(_messages)));

    try {
      final response = await _aiChatService.sendMessage(event.message);
      _messages.add(AiChatMessage(
        text: response ?? 'Không nhận được phản hồi.',
        isUser: false,
      ));
      emit(AiChatLoaded(List.from(_messages)));
    } catch (e) {
      _messages.add(AiChatMessage(
        text: 'Có lỗi xảy ra. Vui lòng thử lại.',
        isUser: false,
      ));
      emit(AiChatError(e.toString(), List.from(_messages)));
    }
  }

  void _onResetChat(ResetAiChatEvent event, Emitter<AiChatState> emit) {
    _aiChatService.resetChat();
    _messages.clear();
    emit(AiChatInitial());
    add(LoadAiContextEvent());
  }
}
