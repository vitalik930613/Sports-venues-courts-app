import '../services/api_client.dart';
import '../model/court.dart';

class CourtViewModel {
  final ApiClient _api = ApiClient();

  Future<List<Court>> fetchCourtsByEstablishment(int establishmentId) async {
    final data = await _api.get('/courts/establishment/$establishmentId');
    if (data is List) {
      return data.map((json) => Court.fromJson(json)).toList();
    }
    return [];
  }

  Future<Court> fetchCourtById(int id) async {
    final data = await _api.get('/courts/$id');
    return Court.fromJson(data);
  }

  Future<List<Court>> fetchAllCourts() async {
    final data = await _api.get('/courts');
    if (data is List) {
      return data.map((json) => Court.fromJson(json)).toList();
    }
    return [];
  }
}
