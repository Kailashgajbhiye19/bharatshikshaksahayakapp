import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'app_exception.dart';
import 'failures.dart';

/// Utility class to parse any caught error/exception into a user-friendly [AppException].
class ErrorHandler {
  static AppException process(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is Failure) {
      return AppException(
        title: "Action Failed",
        message: error.message,
      );
    }

    if (error is PlatformException) {
      return _parsePlatformException(error);
    }

    if (error is DioException) {
      return _parseDioException(error);
    }

    final String errorStr = error.toString();

    if (errorStr.contains('permission') || errorStr.contains('Permission')) {
      bool isPermanentlyDenied = errorStr.contains('permanently') || errorStr.contains('settings');
      return PermissionException(
        title: "Permission Required",
        message: "Camera and Storage permissions are required to scan and save documents.",
        isPermanentlyDenied: isPermanentlyDenied,
      );
    }

    if (errorStr.contains('storage') || errorStr.contains('space')) {
      return StorageSpaceException();
    }

    if (errorStr.contains('QR code') || errorStr.contains('qr')) {
      return QrScanException(
        message: "No QR code detected in the selected image. Please make sure the code is well lit and readable.",
      );
    }

    // Clean up generic Exception prefix if present
    String cleanMessage = errorStr;
    if (cleanMessage.startsWith("Exception: ")) {
      cleanMessage = cleanMessage.substring(11);
    }

    return AppException(
      title: "Something Went Wrong",
      message: cleanMessage.isNotEmpty ? cleanMessage : "An unexpected error occurred. Please try again.",
    );
  }

  static AppException _parsePlatformException(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    if (code.contains('camera_access_denied') || 
        code.contains('photo_access_denied') || 
        code.contains('permission') ||
        message.contains('permission') ||
        message.contains('denied')) {
      return PermissionException(
        title: "Permission Denied",
        message: "Access to camera or gallery was denied. Please grant permission in App Settings.",
        isPermanentlyDenied: true,
      );
    }

    if (code.contains('camera') || message.contains('camera')) {
      return CameraException(
        message: "Unable to access camera. Please check if another app is using the camera and try again.",
      );
    }

    if (code.contains('storage') || message.contains('storage')) {
      return StorageSpaceException();
    }

    return AppException(
      title: "System Error",
      message: error.message ?? "A system error occurred. Please try again.",
    );
  }

  static AppException _parseDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        final responseData = error.response?.data;
        if (responseData is Map && responseData['message'] is String) {
          return AuthException(message: responseData['message'] as String);
        }
        return ServerException();
      case DioExceptionType.cancel:
        return AppException(
          title: "Request Cancelled",
          message: "The request was cancelled. Please try again.",
        );
      default:
        return NetworkException();
    }
  }
}
