import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// function
import 'package:flutter_android_chatapp/function/message.dart';

class ChatInputField extends ConsumerStatefulWidget {
  final String roomId;
  const ChatInputField({
    super.key,
    required this.roomId
  });

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final TextEditingController _textController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Emoji button
          GestureDetector(
            onTap: () {
              // Handle emoji button tap
            },
            child: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 11.5),

          // Text input field
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFADAEBC),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(bottom: 10),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11.5),

          // Send button
          GestureDetector(
            onTap: () async{
              // Handle send button tap
              if (_textController.text.isNotEmpty) {
                // Send message logic would go here
                final send = await sendMessage(ref, _textController.text, widget.roomId);
                if (!send.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(send.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                _textController.clear();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}