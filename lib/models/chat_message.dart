class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.chatId,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) =>
      ChatMessage(
        id: id,
        senderId: map['senderId'] ?? '',
        senderEmail: map['senderEmail'] ?? '',
        receiverId: map['receiverId'] ?? '',
        message: map['message'] ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
        chatId: map['chatId'] ?? '',
      );
  final String id;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String chatId;

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderEmail': senderEmail,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'chatId': chatId,
      };
}
