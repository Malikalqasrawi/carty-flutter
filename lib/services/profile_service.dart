import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  /// Returns null if the profile row does not exist yet.
  Future<Profile?> fetch() async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', _userId)
        .maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  /// Creates the row if missing, otherwise updates it.
  Future<Profile> save({
    required String fullName,
    required String phone,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final row = await _client
        .from('profiles')
        .upsert({
          'id': _userId,
          'full_name': fullName,
          'phone': phone,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select()
        .single();
    return Profile.fromMap(row);
  }
}
