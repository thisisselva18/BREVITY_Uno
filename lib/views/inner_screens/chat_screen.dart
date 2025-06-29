import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:newsai/controller/bloc/chat_bloc/chat_bloc.dart';
import 'package:newsai/models/article_model.dart';
import 'package:newsai/views/common_widgets/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final Article article;
  const ChatScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ChatBloc()..add(InitializeChat(articleData: article.title)),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // Set back button color to white
          title: const Text(
            'NewsAI Assistant',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () => context.read<ChatBloc>().add(ClearChat()),
            ),
          ],
        ),
        body: Column(
          children: [
            // Initial Article Card
            _buildArticleCard(context),
            Expanded(child: _buildMessageList()),
            _buildInputField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 35, 35, 35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        article.title,
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoaded) {
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: state.chatWindow.conversations.length,
            itemBuilder: (context, index) {
              final message =
                  state.chatWindow.conversations.reversed.toList()[index];
              return MessageBubble(
                message: message.request,
                response: message.response,
                isUser: true,
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildInputField(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask about this news...',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color.fromARGB(255, 45, 45, 45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const Gap(12),
          CircleAvatar(
            backgroundColor: const Color.fromRGBO(68, 138, 255, 1),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                final message = controller.text;
                if (message.isNotEmpty) {
                  context.read<ChatBloc>().add(
                    AddMessage(
                      message: message,
                      response: _generateDummyResponse(message), // Temporary
                    ),
                  );
                  controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Temporary dummy response generator
  String _generateDummyResponse(String input) {
    return "This is a placeholder response for: '$input'. (AI response functionality will be added later)";
  }
}
