import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateBookingScreen extends StatelessWidget {
  const CreateBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
          tooltip: 'Về trang chủ',
        ),
        title: const Text('Đặt lịch mới'),
      ),
      body: const Center(
        child: Text('Màn hình đặt lịch mới - Đang phát triển'),
      ),
    );
  }
}





