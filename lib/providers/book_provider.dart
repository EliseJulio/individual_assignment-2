import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';

class BookProvider with ChangeNotifier {
  BookProvider() {
    _listenToBooks();
    _listenToMyBooks();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Book> _books = [];
  List<Book> _myBooks = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  List<Book> get myBooks => _myBooks;
  bool get isLoading => _isLoading;

  void _listenToBooks() {
    _firestore.collection('books').snapshots().listen((snapshot) {
      _books =
          snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    });
  }

  void _listenToMyBooks() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('books')
          .where('ownerId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        _myBooks = snapshot.docs
            .map((doc) => Book.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();
      });
    }
  }

  Future<String?> addBook(
      String title, String author, String condition, String imageUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return 'User not authenticated';
      
      // Get user name from Firestore
      String ownerName = user.email ?? '';
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          ownerName = userDoc.data()?['name'] ?? user.email ?? '';
        }
      } catch (e) {
        ownerName = user.email ?? '';
      }

      final book = Book(
        id: '',
        title: title,
        author: author,
        condition: condition,
        imageUrl: imageUrl,
        ownerId: user.uid,
        ownerEmail: ownerName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('books').add(book.toMap());

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> updateBook(String bookId, String title, String author,
      String condition, String imageUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('books').doc(bookId).update({
        'title': title,
        'author': author,
        'condition': condition,
        'imageUrl': imageUrl,
      });

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> deleteBook(String bookId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('books').doc(bookId).delete();

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> updateBookStatus(String bookId, String status) async {
    try {
      await _firestore
          .collection('books')
          .doc(bookId)
          .update({'status': status});
      return null;
    } on FirebaseException catch (e) {
      return e.toString();
    }
  }
}
