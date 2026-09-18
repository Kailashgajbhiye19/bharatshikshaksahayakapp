import 'package:dio/dio.dart';

/// Native Flutter clients use the stored Authorization header instead of browser cookies.
void configureCookieSupport(Dio client) {}
