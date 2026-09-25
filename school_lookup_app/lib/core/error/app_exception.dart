import 'package:flutter/material.dart';

/// Base class for all user-friendly application exceptions.
/// These exceptions carry clean, human-readable titles, messages, and actionable metadata.
class AppException implements Exception {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final bool isPermissionError;
  final bool isPermanentlyDenied;

  const AppException({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.actionLabel,
    this.isPermissionError = false,
    this.isPermanentlyDenied = false,
  });

  @override
  String toString() => message;
}

/// Thrown when camera or storage permission is denied or required.
class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.title = "Permission Required",
    super.isPermanentlyDenied = false,
  }) : super(
          icon: Icons.security,
          actionLabel: isPermanentlyDenied ? "Open Settings" : "Grant Permission",
          isPermissionError: true,
        );
}

/// Thrown when device storage space is insufficient or writing to file fails.
class StorageSpaceException extends AppException {
  StorageSpaceException({
    super.title = "Storage Error",
    super.message = "Insufficient storage space on your device. Please clear some space and try again.",
  }) : super(
          icon: Icons.sd_card_alert_rounded,
          actionLabel: "OK",
        );
}

/// Thrown when camera fails to initialize or capture.
class CameraException extends AppException {
  CameraException({
    super.title = "Camera Error",
    required super.message,
  }) : super(
          icon: Icons.camera_alt_outlined,
        );
}

/// Thrown when text recognition (OCR) fails.
class OcrException extends AppException {
  OcrException({
    super.title = "Text Recognition Failed",
    super.message = "Could not extract text from the image. Please make sure the image is clear and try again.",
  }) : super(
          icon: Icons.document_scanner_outlined,
        );
}

/// Thrown when QR code scanning fails or no QR code is found.
class QrScanException extends AppException {
  QrScanException({
    super.title = "QR Scan Error",
    super.message = "No valid QR code detected in the image. Please try again with a clear QR code.",
  }) : super(
          icon: Icons.qr_code_scanner_rounded,
        );
}

/// Thrown when network connection is missing or times out.
class NetworkException extends AppException {
  NetworkException({
    super.title = "Network Error",
    super.message = "No internet connection available. Please check your connection and try again.",
  }) : super(
          icon: Icons.wifi_off_rounded,
        );
}

/// Thrown when backend API or server returns an error.
class ServerException extends AppException {
  ServerException({
    super.title = "Server Error",
    super.message = "A server error occurred. Please try again later.",
  }) : super(
          icon: Icons.cloud_off_rounded,
        );
}

/// Thrown when user authentication fails.
class AuthException extends AppException {
  AuthException({
    super.title = "Authentication Failed",
    required super.message,
  }) : super(
          icon: Icons.lock_outline_rounded,
        );
}
