import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ai_provider.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImagePath = image?.path;
    });
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty && _selectedImagePath == null) {
      return;
    }
    
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final message = _messageController.text;
    
    // Check if this is an image editing request
    if (_selectedImagePath != null && message.toLowerCase().contains('chỉnh sửa')) {
      aiProvider.editImage(_selectedImagePath!, message);
    } else {
      aiProvider.sendMessage(message, imagePath: _selectedImagePath);
    }
    
    _messageController.clear();
    setState(() {
      _selectedImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
          tooltip: 'Quay lại',
        ),
        title: const Text('AI Chat - Gemini 2.5 Pro'),
        actions: [
          Consumer<AIProvider>(
            builder: (context, aiProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
                    case 'clear':
                      aiProvider.clearMessages();
                      break;
                    case 'regenerate':
                      await aiProvider.regenerateLastResponse();
                      break;
                    case 'export':
                      await aiProvider.exportChat();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xuất lịch sử chat'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'regenerate',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('Tạo lại phản hồi'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 8),
                        Text('Xuất lịch sử'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          return Column(
            children: [
              Expanded(
                child: aiProvider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chào mừng đến với AI Chat!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Powered by Gemini 2.5 Pro - AI mạnh mẽ nhất',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Hãy bắt đầu cuộc trò chuyện với AI',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Error message
                          if (aiProvider.error != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      aiProvider.error!,
                                      style: TextStyle(color: Colors.red[600]),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () => aiProvider.clearError(),
                                  ),
                                  if (aiProvider.error != null && aiProvider.error!.contains('503'))
                                    IconButton(
                                      icon: const Icon(Icons.refresh, size: 20),
                                      onPressed: () async {
                                        // Retry last message
                                        if (aiProvider.messages.isNotEmpty) {
                                          final lastUserMessage = aiProvider.messages.lastWhere((msg) => msg.isUser);
                                          await aiProvider.sendMessage(lastUserMessage.message, imagePath: lastUserMessage.imagePath);
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          // Messages list
                          Expanded(
                            child: ListView.builder(
                              reverse: true,
                              itemCount: aiProvider.messages.length,
                              itemBuilder: (context, index) {
                                final message = aiProvider.messages[aiProvider.messages.length - 1 - index];
                                return Align(
                                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: message.isUser 
                                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: message.isUser 
                                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                                            : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                              child: Column(
                                crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (message.imagePath != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(message.imagePath!),
                                          height: 150,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: message.isUser 
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                          ),
                        ],
                      ),
              ),
              if (aiProvider.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI đang suy nghĩ...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_selectedImagePath != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 100,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImagePath!),
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImagePath = null;
                            });
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImage,
                      tooltip: 'Chọn ảnh',
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      tooltip: 'Gửi tin nhắn',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
