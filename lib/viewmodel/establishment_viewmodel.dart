import '../services/api_client.dart';
import '../model/establishment.dart';

class EstablishmentViewModel {
  final ApiClient _api = ApiClient();

  Future<List<Establishment>> fetchEstablishments() async {
    final data = await _api.get('/establishments');
    if (data is List) {
      return data.map((json) => Establishment.fromJson(json)).toList();
    }
    return [];
  }
}
