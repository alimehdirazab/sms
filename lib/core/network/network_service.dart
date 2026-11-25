import 'dart:async';
import 'dart:io';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  /// Check if the device currently has active internet connectivity
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('api.nexira.pk')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final fallback = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        return fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }
}
