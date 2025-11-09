import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Books'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'My Books'),
                Tab(text: 'My Offers'),
                Tab(text: 'Received'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _MyBooksTab(),
              _MyOffersTab(),
              _ReceivedOffersTab(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBookScreen()),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      );
}

class _MyBooksTab extends StatelessWidget {
  const _MyBooksTab();

  @override
  Widget build(BuildContext context) => Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.myBooks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No books listed yet', style: TextStyle(fontSize: 18)),
                  Text('Tap + to add your first book'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookProvider.myBooks.length,
            itemBuilder: (context, index) {
              final book = bookProvider.myBooks[index];
              return BookCard(
                book: book,
                isOwner: true,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookScreen(book: book),
                  ),
                ),
                onDelete: () => _showDeleteDialog(context, book.id),
              );
            },
          );
        },
      );

  void _showDeleteDialog(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final bookProvider =
                  Provider.of<BookProvider>(context, listen: false);
              final error = await bookProvider.deleteBook(bookId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Book deleted successfully'),
                    backgroundColor: error != null ? Colors.red : Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MyOffersTab extends StatelessWidget {
  const _MyOffersTab();

  @override
  Widget build(BuildContext context) => Consumer<SwapProvider>(
        builder: (context, swapProvider, child) {
          if (swapProvider.myOffers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No swap offers sent', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: swapProvider.myOffers.length,
            itemBuilder: (context, index) {
              final offer = swapProvider.myOffers[index];
              return Card(
                child: ListTile(
                  title: Text(offer.bookTitle),
                  subtitle: Text('To: ${offer.ownerEmail}'),
                  trailing: Chip(
                    label: Text(offer.status.toUpperCase()),
                    backgroundColor: _getStatusColor(offer.status),
                  ),
                ),
              );
            },
          );
        },
      );

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ReceivedOffersTab extends StatelessWidget {
  const _ReceivedOffersTab();

  @override
  Widget build(BuildContext context) => Consumer<SwapProvider>(
        builder: (context, swapProvider, child) {
          if (swapProvider.receivedOffers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No swap offers received',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: swapProvider.receivedOffers.length,
            itemBuilder: (context, index) {
              final offer = swapProvider.receivedOffers[index];
              return Card(
                child: ListTile(
                  title: Text(offer.bookTitle),
                  subtitle: Text('From: ${offer.requesterEmail}'),
                  trailing: offer.status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateOfferStatus(
                                  context, offer.id, 'accepted', offer.bookId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateOfferStatus(
                                  context, offer.id, 'rejected', offer.bookId),
                            ),
                          ],
                        )
                      : Chip(
                          label: Text(offer.status.toUpperCase()),
                          backgroundColor: _getStatusColor(offer.status),
                        ),
                ),
              );
            },
          );
        },
      );

  Future<void> _updateOfferStatus(BuildContext context, String offerId,
      String status, String bookId) async {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    final error = await swapProvider.updateSwapStatus(offerId, status, bookId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Offer $status'),
          backgroundColor: error != null ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
