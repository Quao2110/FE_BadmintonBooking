import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/inbox/inbox_usecases.dart';
import '../../../data/repositories/inbox_repository_impl.dart';
import 'inbox_event.dart';
import 'inbox_state.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final GetAdminChatRoomsUseCase _getAdminChatRooms;
  final AdminReplyUseCase _adminReply;
  final SendMessageUseCase _sendMessage;
  final GetMyMessagesUseCase _getMyMessages;

  InboxBloc({
    GetAdminChatRoomsUseCase? getAdminChatRooms,
    AdminReplyUseCase? adminReply,
    SendMessageUseCase? sendMessage,
    GetMyMessagesUseCase? getMyMessages,
  })  : _getAdminChatRooms = getAdminChatRooms ??
            GetAdminChatRoomsUseCase(InboxRepository()),
        _adminReply = adminReply ?? AdminReplyUseCase(InboxRepository()),
        _sendMessage = sendMessage ?? SendMessageUseCase(InboxRepository()),
        _getMyMessages =
            getMyMessages ?? GetMyMessagesUseCase(InboxRepository()),
        super(InboxInitial()) {
    on<LoadAdminChatRoomsEvent>(_onLoadAdminChatRooms);
    on<AdminReplyEvent>(_onAdminReply);
    on<SendMessageEvent>(_onSendMessage);
    on<LoadMyMessagesEvent>(_onLoadMyMessages);
  }

  Future<void> _onLoadAdminChatRooms(
      LoadAdminChatRoomsEvent event, Emitter<InboxState> emit) async {
    emit(InboxLoading());
    try {
      final rooms = await _getAdminChatRooms();
      emit(AdminChatRoomsLoaded(rooms));
    } catch (e) {
      emit(InboxError(e.toString()));
    }
  }

  Future<void> _onAdminReply(
      AdminReplyEvent event, Emitter<InboxState> emit) async {
    try {
      await _adminReply(
        chatRoomId: event.chatRoomId,
        messageText: event.messageText,
        imageUrl: event.imageUrl,
      );
      emit(InboxMessageSent());
      // Reload phòng chat sau khi reply
      final rooms = await _getAdminChatRooms();
      emit(AdminChatRoomsLoaded(rooms));
    } catch (e) {
      emit(InboxError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<InboxState> emit) async {
    try {
      await _sendMessage(
          messageText: event.messageText, imageUrl: event.imageUrl);
      emit(InboxMessageSent());
      // Reload messages
      final messages = await _getMyMessages();
      emit(MyMessagesLoaded(messages));
    } catch (e) {
      emit(InboxError(e.toString()));
    }
  }

  Future<void> _onLoadMyMessages(
      LoadMyMessagesEvent event, Emitter<InboxState> emit) async {
    emit(InboxLoading());
    try {
      final messages = await _getMyMessages();
      emit(MyMessagesLoaded(messages));
    } catch (e) {
      emit(InboxError(e.toString()));
    }
  }
}
