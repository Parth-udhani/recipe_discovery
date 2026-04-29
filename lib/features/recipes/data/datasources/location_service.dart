import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';

class LocationService {
  /// Returns a MealDB-compatible area string (e.g. "Indian", "American").
  ///
  /// Strategy (fastest / most VPN-friendly first):
  ///   1. IP-based geolocation  — works even through a VPN, zero permissions
  ///   2. GPS / device location — accurate but requires permission
  ///   3. null                  — caller falls back to time-based category
  Future<String?> getAreaCuisine() async {
    // Try IP geolocation first — no permission needed, VPN-aware
    final fromIp = await _getAreaFromIp();
    if (fromIp != null) {
      AppLogger.info('Location resolved via IP → $fromIp');
      return fromIp;
    }

    // Fall back to GPS
    final fromGps = await _getAreaFromGps();
    if (fromGps != null) {
      AppLogger.info('Location resolved via GPS → $fromGps');
      return fromGps;
    }

    AppLogger.warning('Location unavailable — will fall back to time-based category');
    return null;
  }

  // ── IP geolocation ────────────────────────────────────────────────────────

  Future<String?> _getAreaFromIp() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await dio.get('http://ip-api.com/json?fields=country');
      final country = response.data['country'] as String?;
      if (country == null || country.isEmpty) return null;

      final cuisine = AppConstants.countryToCuisine[country];
      AppLogger.debug('IP geo → country: "$country", cuisine: "${cuisine ?? "not mapped"}"');
      return cuisine;
    } catch (e) {
      AppLogger.warning('IP geolocation failed: $e');
      return null;
    }
  }

  // ── GPS geolocation ───────────────────────────────────────────────────────

  Future<String?> _getAreaFromGps() async {
    try {
      final hasPermission = await _checkGpsPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final country = placemarks.first.country ?? '';
      final cuisine = AppConstants.countryToCuisine[country];
      AppLogger.debug('GPS geo → country: "$country", cuisine: "${cuisine ?? "not mapped"}"');
      return cuisine;
    } catch (e) {
      AppLogger.warning('GPS geolocation failed: $e');
      return null;
    }
  }

  Future<bool> _checkGpsPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }
}