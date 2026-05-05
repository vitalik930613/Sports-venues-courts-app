import '../services/api_client.dart';
import '../model/court_booking.dart';

class BookingViewModel {
  final ApiClient _api = ApiClient();

  Future<CourtBooking> createBooking({
    required int courtId,
    required int userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final body = {
      'court_id': courtId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
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
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
    final data = await _api.post('/court-bookings/check-availability', body);
    return data['available'] ?? false;
  }
}
