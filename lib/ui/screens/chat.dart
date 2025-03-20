import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_message.dart';
import '../../provider/auth_provider.dart';

// Provider สำหรับ Firestore และ Auth
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// StreamProvider สำหรับดึงข้อความแชทแบบเรียลไทม์จาก 'messages'
final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, roomId) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]); // ถ้ายังไม่ล็อกอิน คืน list ว่าง
  return firestore
      .collection('messages')
      .where('room_id', isEqualTo: roomId)
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

Future<void> signOutUser() async {
  try {
    await FirebaseAuth.instance.signOut();
    print("User signed out successfully");
  } catch (e) {
    print("Error signing out: $e");
  }
}


// FutureProvider สำหรับดึงข้อมูลผู้ใช้จาก 'users' ตาม senderId
final userInfoProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, senderId) async {
  final firestore = ref.watch(firestoreProvider);
  final doc = await firestore.collection('users').doc(senderId).get();
  return doc.data() ?? {};
});

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId; // ระบุกลุ่มแชท (เช่น "group1")
  const ChatScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).currentUser;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => signOutUser(),
                    child: const SizedBox(
                      width: 11,
                      height: 18,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://cdn.builder.io/api/v1/image/assets/TEMP/e49e5bc44dc899c764702b908822b721e078071d'),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Group Chat', // อาจเปลี่ยนเป็นชื่อกลุ่มจาก Firestore
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Chat area
            Expanded(
              child: Container(
                color: const Color(0xFFF3F4F6),
                padding: const EdgeInsets.all(16),
                child: messagesAsync.when(
                  data: (messages) {
                    String? previousSenderId;

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final senderId = message['sender'] as String;
                        final isReceived = senderId != currentUser?.uid;
                        final DateTime timestamp = DateTime.parse(message['timestamp']);

                        final time = "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

                        // ดึงข้อมูลผู้ใช้จาก userInfoProvider
                        final userInfoAsync = ref.watch(userInfoProvider(senderId));

                        // ตรวจสอบว่า sender เดียวกันกับข้อความก่อนหน้าหรือไม่
                        final showSenderImage = previousSenderId != senderId;
                        previousSenderId = senderId;

                        return Column(
                          children: [
                            userInfoAsync.when(
                              data: (userInfo) {
                                final senderImage = showSenderImage && isReceived
                                    ? (userInfo['image_url'] as String?) ??
                                        'https://cdn.builder.io/api/v1/image/assets/TEMP/662b3451c8a5ff8bfbb679b99e7bbcd4a1fda80e'
                                    : null;

                                return MessageBubble(
                                  message: message['message'] as String?,
                                  time: time,
                                  isReceived: isReceived,
                                  senderImage: senderImage,
                                  imageUrl: message['imageUrl'] as String?,
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) => Text('Error loading user: $error'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ),

            // Input field
            ChatInputField(roomId: widget.roomId),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}