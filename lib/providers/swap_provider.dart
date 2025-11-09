import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/swap_offer.dart';

class SwapProvider with ChangeNotifier {
  SwapProvider() {
    _listenToMyOffers();
    _listenToReceivedOffers();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SwapOffer> _myOffers = [];
  List<SwapOffer> _receivedOffers = [];
  bool _isLoading = false;

  List<SwapOffer> get myOffers => _myOffers;
  List<SwapOffer> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;

  void _listenToMyOffers() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('swapOffers')
          .where('requesterId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        _myOffers = snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();
      });
    }
  }

  void _listenToReceivedOffers() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('swapOffers')
          .where('ownerId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        _receivedOffers = snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();
      });
    }
  }

  Future<String?> createSwapOffer(String bookId, String bookTitle,
      String ownerId, String ownerEmail) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return 'User not authenticated';

      final swapOffer = SwapOffer(
        id: '',
        requesterId: user.uid,
        requesterEmail: user.email ?? '',
        ownerId: ownerId,
        ownerEmail: ownerEmail,
        bookId: bookId,
        bookTitle: bookTitle,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('swapOffers').add(swapOffer.toMap());

      // Update book status to pending
      await _firestore
          .collection('books')
          .doc(bookId)
          .update({'status': 'pending'});

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> updateSwapStatus(
      String offerId, String status, String bookId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('swapOffers')
          .doc(offerId)
          .update({'status': status});

      // Update book status based on swap status
      final bookStatus = status == 'accepted' ? 'swapped' : 'available';
      await _firestore
          .collection('books')
          .doc(bookId)
          .update({'status': bookStatus});

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
}
