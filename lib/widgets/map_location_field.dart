import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme.dart';
import '../models/picked_location.dart';
import '../screens/map_picker_screen.dart';

/// "Choose on map" button. Once a location is picked it shows a small
/// map preview with the pin, and a "Change" button.
///
/// [onPicked] gets the new location (coordinates + address text).
class MapLocationField extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final ValueChanged<PickedLocation> onPicked;

  const MapLocationField({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onPicked,
  });

  bool get _hasLocation => latitude != null && longitude != null;

  Future<void> _openPicker(BuildContext context) async {
    final picked = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initial: _hasLocation ? LatLng(latitude!, longitude!) : null,
        ),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLocation) {
      return OutlinedButton.icon(
        onPressed: () => _openPicker(context),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.map_outlined),
        label: const Text('Choose on map'),
      );
    }

    final point = LatLng(latitude!, longitude!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 140,
        child: Stack(
          children: [
            // Small map preview; not draggable, tap opens the picker.
            FlutterMap(
              // Key forces a rebuild when the location changes.
              key: ValueKey(point),
              options: MapOptions(
                initialCenter: point,
                initialZoom: 16,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutterprojectfinal',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on,
                          size: 40, color: AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
            // Transparent layer: tapping anywhere on the preview opens the picker.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: () => _openPicker(context)),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: FilledButton.icon(
                onPressed: () => _openPicker(context),
                icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: const Text('Change'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
