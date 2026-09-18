import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'api_client_cookie_config_stub.dart'
    if (dart.library.js_interop) 'api_client_cookie_config_web.dart';

/// One HTTP client for the app. Override the URL for a physical device with:
/// `--dart-define=API_BASE_URL=http://<computer-LAN-IP>:5000/api/v1`.
class ApiClient {
  ApiClient._();

  static final Dio instance = _create();

  static Dio _create() {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    final client = Dio(BaseOptions(
      baseUrl: configuredUrl.isNotEmpty ? configuredUrl : _developmentBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    configureCookieSupport(client);
    client.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      // Login/register work without a token; every later protected request reuses it.
      final token = Hive.box('settings').get('authToken');
      if (token is String && token.isNotEmpty) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }));
    return client;
  }

  static String _developmentBaseUrl() {
    // Android emulators use 10.0.2.2 to reach the development computer.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5000/api/v1';
    return 'http://localhost:5000/api/v1';
  }
}
