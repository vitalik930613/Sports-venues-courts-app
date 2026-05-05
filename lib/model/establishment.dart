class Establishment {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int ownerId;
  final List<int> workingDays;
  final String? photo;

  Establishment({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    required this.workingDays,
    this.photo,
  });

  factory Establishment.fromJson(Map<String, dynamic> json) {
    final lat = json['latitude'];
    final lng = json['longitude'];

    final double latitude = (lat is num)
        ? lat.toDouble()
        : double.parse(lat as String);
    final double longitude = (lng is num)
        ? lng.toDouble()
        : double.parse(lng as String);

    return Establishment(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: latitude,
      longitude: longitude,
      ownerId: json['owner_id'] as int,
      workingDays: (json['working_days'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      photo: json['photo'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'owner_id': ownerId,
      'working_days': workingDays,
      'photo': photo,
    };
  }
}
