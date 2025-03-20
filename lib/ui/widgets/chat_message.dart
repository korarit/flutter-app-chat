import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String? message;
  final String time;
  final bool isReceived;
  final String? senderImage;
  final String? imageUrl;

  const MessageBubble({
    super.key,
    this.message,
    required this.time,
    required this.isReceived,
    this.senderImage,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isReceived ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender image (only for received messages)
        if (isReceived && senderImage != null) ...[
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(senderImage!),
          ),
          const SizedBox(width: 8),
        ],

        // Message content and timestamp
        Column(
          crossAxisAlignment: isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // Message bubble
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: imageUrl != null
                ? const EdgeInsets.all(8)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isReceived ? Colors.white : const Color(0xFF3B82F6),
                borderRadius: isReceived
                    ? const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        topLeft: Radius.circular(2),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        topRight: Radius.circular(2),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      message ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isReceived ? Colors.black : Colors.white,
                      ),
                    ),
            ),

            // Timestamp
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}