import 'package:brevity/models/conversation_model.dart';

class ChatWindow {
  final String articleData;
  final List<Conversation> conversations;
  final DateTime createdAt;

  ChatWindow({
    required this.articleData,
    required this.conversations,
    required this.createdAt,
  });

  ChatWindow copyWith({
    String? articleData,
    List<Conversation>? conversations,
  }) {
    return ChatWindow(
      articleData: articleData ?? this.articleData,
      conversations: conversations ?? this.conversations,
      createdAt: createdAt,
    );
  }
}