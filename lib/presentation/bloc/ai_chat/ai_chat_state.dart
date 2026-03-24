import 'package:equatable/equatable.dart';

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

abstract class AiChatState extends Equatable {
  const AiChatState();
  @override
  List<Object?> get props => [];
}

class AiChatInitial extends AiChatState {}

class AiChatLoading extends AiChatState {
  final List<AiChatMessage> messages;
  const AiChatLoading(this.messages);
  @override
  List<Object?> get props => [messages];
}

class AiChatLoaded extends AiChatState {
  final List<AiChatMessage> messages;
  const AiChatLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class AiChatError extends AiChatState {
  final String message;
  final List<AiChatMessage> messages;
  const AiChatError(this.message, this.messages);
  @override
  List<Object?> get props => [message, messages];
}
