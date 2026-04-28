import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    AppLogger.info( 'Initializing connectivity listener...');

    _connectivity.onConnectivityChanged.listen((results) {
      final connected = _hasConnection(results);
      final types = results.map((r) => r.name).join(', ');

      if (connected) {
        AppLogger.debug( 'Connection RESTORED → types: [$types]');
      } else {
        AppLogger.warning('Connection LOST → types: [$types]');
      }

      _controller.add(connected);
    });

    AppLogger.debug('Connectivity listener registered ✓');
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
    r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  Future<bool> get isConnected async {
    AppLogger.info('Checking current connectivity status...');
    final results = await _connectivity.checkConnectivity();
    final connected = _hasConnection(results);
    final types = results.map((r) => r.name).join(', ');

    if (connected) {
      AppLogger.debug( 'Device is ONLINE → [$types]');
    } else {
      AppLogger.warning( 'Device is OFFLINE → [$types]');
    }

    return connected;
  }

  void dispose() {
    AppLogger.info( 'Disposing connectivity stream controller...');
    _controller.close();
    AppLogger.debug( 'ConnectivityService disposed ✓');
  }
}