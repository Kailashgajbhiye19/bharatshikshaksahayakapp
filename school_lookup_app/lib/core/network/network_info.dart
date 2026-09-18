import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkInfoProvider = Provider((ref) => NetworkInfo(InternetConnectionChecker()));

/// [NetworkInfo] checks for active internet connectivity.
class NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  NetworkInfo(this.connectionChecker);

  Future<bool> get isConnected => connectionChecker.hasConnection;
}
