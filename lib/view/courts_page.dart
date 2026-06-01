import 'package:flutter/material.dart';
import 'package:mobile/model/establishment.dart';
import 'package:mobile/model/court.dart';
import 'package:mobile/utils/image_utils.dart';
import 'package:mobile/view/court_detail_page.dart';
import 'package:mobile/viewmodel/court_viewmodel.dart';

class CourtsPage extends StatefulWidget {
  final Establishment establishment;
  const CourtsPage({super.key, required this.establishment});

  @override
  State<CourtsPage> createState() => _CourtsPageState();
}

class _CourtsPageState extends State<CourtsPage> {
  final CourtViewModel _viewModel = CourtViewModel();
  List<Court> _courts = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final courts = await _viewModel.fetchCourtsByEstablishment(
        widget.establishment.id,
      );
      setState(() {
        _courts = courts;
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
        title: Text(widget.establishment.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text('Erro: $_error'))
          : _courts.isEmpty
          ? const Center(child: Text('Nenhuma quadra encontrada'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _courts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final court = _courts[index];
                return _CourtCard(
                  court: court,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourtDetailPage(
                          court: court,
                          establishment: widget.establishment,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final Court court;
  final VoidCallback onTap;

  const _CourtCard({required this.court, required this.onTap});

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
                image: court.photo != null
                    ? DecorationImage(
                        image: NetworkImage(court.photo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: court.photo == null
                  ? Image.asset(
                      getDefaultSportImage(court.sport),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sportName(court.sport),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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

  String _sportName(Sport sport) {
    switch (sport) {
      case Sport.soccer:
        return 'Futebol';
      case Sport.futsal:
        return 'Futsal';
      case Sport.padel:
        return 'Padel';
      case Sport.tennis:
        return 'Tênis';
    }
  }
}
