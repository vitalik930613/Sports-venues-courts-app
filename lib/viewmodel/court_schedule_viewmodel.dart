// lib/viewmodel/court_schedule_viewmodel.dart
import '../services/api_client.dart';
import '../model/court_schedule.dart';

class CourtScheduleViewModel {
  final ApiClient _api = ApiClient();

  Future<CourtSchedule?> fetchScheduleByCourtId(int courtId) async {
    try {
      final data = await _api.get('/court-schedules/court/$courtId');
      if (data is List && data.isNotEmpty) {
        return CourtSchedule.fromJson(data[0]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
