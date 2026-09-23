import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme.dart';
import '../models/picked_location.dart';
import '../services/location_service.dart';

/// Full-screen map with a pin fixed in the centre (like Talabat).
/// The user drags the map under the pin, then taps "Confirm location".
///
/// Usage:
///   final picked = await Navigator.push<PickedLocation>(context,
///       MaterialPageRoute(builder: (_) => const MapPickerScreen()));
class MapPickerScreen extends StatefulWidget {
  /// Where to start (e.g. the previously saved location).
  final LatLng? initial;

  const MapPickerScreen({super.key, this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _mapController = MapController();
  final _locationService = LocationService();

  late LatLng _center = widget.initial ?? LocationService.amman;
  String? _address;
  bool _loadingAddress = false;
  bool _dragging = false;
  bool _locating = false;
  Timer? _debounce;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapReady() {
    if (widget.initial == null) {
      _goToMyLocation(); // start where the user is
    } else {
      _lookUpAddress();
    }
  }

  /// Called on every tiny map movement. We wait until the user stops
  /// moving for 600 ms before asking for the address.
  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _center = camera.center;
    if (!_dragging) setState(() => _dragging = true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _dragging = false);
      _lookUpAddress();
    });
  }

  Future<void> _lookUpAddress() async {
    final id = ++_requestId;
    setState(() => _loadingAddress = true);
    final address = await _locationService.addressFor(_center);
    // Ignore old answers if the map moved again meanwhile.
    if (!mounted || id != _requestId) return;
    setState(() {
      _address = address;
      _loadingAddress = false;
    });
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    final position = await _locationService.currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get your location. Turn on GPS or move the map.'),
        ),
      );
      _lookUpAddress();
      return;
    }
    _mapController.move(position, 17);
  }

  void _confirm() {
    final text = _address ??
        '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}';
    Navigator.pop(
      context,
      PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose delivery location')),
      body: Stack(
        children: [
          // ---------- The map ----------
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: widget.initial == null ? 12 : 17,
              minZoom: 5,
              maxZoom: 19,
              onMapReady: _onMapReady,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Required by OpenStreetMap's tile usage policy.
                userAgentPackageName: 'com.example.flutterprojectfinal',
              ),
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
            ],
          ),

          // ---------- Pin fixed in the centre ----------
          // IgnorePointer lets touches pass through to the map.
          IgnorePointer(
            child: Center(
              child: AnimatedSlide(
                // Lift the pin a little while dragging, like Talabat.
                offset: Offset(0, _dragging ? -0.75 : -0.5),
                duration: const Duration(milliseconds: 150),
                child: const Icon(
                  Icons.location_on,
                  size: 52,
                  color: AppColors.error,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black38)],
                ),
              ),
            ),
          ),

          // ---------- "My location" button ----------
          Positioned(
            right: 16,
            bottom: 190,
            child: FloatingActionButton(
              heroTag: 'my-location',
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              onPressed: _locating ? null : _goToMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // ---------- Address card + confirm ----------
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dragging || _loadingAddress
                                  ? 'Finding address...'
                                  : (_address ?? 'Move the map to place the pin'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _dragging ? null : _confirm,
                        child: const Text('Confirm location'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
