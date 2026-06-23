import 'package:flutter/material.dart';
import 'package:mobile/utils/geocoding_helper.dart';
import 'package:mobile/utils/theme_utils.dart';
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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(ThemeUtils.getLogoPath(context), height: 60),
        ),
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
        backgroundColor: primary,
        child: const Icon(Icons.watch, color: Colors.white),
      ),
    );
  }
}

class _EstablishmentCard extends StatefulWidget {
  final Establishment establishment;
  final VoidCallback onTap;

  const _EstablishmentCard({required this.establishment, required this.onTap});

  @override
  State<_EstablishmentCard> createState() => _EstablishmentCardState();
}

class _EstablishmentCardState extends State<_EstablishmentCard> {
  String _address = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final address = await GeocodingHelper.getAddress(
      widget.establishment.latitude,
      widget.establishment.longitude,
    );
    if (mounted) {
      setState(() {
        _address = address;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                image: widget.establishment.photo != null
                    ? DecorationImage(
                        image: NetworkImage(widget.establishment.photo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.establishment.photo == null
                  ? const Icon(Icons.sports_soccer, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.establishment.name,
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
                      Expanded(
                        child: Text(
                          _loading ? 'Carregando endereço...' : _address,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurface,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
