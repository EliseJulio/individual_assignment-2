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
        .listen((snapshot) async {
      final messages = <ChatMessage>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        var message = ChatMessage.fromMap(data, doc.id);
        
        // If no sender name, try to fetch it
        if (message.senderName == null) {
          try {
            final userDoc = await _firestore.collection('users').doc(message.senderId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              final senderName = userData?['name'] ?? userData?['email']?.split('@')[0] ?? message.senderEmail.split('@')[0];
              message = ChatMessage(
                id: message.id,
                senderId: message.senderId,
                senderEmail: message.senderEmail,
                receiverId: message.receiverId,
                message: message.message,
                timestamp: message.timestamp,
                chatId: message.chatId,
                senderName: senderName,
              );
            }
          } catch (e) {
            // Use email prefix as fallback
            message = ChatMessage(
              id: message.id,
              senderId: message.senderId,
              senderEmail: message.senderEmail,
              receiverId: message.receiverId,
              message: message.message,
              timestamp: message.timestamp,
              chatId: message.chatId,
              senderName: message.senderEmail.split('@')[0],
            );
          }
        }
        
        messages.add(message);
      }
      
      _messages = messages;
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

      // Get sender name
      String? senderName;
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        senderName = userDoc.data()?['name'] ?? user.email?.split('@')[0];
      } catch (e) {
        senderName = user.email?.split('@')[0];
      }

      final chatMessage = ChatMessage(
        id: '',
        senderId: user.uid,
        senderEmail: user.email ?? '',
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        chatId: chatId,
        senderName: senderName,
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
    } on Exception catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  String generateChatId(String userId1, String userId2) {
    final ids = <String>[userId1, userId2];
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

      final chats = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUserId = participants.firstWhere((id) => id != user.uid);
        
        // Get other user's name
        String otherUserName = 'Unknown User';
        try {
          final userDoc = await _firestore.collection('users').doc(otherUserId).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            otherUserName = userData?['name'] ?? userData?['email']?.split('@')[0] ?? otherUserId;
          } else {
            otherUserName = otherUserId;
          }
        } catch (e) {
          otherUserName = otherUserId;
        }
        
        chats.add({
          'id': doc.id,
          'otherUserName': otherUserName,
          ...data,
        });
      }
      
      return chats;
    } on FirebaseException {
      return [];
    }
  }
}
