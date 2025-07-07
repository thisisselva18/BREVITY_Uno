part of 'chat_bloc.dart';

abstract class ChatEvent {}

class InitializeChat extends ChatEvent {
  final Article article;
  InitializeChat({required this.article});
}

class SendMessage extends ChatEvent {
  final String message;
  final ChatWindow chatWindow;
  SendMessage({required this.message, required this.chatWindow});
}

class ClearChat extends ChatEvent {}
