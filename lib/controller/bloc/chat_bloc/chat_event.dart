part of 'chat_bloc.dart';

abstract class ChatEvent {}

class InitializeChat extends ChatEvent {
  final String articleData;
  InitializeChat({required this.articleData});
}

class AddMessage extends ChatEvent {
  final String message;
  final String response;
  AddMessage({required this.message, required this.response});
}

class ClearChat extends ChatEvent {}