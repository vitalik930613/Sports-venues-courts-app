class CourtSchedule {
  final int id;
  final int courtId;
  final String openingTime;
  final String closingTime;
  final int gameDuration;
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
    final priceBrl = json['price_brl'];
    final priceUyu = json['price_uyu'];

    final double parsedPriceBrl = (priceBrl is num)
        ? priceBrl.toDouble()
        : double.parse(priceBrl as String);
    final double parsedPriceUyu = (priceUyu is num)
        ? priceUyu.toDouble()
        : double.parse(priceUyu as String);

    return CourtSchedule(
      id: json['id'] as int,
      courtId: json['court_id'] as int,
      openingTime: json['opening_time'] as String,
      closingTime: json['closing_time'] as String,
      gameDuration: json['game_duration'] as int,
      priceBrl: parsedPriceBrl,
      priceUyu: parsedPriceUyu,
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
