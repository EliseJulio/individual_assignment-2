import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void listenToMessages(String chatId) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  Future<String?> sendMessage(
      String chatId, String receiverId, String message) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return 'User not authenticated';

      final chatMessage = ChatMessage(
        id: '',
        senderId: user.uid,
        senderEmail: user.email ?? '',
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        chatId: chatId,
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(chatMessage.toMap());

      // Update chat document with last message info
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [user.uid, receiverId],
        'lastMessage': message,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  String generateChatId(String userId1, String userId2) {
    final ids = <String>[userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Future<List<Map<String, dynamic>>> getUserChats() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } on FirebaseException {
      return [];
    }
  }
}
