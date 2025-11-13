import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/safe_image.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key, this.book});
  final Book? book;

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCondition = 'Good';

  final List<String> _conditions = ['New', 'Like New', 'Good', 'Used'];

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _imageUrlController.text = widget.book!.imageUrl;
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add Book'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter book title';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter author name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCondition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: _conditions
                    .map((condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCondition = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Leave empty for placeholder',
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SafeImage(
                    imageUrl: _imageUrlController.text,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<BookProvider>(
                builder: (context, bookProvider, child) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: bookProvider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: bookProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEditing ? 'Update Book' : 'Add Book'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    String? error;

    if (widget.book != null) {
      error = await bookProvider.updateBook(
        widget.book!.id,
        _titleController.text,
        _authorController.text,
        _selectedCondition,
        _imageUrlController.text,
      );
    } else {
      error = await bookProvider.addBook(
        _titleController.text,
        _authorController.text,
        _selectedCondition,
        _imageUrlController.text,
      );
    }

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.book != null ? 'Book updated!' : 'Book added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
