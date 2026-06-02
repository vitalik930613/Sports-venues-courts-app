import 'package:flutter/material.dart';
import 'package:mobile/view/courts_page.dart';
import 'package:mobile/view/wearable/wearable_screen.dart';
import 'package:mobile/viewmodel/establishment_viewmodel.dart';
import 'package:mobile/model/establishment.dart';

class EstablishmentsPage extends StatefulWidget {
  const EstablishmentsPage({super.key});

  @override
  State<EstablishmentsPage> createState() => _EstablishmentsPageState();
}

class _EstablishmentsPageState extends State<EstablishmentsPage> {
  final EstablishmentViewModel _viewModel = EstablishmentViewModel();
  List<Establishment> _establishments = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadEstablishments();
  }

  Future<void> _loadEstablishments() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final establishments = await _viewModel.fetchEstablishments();
      setState(() {
        _establishments = establishments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('assets/images/cancha_logo.png', height: 60),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text('Erro: $_error'))
          : _establishments.isEmpty
          ? const Center(child: Text('Nenhum estabelecimento encontrado'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _establishments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final est = _establishments[index];
                return _EstablishmentCard(
                  establishment: est,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourtsPage(establishment: est),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WearableScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.watch, color: Colors.white),
      ),
    );
  }
}

class _EstablishmentCard extends StatelessWidget {
  final Establishment establishment;
  final VoidCallback onTap;

  const _EstablishmentCard({required this.establishment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                image: establishment.photo != null
                    ? DecorationImage(
                        image: NetworkImage(establishment.photo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: establishment.photo == null
                  ? const Icon(Icons.sports_soccer, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    establishment.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Lat: ${establishment.latitude}, Lng: ${establishment.longitude}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
