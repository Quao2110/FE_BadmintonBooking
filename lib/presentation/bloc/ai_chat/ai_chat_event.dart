import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();
  @override
  List<Object> get props => [];
}

class SendAiMessageEvent extends AiChatEvent {
  final String message;
  const SendAiMessageEvent(this.message);
  @override
  List<Object> get props => [message];
}

class LoadAiContextEvent extends AiChatEvent {}

class ResetAiChatEvent extends AiChatEvent {}
