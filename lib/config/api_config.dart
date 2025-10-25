import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Lấy URL từ file .env hoặc fallback
  static String get devBaseUrl =>
      dotenv.env['DEV_BASE_URL'] ?? 'http://localhost:9001/api';

  static String get prodBaseUrl =>
      dotenv.env['PROD_BASE_URL'] ?? 'https://api.barbershop.com/api';

  static String get stagingBaseUrl =>
      dotenv.env['STAGING_BASE_URL'] ??
      'https://staging-api.barbershop.com/api';

  // Lấy URL dựa trên environment từ .env hoặc fallback
  static String get baseUrl {
    final environment = dotenv.env['ENVIRONMENT'] ?? 'dev';

    switch (environment.toLowerCase()) {
      case 'prod':
      case 'production':
        return prodBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      case 'dev':
      case 'development':
      default:
        return devBaseUrl;
    }
  }

  // Chuẩn hóa URL ảnh: hỗ trợ đường dẫn relative như "/uploads/..."
  static String resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    // Determine origin from baseUrl (strip trailing /api if present)
    final origin = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;

    // If absolute URL but points to localhost/127.0.0.1, rewrite to current origin
    if (url.startsWith('http://') || url.startsWith('https://')) {
      final lower = url.toLowerCase();
      if (lower.contains('://localhost') || lower.contains('://127.0.0.1')) {
        // Replace scheme+host (and optional port) with current origin
        try {
          final uri = Uri.parse(url);
          final replacement = Uri.parse(origin);
          final rebuilt = uri.replace(
            scheme: replacement.scheme,
            host: replacement.host,
            port: replacement.hasPort ? replacement.port : replacement.port,
          );
          return rebuilt.toString();
        } catch (_) {
          // fallback to origin + path
          final path = url.replaceFirst(RegExp(r'^https?://[^/]+'), '');
          return '$origin$path';
        }
      }
      return url;
    }
    // Lấy origin từ baseUrl (loại "/api")
    if (url.startsWith('/')) return '$origin$url';
    return '$origin/$url';
  }

  // Gemini API Key từ file .env
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? 'AIzaSyB71pXOOolh5Ub2hXnXPqJgtqY8_18B3W8';

  // Gemini Model Configuration
  static String get geminiModel => dotenv.env['GEMINI_MODEL_NAME'] ?? 'gemini-2.5-pro';
  
  static int get geminiMaxTokens => int.tryParse(dotenv.env['GEMINI_MAX_TOKENS'] ?? '4096') ?? 4096;
  
  static double get geminiTemperature => double.tryParse(dotenv.env['GEMINI_TEMPERATURE'] ?? '0.7') ?? 0.7;

  // Phương thức để khởi tạo dotenv (gọi trong main.dart)
  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('⚠️ Không thể load file .env, sử dụng URL mặc định: $devBaseUrl');
    }
  }
}
