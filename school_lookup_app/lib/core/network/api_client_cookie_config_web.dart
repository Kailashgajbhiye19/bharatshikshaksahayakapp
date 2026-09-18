import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Lets the browser retain and send the backend's HTTP-only accessToken cookie.
void configureCookieSupport(Dio client) {
  (client.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
}
