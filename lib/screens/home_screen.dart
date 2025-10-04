import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../widgets/top_navbar.dart';

class HomeScreen extends ConsumerWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const TopNavbar(activeIndex: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: Text('Chào, ${user.fullName}!', style: const TextStyle(color: Colors.white)),
                subtitle: Text('Cấp độ: ${user.level}/1000', style: const TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Chọn một chức năng ở thanh điều hướng phía trên để tiếp tục.',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0F0A1F),
    );
  }
}
