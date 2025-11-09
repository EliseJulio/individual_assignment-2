import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../widgets/book_card.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Browse Books'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Consumer<BookProvider>(
          builder: (context, bookProvider, child) {
            final currentUser = FirebaseAuth.instance.currentUser;
            final availableBooks = bookProvider.books
                .where((book) =>
                    book.ownerId != currentUser?.uid &&
                    book.status == 'available')
                .toList();

            if (availableBooks.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No books available for swap',
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableBooks.length,
              itemBuilder: (context, index) {
                final book = availableBooks[index];
                return BookCard(
                  book: book,
                  onSwap: () => _showSwapDialog(context, book),
                );
              },
            );
          },
        ),
      );

  void _showSwapDialog(BuildContext context, book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Swap'),
        content: Text('Do you want to request a swap for "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final swapProvider =
                  Provider.of<SwapProvider>(context, listen: false);
              final error = await swapProvider.createSwapOffer(
                book.id,
                book.title,
                book.ownerId,
                book.ownerEmail,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Swap request sent!'),
                    backgroundColor: error != null ? Colors.red : Colors.green,
                  ),
                );
              }
            },
            child: const Text('Request Swap'),
          ),
        ],
      ),
    );
  }
}
