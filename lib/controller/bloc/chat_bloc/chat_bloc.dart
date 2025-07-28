import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brevity/models/conversation_model.dart';
import 'package:brevity/models/chat_window_model.dart';
import 'package:brevity/models/article_model.dart';
import 'package:brevity/controller/services/gemini_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiFlashService _geminiService;

  ChatBloc({required GeminiFlashService geminiService})
      : _geminiService = geminiService,
        super(ChatInitial()) {
    on<InitializeChat>(_onInitializeChat);
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
  }

  void _onInitializeChat(InitializeChat event, Emitter<ChatState> emit) {
    emit(ChatLoaded(
      chatWindow: ChatWindow(
        article: event.article,
        conversations: [],
        createdAt: DateTime.now(),
      ),
    ));
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
        
    // Show message sending state
    emit(MessageSending(chatWindow: currentState.chatWindow));

    try {
      // Build full context with conversation history
      final prompt = _buildContextualPrompt(event.chatWindow, event.message);
            
      // Get response from Gemini
      final response = await _geminiService.getFreeResponse(prompt);

      // Create new conversation
      final newConversation = Conversation(
        request: event.message,
        response: response,
        timestamp: DateTime.now(),
      );

      // Add conversation to chat window
      final updatedConversations = [
        ...currentState.chatWindow.conversations,
        newConversation
      ];

      // Emit with typewriter animation flag
      emit(ChatLoaded(
        chatWindow: currentState.chatWindow.copyWith(
          conversations: updatedConversations,
        ),
        shouldAnimateLatest: true, // Flag to animate the latest message
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to get response: ${e.toString()}'));
            
      // Return to previous state after error
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) {
          emit(ChatLoaded(
            chatWindow: currentState.chatWindow,
            shouldAnimateLatest: false,
          ));
        }
      });
    }
  }

  void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
    emit(ChatInitial());
  }

  String _buildContextualPrompt(ChatWindow chatWindow, String userQuery) {
    final article = chatWindow.article;
    final history = chatWindow.conversations;
        
    String prompt = """You are an intelligent news companion that engages readers in meaningful discussions about articles. 

ARTICLE CONTEXT:
Title: ${article.title}
Author: ${article.author} | Source: ${article.sourceName}
Summary: ${article.description}
Content: ${article.content}

GUIDELINES:
• Answer questions accurately based solely on the article content
• Match the conversational tone and style from our chat history
• Politely redirect off-topic questions back to the article
• Keep responses engaging by ending with thoughtful follow-up questions
• Maintain a natural, human-like conversational flow""";

    if (history.isNotEmpty) {
      prompt += "\n\nCONVERSATION HISTORY:\n";
      for (var conv in history) {
        prompt += "You: ${conv.response}\nReader: ${conv.request}\n";
      }
    }

    prompt += "\n\nReader's Question: $userQuery\n\nYour Response:";
        
    return prompt;
  }
}