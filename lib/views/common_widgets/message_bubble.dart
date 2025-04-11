import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String response;
  final bool isUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.response,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // User Message
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser 
                ? const Color.fromRGBO(68, 138, 255, 1)
                : const Color.fromARGB(255, 45, 45, 45),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isUser 
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
              bottomRight: !isUser 
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
            ),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        // AI Response
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 35, 35, 35),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: !isUser 
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
              bottomRight: isUser 
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
            ),
          ),
          child: Text(
            response,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.4
            ),
          ),
        ),
        const SizedBox(height: 16)
      ],
    );
  }
}