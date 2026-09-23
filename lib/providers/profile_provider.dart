import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;

  ProfileProvider(this._service);

  Profile? _profile;
  bool _isSaving = false;

  Profile? get profile => _profile;
  bool get isSaving => _isSaving;

  /// Saved delivery address, used to pre-fill Checkout.
  String get address => _profile?.address ?? '';
  double? get latitude => _profile?.latitude;
  double? get longitude => _profile?.longitude;

  Future<void> load() async {
    try {
      _profile = await _service.fetch();
    } catch (_) {
      // Profile is optional; the app still works without it.
    }
    notifyListeners();
  }

  /// Returns true on success.
  Future<bool> save({
    required String fullName,
    required String phone,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    _isSaving = true;
    notifyListeners();
    try {
      _profile = await _service.save(
        fullName: fullName,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearLocal() {
    _profile = null;
    notifyListeners();
  }
}
