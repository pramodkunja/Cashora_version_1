class AppConfig {
  static const String appName = 'Cashora';
  
  // ==================== NETWORK CONFIGURATION ====================
  // IMPORTANT: Choose the correct URL based on your testing environment
  // Uncomment ONLY ONE of the following:
  
  // 1. For Android Emulator (10.0.2.2 maps to host machine's localhost)
  // static const String apiBaseUrl = 'http://10.0.2.2:8000';
  
  // 2. For iOS Simulator
  // static const String apiBaseUrl = 'http://127.0.0.1:8000';
  
  // 3. For Physical Device (Replace with your computer's local IP)
  // Find your IP: Windows (ipconfig), Mac/Linux (ifconfig)
  // static const String apiBaseUrl = 'https://cashora.nxsys.in';
  static const String apiBaseUrl = 'http://192.168.0.149:8000';
  
  // 4. For Production/Remote Server
  // static const String apiBaseUrl = 'https://your-production-api.com';
  
  // ===============================================================

  // Timeouts (in milliseconds)
  static const int connectTimeout = 15000;  // 15 seconds
  static const int receiveTimeout = 15000;  // 15 seconds
  
  // Debug mode - set to true to see detailed network logs
  static const bool enableDebugLogs = true;

}
