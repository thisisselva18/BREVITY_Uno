part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final ChatWindow chatWindow;
  final bool shouldAnimateLatest;
  
  ChatLoaded({
    required this.chatWindow,
    this.shouldAnimateLatest = false,
  });
}

class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}

class MessageSending extends ChatState {
  final ChatWindow chatWindow;
  MessageSending({required this.chatWindow});
}