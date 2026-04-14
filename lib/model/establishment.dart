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
    return Establishment(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
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
