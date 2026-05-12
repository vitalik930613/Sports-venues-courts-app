import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../viewmodel/map_viewmodel.dart';

class MapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String name;

  const MapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapViewModel _viewModel;
  late MapController _mapController;
  late LatLng _destination;

  @override
  void initState() {
    super.initState();
    _viewModel = MapViewModel();
    _mapController = MapController();
    _destination = LatLng(widget.latitude, widget.longitude);
    _viewModel.setDestination(_destination);
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _centralizarNoUsuario() {
    if (_viewModel.currentPosition != null) {
      _mapController.move(_viewModel.currentPosition!, 15);
    }
  }

  void _ajustarMapaParaRota() {
    if (_viewModel.routePoints.isEmpty) return;
    double minLat = _viewModel.routePoints
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = _viewModel.routePoints
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = _viewModel.routePoints
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = _viewModel.routePoints
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  Future<void> _onGetLocation() async {
    await _viewModel.obterMinhaLocalizacao();
    if (_viewModel.currentPosition != null && mounted) {
      _centralizarNoUsuario();
    } else if (_viewModel.errorMessage != null && mounted) {
      _showSnackBar(_viewModel.errorMessage!, Colors.red);
    }
  }

  Future<void> _onGetRoute() async {
    if (_viewModel.currentPosition == null) {
      _showSnackBar('Obtenha sua localização primeiro', Colors.orange);
      return;
    }
    await _viewModel.calcularRota();
    if (_viewModel.routePoints.isNotEmpty && mounted) {
      _ajustarMapaParaRota();
    } else if (_viewModel.errorMessage != null && mounted) {
      _showSnackBar(_viewModel.errorMessage!, Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _destination,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.mobile',
                maxZoom: 20,
                maxNativeZoom: 19,
              ),
              if (_viewModel.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _viewModel.routePoints,
                      color: Colors.blue,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              if (_viewModel.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _viewModel.currentPosition!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _destination,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'destination',
                  onPressed: () => _mapController.move(_destination, 15),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.place, color: Colors.red),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'locate',
                  onPressed: _viewModel.loading ? null : _onGetLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.green),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'route',
                  onPressed: _viewModel.loading ? null : _onGetRoute,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.route, color: Colors.blue),
                ),
              ],
            ),
          ),
          if (_viewModel.loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
