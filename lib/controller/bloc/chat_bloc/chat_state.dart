part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final ChatWindow chatWindow;
  ChatLoaded({required this.chatWindow});
}

class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}