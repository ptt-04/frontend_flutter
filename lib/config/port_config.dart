class PortConfig {
  // Backend ports
  static const int backendPort = 9000;
  static const String backendUrl = 'http://localhost:$backendPort';
  static const String backendApiUrl = '$backendUrl/api';
  
  // Frontend ports
  static const int flutterWebPort = 4000;
  static const int flutterDesktopPort = 4001;
  static const int flutterMobilePort = 4002;
  
  // Frontend URLs
  static const String flutterWebUrl = 'http://localhost:$flutterWebPort';
  static const String flutterDesktopUrl = 'http://localhost:$flutterDesktopPort';
  static const String flutterMobileUrl = 'http://localhost:$flutterMobilePort';
  
  // Development URLs
  static const String devBackendUrl = 'http://localhost:$backendPort';
  static const String devBackendApiUrl = '$devBackendUrl/api';
  
  // Production URLs
  static const String prodBackendUrl = 'https://api.barbershop.com';
  static const String prodBackendApiUrl = '$prodBackendUrl/api';
  
  // Staging URLs
  static const String stagingBackendUrl = 'https://staging-api.barbershop.com';
  static const String stagingBackendApiUrl = '$stagingBackendUrl/api';
}
