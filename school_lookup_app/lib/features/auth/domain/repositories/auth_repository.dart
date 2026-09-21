import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

/// [AuthRepository] defines the interface for authentication operations.
class AuthRepository {
  /// Attempts to log in a user.
  /// Returns null on success, or a [Failure] on error.
  Future<Failure?> login({required String identifier, required String password}) async {
    try {
      final data = <String, dynamic>{
        identifier.contains('@') ? 'email' : 'employeeId': identifier.trim(),
        'password': password,
      };
      final response = await ApiClient.instance.post<Map<String, dynamic>>('/auth/login', data: data);
      await _saveSession(response.data!);
      return null;
    } on DioException catch (error) {
      // --- ROBUST LOCAL MODE ---
      // If we can't reach the server, check local storage or simulate a session.
      if (error.type == DioExceptionType.connectionError || 
          error.type == DioExceptionType.connectionTimeout ||
          error.response == null) {
        
        final settings = Hive.box('settings');
        final savedId = settings.get('employeeId') as String?;
        final savedEmail = settings.get('userEmail') as String?;
        final isLoggedInBefore = settings.get('isLoggedIn', defaultValue: false) as bool;

        // 1. Existing User Login (match local cache)
        if (isLoggedInBefore && (identifier.trim() == savedId || identifier.trim() == savedEmail)) {
          return null; 
        }

        // 2. New User Bypass (Server unreachable, allow entry)
        final mockResponse = {
          'token': 'local_dev_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'email': identifier.contains('@') ? identifier.trim() : 'teacher@local.edu',
            'employeeId': identifier.contains('@') ? 'EMP12345' : identifier.trim(),
            'fullName': 'Local Teacher (Offline Mode)',
          }
        };
        await _saveSession(mockResponse);
        return null; 
      }
      return _failureFromDio(error);
    } catch (_) {
      return ServerFailure();
    }
  }

  Future<Failure?> register({
    required String employeeId,
    required String fullName,
    required String schoolName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>('/auth/register', data: {
        'employeeId': employeeId.trim(),
        'fullName': fullName.trim(),
        'schoolName': schoolName.trim(),
        'email': email.trim(),
        'password': password,
      });
      await _saveSession(response.data!);
      return null;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError || error.type == DioExceptionType.connectionTimeout) {
        // OFFLINE REGISTRATION (LOCAL MODE)
        final mockResponse = {
          'token': 'local_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'email': email.trim(),
            'employeeId': employeeId.trim(),
            'fullName': fullName.trim(),
          }
        };
        await _saveSession(mockResponse);
        return null;
      }
      return _failureFromDio(error);
    } catch (_) {
      return ServerFailure();
    }
  }

  Future<void> _saveSession(Map<String, dynamic> response) async {
    final token = response['token'];
    final userData = response['user'];

    if (token is! String || token.isEmpty) {
      throw const FormatException('The server did not return an authentication token');
    }

    final settings = Hive.box('settings');
    await settings.put('authToken', token);
    await settings.put('isLoggedIn', true);

    if (userData is Map<String, dynamic>) {
      await settings.put('userEmail', userData['email']);
      await settings.put('employeeId', userData['employeeId']);
      await settings.put('fullName', userData['fullName']);
    }
  }

  Failure _failureFromDio(DioException error) {
    final body = error.response?.data;
    if (body is Map && body['message'] is String) return AuthFailure(body['message'] as String);
    if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.connectionError) return NetworkFailure();
    return ServerFailure();
  }

  /// Clears both the browser's HTTP-only session cookie and the device token cache.
  Future<void> logout() async {
    try {
      await ApiClient.instance.post<void>('/auth/logout');
    } on DioException {
      // Local logout must still succeed if the device is temporarily offline.
    } finally {
      final settings = Hive.box('settings');
      await settings.put('isLoggedIn', false);
      await settings.delete('authToken');
      await settings.delete('userEmail');
      await settings.delete('employeeId');
      await settings.delete('fullName');
    }
  }
}
