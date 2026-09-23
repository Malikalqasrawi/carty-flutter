import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// GPS position + turning coordinates into a readable address.
/// Uses OpenStreetMap's free Nominatim service (no API key needed).
class LocationService {
  /// Used when GPS is off or permission is denied.
  static const amman = LatLng(31.9539, 35.9106);

  /// Nominatim's usage policy asks every app to identify itself.
  static const _userAgent = 'Carty/1.0 (Flutter student portfolio app)';

  final http.Client _client;

  LocationService([http.Client? client]) : _client = client ?? http.Client();

  /// Returns the phone's current position, or null if GPS is off
  /// or the user refused permission.
  Future<LatLng?> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      // Timed out: fall back to the last known position if there is one.
      final last = await Geolocator.getLastKnownPosition();
      return last == null ? null : LatLng(last.latitude, last.longitude);
    }
  }

  /// Example result: "Wasfi Al-Tal Street, Khalda, Amman".
  /// Returns null if there is no internet or nothing was found.
  Future<String?> addressFor(LatLng point) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': point.latitude.toStringAsFixed(6),
      'lon': point.longitude.toStringAsFixed(6),
      'format': 'jsonv2',
      'zoom': '18',
      'accept-language': 'en',
    });

    try {
      final response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final parts = (json['address'] ?? {}) as Map<String, dynamic>;

      // Build a short address from the most useful parts only.
      final pieces = <String>[
        for (final key in ['road', 'neighbourhood', 'suburb'])
          if (parts[key] is String) parts[key] as String,
        (parts['city'] ?? parts['town'] ?? parts['village'] ?? '') as String,
      ].where((p) => p.isNotEmpty).toList();

      if (pieces.isEmpty) return json['display_name'] as String?;
      return pieces.join(', ');
    } catch (_) {
      return null;
    }
  }
}
