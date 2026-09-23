class Profile {
  final String id;
  final String? username;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final double? latitude;
  final double? longitude;

  const Profile({
    required this.id,
    this.username,
    this.fullName,
    this.phone,
    this.address,
    this.avatarUrl,
    this.latitude,
    this.longitude,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}
