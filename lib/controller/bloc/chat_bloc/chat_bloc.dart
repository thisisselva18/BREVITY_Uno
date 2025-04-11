import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsai/models/conversation_model.dart';
import 'package:newsai/models/chat_window_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<InitializeChat>(_onInitializeChat);
    on<AddMessage>(_onAddMessage);
    on<ClearChat>(_onClearChat);
  }

  void _onInitializeChat(InitializeChat event, Emitter<ChatState> emit) {
    emit(ChatLoaded(
      chatWindow: ChatWindow(
        articleData: event.articleData,
        conversations: [],
        createdAt: DateTime.now(),
      ),
    ));
  }

  void _onAddMessage(AddMessage event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedConversations = [
        ...currentState.chatWindow.conversations,
        Conversation(
          request: event.message,
          response: event.response,
          timestamp: DateTime.now(),
        )
      ];

      emit(ChatLoaded(
        chatWindow: currentState.chatWindow.copyWith(
          conversations: updatedConversations,
        ),
      ));
    }
  }

  void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
    emit(ChatInitial());
  }
}