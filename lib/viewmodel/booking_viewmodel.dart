import '../services/api_client.dart';
import '../model/court_booking.dart';

class BookingViewModel {
  final ApiClient _api = ApiClient();

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Future<CourtBooking> createBooking({
    required int courtId,
    required int userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final body = {
      'court_id': courtId,
      'user_id': userId,
      'start_time': _formatDateTime(startTime),
      'end_time': _formatDateTime(endTime),
      'status': 'confirmed',
    };
    final data = await _api.post('/court-bookings', body);
    return CourtBooking.fromJson(data);
  }

  Future<bool> checkAvailability({
    required int courtId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final body = {
      'court_id': courtId,
      'start_time': _formatDateTime(startTime),
      'end_time': _formatDateTime(endTime),
    };
    final data = await _api.post('/court-bookings/check-availability', body);
    return data['available'] ?? false;
  }
}
