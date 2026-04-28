import 'package:flutter/material.dart';

class Court {
  final int id;
  final String name;
  final double priceRS;
  final double priceUYU;
  final String imageUrl;
  final double rating;
  final double distance;

  Court({
    required this.id,
    required this.name,
    required this.priceRS,
    required this.priceUYU,
    required this.imageUrl,
    required this.rating,
    required this.distance,
  });
}

class TimeSlot {
  final String time;
  bool isAvailable;
  bool isSelected;

  TimeSlot({
    required this.time,
    this.isAvailable = true,
    this.isSelected = false,
  });
}

const String logoAsset = 'assets/images/cancha_logo.png';

final List<Court> mockCourts = [
  Court(
    id: 1,
    name: 'Quadra 1',
    priceRS: 150.00,
    priceUYU: 1350.00,
    imageUrl: 'https://altipisos.com.br/wp-content/uploads/2021/04/site-1.jpg',
    rating: 4.8,
    distance: 1.2,
  ),
  Court(
    id: 2,
    name: 'Quadra 2',
    priceRS: 120.00,
    priceUYU: 1080.00,
    imageUrl: 'https://altipisos.com.br/wp-content/uploads/2021/04/site-1.jpg',
    rating: 4.5,
    distance: 2.5,
  ),
  Court(
    id: 3,
    name: 'Quadra 3',
    priceRS: 180.00,
    priceUYU: 1620.00,
    imageUrl: 'https://altipisos.com.br/wp-content/uploads/2021/04/site-1.jpg',
    rating: 4.9,
    distance: 0.8,
  ),
  Court(
    id: 4,
    name: 'Quadra 4',
    priceRS: 130.00,
    priceUYU: 1170.00,
    imageUrl:
        'https://quadraspoliesportivas.com.br/wp-content/uploads/2023/03/construcao-de-quadras-abertas-e-cobertas-de-futebol-em-curitiba-7.jpg',
    rating: 4.6,
    distance: 3.1,
  ),
];

final List<TimeSlot> mockTimeSlots = List.generate(48, (index) {
  int hour = 8 + (index ~/ 6);
  int minute = (index % 6) * 10;
  String time =
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  bool isAvailable =
      index != 2 &&
      index != 3 &&
      index != 15 &&
      index != 16 &&
      index != 27 &&
      index != 28 &&
      index != 39 &&
      index != 40 &&
      index != 45;
  return TimeSlot(time: time, isAvailable: isAvailable);
});

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Court> _displayedCourts = List.from(mockCourts);
  String _currentFilter = '';

  void _applyFilter(String filterType) {
    setState(() {
      _currentFilter = filterType;
      switch (filterType) {
        case 'Proximidade':
          _displayedCourts.sort((a, b) => a.distance.compareTo(b.distance));
          break;
        case 'Preço: Baixo-Alto':
          _displayedCourts.sort((a, b) => a.priceRS.compareTo(b.priceRS));
          break;
        case 'Preço: Alto-Baixo':
          _displayedCourts.sort((a, b) => b.priceRS.compareTo(a.priceRS));
          break;
        case 'Filtro (Avaliação)':
          _displayedCourts = mockCourts
              .where((court) => court.rating >= 4.7)
              .toList();
          break;
        default:
          _displayedCourts = List.from(mockCourts);
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedCourts = List.from(mockCourts);
      } else {
        _displayedCourts = mockCourts
            .where(
              (court) => court.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Image.asset(logoAsset, height: 100))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome da quadra...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterButton('Proximidade', Icons.my_location),
                    _buildFilterButton(
                      'Preço: Baixo-Alto',
                      Icons.arrow_downward,
                    ),
                    _buildFilterButton('Preço: Alto-Baixo', Icons.arrow_upward),
                    _buildFilterButton(
                      'Filtro (Avaliação)',
                      Icons.star_rate_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _displayedCourts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) =>
                  CourtCard(court: _displayedCourts[index]),
            ),
          ),
          Container(
            height: 60,
            color: Colors.green.shade600,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: Colors.white, size: 30),
                SizedBox(width: 40),
                Icon(Icons.calendar_today, color: Colors.white54, size: 28),
                SizedBox(width: 40),
                Icon(Icons.person, color: Colors.white54, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, IconData icon) {
    bool isSelected = _currentFilter == text;
    return GestureDetector(
      onTap: () => _applyFilter(text),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        width: MediaQuery.of(context).size.width / 4 - 14,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.green : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Colors.green.shade800
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CourtCard extends StatelessWidget {
  final Court court;
  const CourtCard({super.key, required this.court});

  String _formatCurrency(double value, String symbol) {
    return '$symbol ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(court: court)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                image: DecorationImage(
                  image: NetworkImage(court.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
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
                  const SizedBox(height: 12),
                  Text(
                    _formatCurrency(court.priceRS, 'R\$'),
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  Text(
                    _formatCurrency(court.priceUYU, 'UYU'),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        court.rating.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.my_location,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${court.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final Court court;
  const DetailPage({super.key, required this.court});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  DateTime? _selectedDate;
  int? _selectedTimeIndex;
  List<TimeSlot> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _timeSlots = List.generate(
      mockTimeSlots.length,
      (index) => TimeSlot(
        time: mockTimeSlots[index].time,
        isAvailable: mockTimeSlots[index].isAvailable,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeIndex = null;
        _resetTimeSlotsForNewDate();
      });
    }
  }

  void _resetTimeSlotsForNewDate() {
    setState(() {
      _timeSlots = List.generate(
        mockTimeSlots.length,
        (index) => TimeSlot(
          time: mockTimeSlots[index].time,
          isAvailable: (index % 5 != 0) && (index != 1) && (index != 22),
        ),
      );
    });
  }

  void _onTimeSelected(int index) {
    setState(() {
      if (_selectedTimeIndex != null)
        _timeSlots[_selectedTimeIndex!].isSelected = false;
      _selectedTimeIndex = index;
      _timeSlots[index].isSelected = true;
    });
  }

  String _formatCurrency(double value, String symbol) {
    return '$symbol ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Image.asset(logoAsset, height: 100)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      image: DecorationImage(
                        image: NetworkImage(widget.court.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.court.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatCurrency(widget.court.priceRS, 'R\$'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatCurrency(widget.court.priceUYU, 'UYU'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data desejada:',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedDate == null
                                    ? 'Selecione uma data...'
                                    : _formatDate(_selectedDate!),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedDate == null
                                      ? Colors.grey.shade500
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.calendar_month,
                            color: Colors.green.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedDate != null) ...[
                    const Text(
                      'Horários disponíveis (Arraste para o lado)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 380,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                              childAspectRatio: 1.5,
                            ),
                        itemCount: _timeSlots.length,
                        itemBuilder: (context, index) => TimeBox(
                          slot: _timeSlots[index],
                          onTap: () => _onTimeSelected(index),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: (_selectedDate != null && _selectedTimeIndex != null)
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reserva solicitada em ${_formatDate(_selectedDate!)} às ${_timeSlots[_selectedTimeIndex!].time}',
                          ),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CONFIRMAR RESERVA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            color: Colors.green.shade600,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: Colors.white54, size: 28),
                SizedBox(width: 40),
                Icon(Icons.calendar_today, color: Colors.white, size: 30),
                SizedBox(width: 40),
                Icon(Icons.person, color: Colors.white54, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeBox extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onTap;
  const TimeBox({super.key, required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.grey.shade200;
    Color textColor = Colors.black;

    if (!slot.isAvailable) {
      backgroundColor = Colors.grey.shade500;
      textColor = Colors.grey.shade200;
    } else if (slot.isSelected) {
      backgroundColor = Colors.green.shade600;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: slot.isAvailable ? onTap : null,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: slot.isSelected
                ? Colors.green.shade700
                : Colors.grey.shade300,
            width: slot.isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          slot.time,
          style: TextStyle(
            fontSize: 12,
            fontWeight: slot.isSelected ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
