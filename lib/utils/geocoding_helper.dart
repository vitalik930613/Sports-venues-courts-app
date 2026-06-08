import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingHelper {
  static Future<String> getAddress(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final String? rua =
              address['road'] ?? address['pedestrian'] ?? address['footway'];
          final String? bairro =
              address['suburb'] ??
              address['neighbourhood'] ??
              address['quarter'];
          final String? cidade =
              address['city'] ?? address['town'] ?? address['village'];

          final List<String> parts = [];
          if (rua != null && rua.isNotEmpty) parts.add(rua);
          if (bairro != null && bairro.isNotEmpty) parts.add(bairro);
          if (cidade != null && cidade.isNotEmpty) parts.add(cidade);

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
        return data['display_name'] ?? 'Endereço não disponível';
      }
      return 'Endereço não encontrado';
    } catch (e) {
      return 'Erro de conexão';
    }
  }
}
