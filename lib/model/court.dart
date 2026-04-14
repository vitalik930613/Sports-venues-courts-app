enum Sport { soccer, futsal, padel, tennis }

class Court {
  final int id;
  final String name;
  final int establishmentId;
  final Sport sport;
  final String? photo;

  Court({
    required this.id,
    required this.name,
    required this.establishmentId,
    required this.sport,
    this.photo,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as int,
      name: json['name'] as String,
      establishmentId: json['establishment_id'] as int,
      sport: _sportFromString(json['sport'] as String),
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'establishment_id': establishmentId,
      'sport': _sportToString(sport),
      'photo': photo,
    };
  }

  static Sport _sportFromString(String value) {
    switch (value) {
      case 'soccer':
        return Sport.soccer;
      case 'futsal':
        return Sport.futsal;
      case 'padel':
        return Sport.padel;
      case 'tennis':
        return Sport.tennis;
      default:
        throw ArgumentError('Esporte inválido: $value');
    }
  }

  static String _sportToString(Sport sport) {
    switch (sport) {
      case Sport.soccer:
        return 'soccer';
      case Sport.futsal:
        return 'futsal';
      case Sport.padel:
        return 'padel';
      case Sport.tennis:
        return 'tennis';
    }
  }
}
