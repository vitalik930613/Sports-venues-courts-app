enum BookingStatus { confirmed, canceled }

class CourtBooking {
  final int id;
  final int courtId;
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;

  CourtBooking({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory CourtBooking.fromJson(Map<String, dynamic> json) {
    return CourtBooking(
      id: json['id'] as int,
      courtId: json['court_id'] as int,
      userId: json['user_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: _statusFromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court_id': courtId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': _statusToString(status),
    };
  }

  static BookingStatus _statusFromString(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'canceled':
        return BookingStatus.canceled;
      default:
        throw ArgumentError('Status inválido: $value');
    }
  }

  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.canceled:
        return 'canceled';
    }
  }
}
