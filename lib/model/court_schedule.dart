class CourtSchedule {
  final int id;
  final int courtId;
  final String openingTime; // "HH:MM:SS"
  final String closingTime;
  final int gameDuration; // minutes
  final double priceBrl;
  final double priceUyu;

  CourtSchedule({
    required this.id,
    required this.courtId,
    required this.openingTime,
    required this.closingTime,
    required this.gameDuration,
    required this.priceBrl,
    required this.priceUyu,
  });

  factory CourtSchedule.fromJson(Map<String, dynamic> json) {
    return CourtSchedule(
      id: json['id'] as int,
      courtId: json['court_id'] as int,
      openingTime: json['opening_time'] as String,
      closingTime: json['closing_time'] as String,
      gameDuration: json['game_duration'] as int,
      priceBrl: (json['price_brl'] as num).toDouble(),
      priceUyu: (json['price_uyu'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court_id': courtId,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'game_duration': gameDuration,
      'price_brl': priceBrl,
      'price_uyu': priceUyu,
    };
  }
}
