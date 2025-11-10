import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chats = await chatProvider.getUserChats();
    setState(() => _chats = chats);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: _chats.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No chats yet', style: TextStyle(fontSize: 18)),
                    Text('Start a conversation after making a swap offer'),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  final currentUser = FirebaseAuth.instance.currentUser;
                  final participants =
                      List<String>.from(chat['participants'] ?? []);
                  final otherUserId =
                      participants.firstWhere((id) => id != currentUser?.uid);

                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(chat['otherUserEmail'] ?? 'Unknown User'),
                    subtitle: Text(chat['lastMessage'] ?? 'No messages yet'),
                    trailing: chat['lastMessageTime'] != null
                        ? Text(_formatTime(chat['lastMessageTime']))
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chatId: chat['id'],
                          otherUserId: otherUserId,
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showNewChatDialog,
          child: const Icon(Icons.add),
        ),
      );

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showNewChatDialog() {
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: TextField(
          controller: userIdController,
          decoration: const InputDecoration(
            labelText: 'User ID',
            hintText: 'Enter the user ID to chat with',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (userIdController.text.isNotEmpty) {
                Navigator.pop(context);
                final chatProvider =
                    Provider.of<ChatProvider>(context, listen: false);
                final currentUser = FirebaseAuth.instance.currentUser;
                final chatId = chatProvider.generateChatId(
                    currentUser!.uid, userIdController.text);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      chatId: chatId,
                      otherUserId: userIdController.text,
                    ),
                  ),
                );
              }
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }
}
