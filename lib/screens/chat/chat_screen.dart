import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatHistory() {
    // TODO: Load chat history from API
    setState(() {
      _messages.addAll([
        ChatMessage(
          id: 1,
          message: 'Xin chào! Tôi có thể giúp gì cho bạn?',
          isFromUser: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ]);
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        message: message,
        isFromUser: true,
        createdAt: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // TODO: Send message to AI service
    _simulateAIResponse(message);
  }

  void _simulateAIResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            message: _getAIResponse(userMessage),
            isFromUser: false,
            createdAt: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('giá') || message.contains('phí')) {
      return 'Chúng tôi có các dịch vụ cắt tóc nam từ 150.000đ, cắt tóc nữ từ 200.000đ. Bạn có muốn xem chi tiết không?';
    } else if (message.contains('đặt lịch') || message.contains('booking')) {
      return 'Bạn có thể đặt lịch qua ứng dụng hoặc gọi điện trực tiếp. Thời gian làm việc: 8:00 - 20:00 hàng ngày.';
    } else if (message.contains('kiểu tóc') || message.contains('style')) {
      return 'Chúng tôi có nhiều kiểu tóc phù hợp với từng khuôn mặt. Bạn có thể sử dụng tính năng AI tư vấn để được gợi ý kiểu tóc phù hợp.';
    } else if (message.contains('sản phẩm') || message.contains('mua')) {
      return 'Chúng tôi có nhiều sản phẩm chăm sóc tóc chất lượng cao. Bạn có thể xem trong phần Cửa hàng của ứng dụng.';
    } else {
      return 'Cảm ơn bạn đã liên hệ! Tôi có thể giúp bạn về dịch vụ cắt tóc, đặt lịch, sản phẩm chăm sóc tóc. Bạn cần hỗ trợ gì thêm không?';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
          tooltip: 'Về trang chủ',
        ),
        title: const Text('Chat với AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _loadChatHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isFromUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isFromUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: message.isFromUser
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  return Text(
                    user?.firstName.isNotEmpty == true
                        ? user!.firstName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final int id;
  final String message;
  final bool isFromUser;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isFromUser,
    required this.createdAt,
  });
}





