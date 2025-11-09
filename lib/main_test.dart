import 'package:flutter/material.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BookSwap Test',
        home: Scaffold(
          appBar: AppBar(title: const Text('BookSwap Test')),
          body: const Center(
            child: Text(
              'App is running successfully!\nFirebase configuration needed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
}
