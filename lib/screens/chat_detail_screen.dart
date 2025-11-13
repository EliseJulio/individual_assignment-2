import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    required this.chatId,
    required this.otherUserId,
    super.key,
  });
  final String chatId;
  final String otherUserId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false)
        .listenToMessages(widget.chatId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String>(
            future: _getOtherUserName(),
            builder: (context, snapshot) {
              return Text(snapshot.data ?? 'Chat');
            },
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  final messages = chatProvider.messages;

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Start the conversation!'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final isMe = message.senderId == currentUser?.uid;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isMe && message.senderName != null) ...[
                                Text(
                                  message.senderName!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                message.message,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isMe ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) => IconButton(
                      onPressed: chatProvider.isLoading ? null : _sendMessage,
                      icon: chatProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final error = await chatProvider.sendMessage(
        widget.chatId, widget.otherUserId, message);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  String _formatTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  Future<String> _getOtherUserName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['name'] ?? userData?['email']?.split('@')[0] ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
