import 'package:flutter/material.dart';
import 'package:mobile/model/court.dart';
import 'package:mobile/model/court_schedule.dart';
import 'package:mobile/utils/image_utils.dart';
import 'package:mobile/viewmodel/auth_viewmodel.dart';
import 'package:mobile/viewmodel/court_schedule_viewmodel.dart';
import 'package:mobile/viewmodel/booking_viewmodel.dart';

class CourtDetailPage extends StatefulWidget {
  final Court court;
  const CourtDetailPage({super.key, required this.court});

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  final CourtScheduleViewModel _scheduleVM = CourtScheduleViewModel();
  final BookingViewModel _bookingVM = BookingViewModel();
  CourtSchedule? _schedule;
  bool _loadingSchedule = true;
  String _error = '';

  DateTime? _selectedDate;
  int? _selectedSlotIndex;
  List<TimeSlot> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _loadingSchedule = true);
    try {
      final data = await _scheduleVM.fetchScheduleByCourtId(widget.court.id);
      if (data != null) {
        setState(() {
          _schedule = data;
          _loadingSchedule = false;
        });
      } else {
        setState(() {
          _error = 'Horário não configurado para esta quadra.';
          _loadingSchedule = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar horário: ${e.toString()}';
        _loadingSchedule = false;
      });
      print('Erro ao buscar schedule: $e');
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlotIndex = null;
        _generateTimeSlots(picked);
      });
    }
  }

  void _generateTimeSlots(DateTime date) {
    if (_schedule == null) return;
    final slots = <TimeSlot>[];
    final opening = _parseTime(_schedule!.openingTime);
    final closing = _parseTime(_schedule!.closingTime);
    final duration = _schedule!.gameDuration; // em minutos

    DateTime current = DateTime(
      date.year,
      date.month,
      date.day,
      opening.hour,
      opening.minute,
    );
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      closing.hour,
      closing.minute,
    );

    while (current.add(Duration(minutes: duration)).isBefore(endOfDay) ||
        current.add(Duration(minutes: duration)).isAtSameMomentAs(endOfDay)) {
      final start = current;
      final end = current.add(Duration(minutes: duration));
      slots.add(
        TimeSlot(
          startTime: start,
          endTime: end,
          isAvailable: true, // será verificado depois
          isSelected: false,
        ),
      );
      current = end;
    }

    _timeSlots = slots;
    // Opcional: verificar disponibilidade em lote (simplificado, faremos na reserva)
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _onSlotSelected(int index) {
    setState(() {
      if (_selectedSlotIndex != null) {
        _timeSlots[_selectedSlotIndex!].isSelected = false;
      }
      _selectedSlotIndex = index;
      _timeSlots[index].isSelected = true;
    });
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedSlotIndex == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione data e horário')));
      return;
    }

    final slot = _timeSlots[_selectedSlotIndex!];
    final userId = AuthViewModel.instance.currentUser!.id;

    setState(() => _loadingSchedule = true); // reuso para loading
    try {
      // Verificar disponibilidade novamente
      final available = await _bookingVM.checkAvailability(
        courtId: widget.court.id,
        startTime: slot.startTime,
        endTime: slot.endTime,
      );
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horário não está mais disponível')),
        );
        _generateTimeSlots(_selectedDate!); // recarregar slots
        setState(() => _loadingSchedule = false);
        return;
      }

      await _bookingVM.createBooking(
        courtId: widget.court.id,
        userId: userId,
        startTime: slot.startTime,
        endTime: slot.endTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva confirmada!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loadingSchedule = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.court.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _loadingSchedule
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      image: widget.court.photo != null
                          ? DecorationImage(
                              image: NetworkImage(widget.court.photo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.court.photo == null
                        ? Image.asset(
                            getDefaultSportImage(widget.court.sport),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.court.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sportName(widget.court.sport),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (_schedule != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${_schedule!.priceBrl.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'UYU ${_schedule!.priceUyu.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Funcionamento: ${_schedule!.openingTime} - ${_schedule!.closingTime}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Data desejada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDate == null
                                      ? 'Selecione uma data'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedDate != null && _timeSlots.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Horários disponíveis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _timeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = _timeSlots[index];
                          return _TimeSlotBox(
                            slot: slot,
                            onTap: () => _onSlotSelected(index),
                          );
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed:
                        _selectedDate != null && _selectedSlotIndex != null
                        ? _confirmBooking
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CONFIRMAR RESERVA',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _sportIcon(Sport sport) {
    switch (sport) {
      case Sport.soccer:
        return Icons.sports_soccer;
      case Sport.futsal:
        return Icons.sports_soccer;
      case Sport.padel:
        return Icons.sports_tennis;
      case Sport.tennis:
        return Icons.sports_tennis;
    }
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

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  bool isAvailable;
  bool isSelected;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.isSelected = false,
  });

  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }
}

class _TimeSlotBox extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onTap;

  const _TimeSlotBox({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.grey.shade200;
    Color textColor = Colors.black;

    if (!slot.isAvailable) {
      backgroundColor = Colors.grey.shade500;
      textColor = Colors.white;
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: slot.isSelected
                ? Colors.green.shade700
                : Colors.grey.shade300,
            width: slot.isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          slot.formattedTime,
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
