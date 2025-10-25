import 'dart:io';
import 'dart:typed_data';

import '../config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as generative_ai;
import 'package:path_provider/path_provider.dart';

import '../models/ai.dart';

class AIProvider with ChangeNotifier {
  final List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  generative_ai.GenerativeModel? _model;

  List<AIChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AIProvider() {
    _initializeModel();
  }

  void _initializeModel() {
    try {
      _model = generative_ai.GenerativeModel(
        model: ApiConfig.geminiModel, // Use configurable model name
        apiKey: ApiConfig.geminiApiKey,
        generationConfig: generative_ai.GenerationConfig(
          temperature: ApiConfig.geminiTemperature,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: ApiConfig.geminiMaxTokens,
        ),
      );
    } catch (e) {
      _error = 'Không thể khởi tạo AI model: $e';
    }
  }


  Future<void> editImage(String imagePath, String editInstruction) async {
    if (_model == null) {
      _error = 'AI model chưa được khởi tạo';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Add user message with image
    _messages.add(
      AIChatMessage(
        message: 'Chỉnh sửa ảnh: $editInstruction',
        isUser: true,
        imagePath: imagePath,
      ),
    );

    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      final prompt = '''
Hãy chỉnh sửa ảnh này theo yêu cầu: $editInstruction
Trả về ảnh đã được chỉnh sửa theo định dạng JPEG.
''';

      final response = await _model!.generateContent([
        generative_ai.Content.multi([
          generative_ai.TextPart(prompt),
          generative_ai.DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ]);

      String responseText = response.text ?? 'Đã chỉnh sửa ảnh thành công!';
      String? responseImagePath;

      // Check for generated image in response
      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        if (candidate.content.parts.isNotEmpty) {
          for (final part in candidate.content.parts) {
            if (part is generative_ai.DataPart && part.mimeType.startsWith('image/')) {
              responseImagePath = await _saveGeneratedImage(part.bytes);
              break;
            }
          }
        }
      }

      _messages.add(
        AIChatMessage(
          message: responseText,
          isUser: false,
          imagePath: responseImagePath,
        ),
      );
    } catch (e) {
      _error = 'Lỗi chỉnh sửa ảnh: $e';
      _messages.add(AIChatMessage(message: _error!, isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message, {String? imagePath}) async {
    if (_model == null) {
      _error = 'AI model chưa được khởi tạo';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    _messages.add(
      AIChatMessage(message: message, isUser: true, imagePath: imagePath),
    );

    // Retry mechanism for overloaded errors
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        final List<generative_ai.Part> parts = [generative_ai.TextPart(message)];

        if (imagePath != null) {
          final imageFile = File(imagePath);
          final imageBytes = await imageFile.readAsBytes();
          parts.add(generative_ai.DataPart('image/jpeg', Uint8List.fromList(imageBytes)));
        }

        final response = await _model!.generateContent([
          generative_ai.Content.multi(parts)
        ]);

        // Check if response contains images
        String responseText = response.text ?? 'Không có phản hồi từ AI.';
        String? responseImagePath;

        // If the response contains image data, save it
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.content.parts.isNotEmpty) {
            for (final part in candidate.content.parts) {
              if (part is generative_ai.DataPart && part.mimeType.startsWith('image/')) {
                // Save the generated image
                responseImagePath = await _saveGeneratedImage(part.bytes);
                break;
              }
            }
          }
        }

        _messages.add(
          AIChatMessage(
            message: responseText,
            isUser: false,
            imagePath: responseImagePath,
          ),
        );
        
        // Success - break out of retry loop
        break;
        
      } catch (e) {
        retryCount++;
        
        // If it's an overload error and we haven't exceeded max retries
        if (e.toString().contains('503') && e.toString().contains('overloaded') && retryCount < maxRetries) {
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
        
        // If max retries exceeded or other error, show error message
        String errorMessage = _parseErrorMessage(e.toString());
        _error = errorMessage;
        _messages.add(AIChatMessage(message: errorMessage, isUser: false));
        break;
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // New method for advanced Gemini 2.5 Pro features
  Future<void> sendAdvancedMessage(String message, {
    String? imagePath,
    String? systemPrompt,
    bool enableCodeGeneration = false,
    bool enableReasoning = false,
  }) async {
    if (_model == null) {
      _error = 'AI model chưa được khởi tạo';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    _messages.add(
      AIChatMessage(message: message, isUser: true, imagePath: imagePath),
    );

    try {
      // Enhanced prompt for Gemini 2.5 Pro
      String enhancedMessage = message;
      
      if (systemPrompt != null) {
        enhancedMessage = '$systemPrompt\n\nUser: $message';
      }
      
      if (enableCodeGeneration) {
        enhancedMessage = '$enhancedMessage\n\nPlease provide code examples if applicable.';
      }
      
      if (enableReasoning) {
        enhancedMessage = '$enhancedMessage\n\nPlease show your reasoning process step by step.';
      }

      final List<generative_ai.Part> parts = [generative_ai.TextPart(enhancedMessage)];

      if (imagePath != null) {
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        parts.add(generative_ai.DataPart('image/jpeg', Uint8List.fromList(imageBytes)));
      }

      final response = await _model!.generateContent([
        generative_ai.Content.multi(parts)
      ]);

      String responseText = response.text ?? 'Không có phản hồi từ AI.';
      String? responseImagePath;

      // Check for generated image in response
      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        if (candidate.content.parts.isNotEmpty) {
          for (final part in candidate.content.parts) {
            if (part is generative_ai.DataPart && part.mimeType.startsWith('image/')) {
              responseImagePath = await _saveGeneratedImage(part.bytes);
              break;
            }
          }
        }
      }

      _messages.add(
        AIChatMessage(
          message: responseText,
          isUser: false,
          imagePath: responseImagePath,
        ),
      );
    } catch (e) {
      String errorMessage = _parseErrorMessage(e.toString());
      _error = errorMessage;
      _messages.add(AIChatMessage(message: errorMessage, isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _saveGeneratedImage(Uint8List imageData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'generated_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageData);
      return file.path;
    } catch (e) {
      print('Error saving generated image: $e');
      return null;
    }
  }

  void clearMessages() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> regenerateLastResponse() async {
    if (_messages.isEmpty || _messages.last.isUser) return;
    
    // Remove last AI response
    _messages.removeLast();
    
    // Get the last user message
    final lastUserMessage = _messages.lastWhere((msg) => msg.isUser);
    
    // Resend the message
    await sendMessage(lastUserMessage.message, imagePath: lastUserMessage.imagePath);
  }

  Future<void> exportChat() async {
    // Export chat history to text
    final chatHistory = _messages.map((msg) => 
      '${msg.isUser ? "Bạn" : "AI"}: ${msg.message}'
    ).join('\n\n');
    
    // You can implement file saving logic here
    print('Chat History:\n$chatHistory');
  }

  int get messageCount => _messages.length;
  
  bool get hasMessages => _messages.isNotEmpty;
  
  String get lastMessage => _messages.isNotEmpty ? _messages.last.message : '';

  String _parseErrorMessage(String error) {
    // Parse specific Gemini API errors
    if (error.contains('503') && error.contains('overloaded')) {
      return '🤖 Gemini AI đang quá tải. Vui lòng thử lại sau vài phút.\n\n💡 Gợi ý: Hãy thử lại sau 1-2 phút hoặc sử dụng câu hỏi ngắn gọn hơn.';
    }
    
    if (error.contains('429') && error.contains('quota')) {
      return '⚠️ Đã vượt quá giới hạn API. Vui lòng thử lại sau.\n\n💡 Gợi ý: Chờ vài phút trước khi gửi tin nhắn tiếp theo.';
    }
    
    if (error.contains('401') || error.contains('unauthorized')) {
      return '🔑 Lỗi xác thực API. Vui lòng kiểm tra cấu hình.\n\n💡 Gợi ý: Liên hệ admin để kiểm tra API key.';
    }
    
    if (error.contains('400') && error.contains('bad request')) {
      return '📝 Yêu cầu không hợp lệ. Vui lòng kiểm tra lại tin nhắn.\n\n💡 Gợi ý: Thử viết lại câu hỏi một cách rõ ràng hơn.';
    }
    
    if (error.contains('timeout') || error.contains('connection')) {
      return '🌐 Lỗi kết nối. Vui lòng kiểm tra internet và thử lại.\n\n💡 Gợi ý: Kiểm tra kết nối mạng và thử lại.';
    }
    
    // Default error message
    return '❌ Đã xảy ra lỗi không xác định.\n\n💡 Gợi ý: Vui lòng thử lại sau hoặc liên hệ hỗ trợ nếu lỗi tiếp tục.';
  }
}
