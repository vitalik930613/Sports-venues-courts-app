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

  Future<List<CourtBooking>> fetchUserBookings() async {
    final data = await _api.get('/court-bookings/user');
    if (data is List) {
      return data.map((json) => CourtBooking.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> cancelBooking(int bookingId) async {
    await _api.patch('/court-bookings/$bookingId', {'status': 'canceled'});
  }

  Future<Map<int, String>> fetchCourtsMap() async {
    final data = await _api.get('/courts');
    if (data is List) {
      return {for (var c in data) c['id'] as int: c['name'] as String};
    }
    return {};
  }

  Future<List<CourtBooking>> fetchBookingsByCourtAndDate(
    int courtId,
    DateTime date,
  ) async {
    final data = await _api.get('/court-bookings/court/$courtId');
    if (data is List) {
      final bookings = data.map((json) => CourtBooking.fromJson(json)).toList();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      return bookings
          .where(
            (b) =>
                b.status == BookingStatus.confirmed &&
                b.startTime.isAfter(startOfDay) &&
                b.startTime.isBefore(endOfDay),
          )
          .toList();
    }
    return [];
  }
}
