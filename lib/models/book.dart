class Book {
  // available, pending, swapped

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    required this.createdAt,
    this.status = 'available',
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) => Book(
        id: id,
        title: map['title'] ?? '',
        author: map['author'] ?? '',
        condition: map['condition'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        ownerId: map['ownerId'] ?? '',
        ownerEmail: map['ownerEmail'] ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
        status: map['status'] ?? 'available',
      );
  final String id;
  final String title;
  final String author;
  final String condition;
  final String imageUrl;
  final String ownerId;
  final String ownerEmail;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toMap() => {
        'title': title,
        'author': author,
        'condition': condition,
        'imageUrl': imageUrl,
        'ownerId': ownerId,
        'ownerEmail': ownerEmail,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'status': status,
      };

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? condition,
    String? imageUrl,
    String? ownerId,
    String? ownerEmail,
    DateTime? createdAt,
    String? status,
  }) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        condition: condition ?? this.condition,
        imageUrl: imageUrl ?? this.imageUrl,
        ownerId: ownerId ?? this.ownerId,
        ownerEmail: ownerEmail ?? this.ownerEmail,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
      );
}
