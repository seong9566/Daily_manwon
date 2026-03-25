import 'package:flutter/material.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('업적')),
      body: const Center(
        child: Text('업적/배지 화면'),
      ),
    );
  }
}
