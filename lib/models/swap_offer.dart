class SwapOffer {
  SwapOffer({
    required this.id,
    required this.requesterId,
    required this.requesterEmail,
    required this.ownerId,
    required this.ownerEmail,
    required this.bookId,
    required this.bookTitle,
    required this.status,
    required this.createdAt,
  });

  factory SwapOffer.fromMap(Map<String, dynamic> map, String id) => SwapOffer(
        id: id,
        requesterId: map['requesterId'] ?? '',
        requesterEmail: map['requesterEmail'] ?? '',
        ownerId: map['ownerId'] ?? '',
        ownerEmail: map['ownerEmail'] ?? '',
        bookId: map['bookId'] ?? '',
        bookTitle: map['bookTitle'] ?? '',
        status: map['status'] ?? 'pending',
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      );
  final String id;
  final String requesterId;
  final String requesterEmail;
  final String ownerId;
  final String ownerEmail;
  final String bookId;
  final String bookTitle;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'requesterId': requesterId,
        'requesterEmail': requesterEmail,
        'ownerId': ownerId,
        'ownerEmail': ownerEmail,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'status': status,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
