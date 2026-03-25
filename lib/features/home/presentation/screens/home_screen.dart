import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('하루 만원')),
      body: const Center(
        child: Text('홈 화면'),
      ),
    );
  }
}
