import 'package:cloud_firestore/cloud_firestore.dart';

//povider
import 'package:flutter_android_chatapp/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Message {
  final String id;
  final String message;
  final String sender;
  final String createdAt;

  Message({
    required this.id,
    required this.message,
    required this.sender,
    required this.createdAt,
  });
}

class SendMessageStatus {
  final bool success;
  final String? error;

  SendMessageStatus({
    required this.success,
    this.error,
  });
  
}

Future<SendMessageStatus> sendMessage(WidgetRef ref, String message, String roomId) async {

  if (message.trim().isEmpty) {
    return SendMessageStatus(success: false, error: 'Please enter message');
  }

  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return  SendMessageStatus(success: false, error: 'Please login first');
  }

  //get datetime now in timezone asia/bangkok
  final now = DateTime.now().toUtc().add(const Duration(hours: 7));
  //format datetime to string
  final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';



  final messageData = {
    'room_id': 'default',
    'message': message,
    'sender': user.uid,
    'timestamp': formattedDate,
  };

  await FirebaseFirestore.instance.collection('messages').add(messageData);

  return SendMessageStatus(success: true);
}