import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapViewModel extends ChangeNotifier {
  LatLng? _currentPosition;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _loading = false;
  String? _errorMessage;

  LatLng? get currentPosition => _currentPosition;
  List<LatLng> get routePoints => _routePoints;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  void setDestination(LatLng destination) {
    _destination = destination;
  }

  Future<void> obterMinhaLocalizacao() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Serviço de localização desativado.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Permissão de localização negada.';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Permissão de localização negada permanentemente.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = 'Erro ao obter localização: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> calcularRota() async {
    if (_currentPosition == null || _destination == null) {
      _errorMessage = 'Defina origem e destino primeiro.';
      notifyListeners();
      return;
    }

    _loading = true;
    _routePoints = [];
    _errorMessage = null;
    notifyListeners();

    try {
      final origin =
          '${_currentPosition!.longitude},${_currentPosition!.latitude}';
      final destination =
          '${_destination!.longitude},${_destination!.latitude}';
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$origin;$destination'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Falha na requisição da rota');
      }

      final data = jsonDecode(response.body);
      if (data['routes'] == null || data['routes'].isEmpty) {
        throw Exception('Nenhuma rota encontrada');
      }

      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      // OSRM retorna [lon, lat] -> converter para LatLng (lat, lon)
      _routePoints = coordinates
          .map<LatLng>(
            (coord) => LatLng(coord[1] as double, coord[0] as double),
          )
          .toList();
    } catch (e) {
      _errorMessage = 'Erro ao calcular rota: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
