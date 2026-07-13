import 'package:flutter/material.dart';
import 'package:cancha_mobile/model/court.dart';
import 'package:cancha_mobile/model/court_booking.dart';
import 'package:cancha_mobile/model/court_schedule.dart';
import 'package:cancha_mobile/model/establishment.dart';
import 'package:cancha_mobile/utils/image_utils.dart';
import 'package:cancha_mobile/view/map_page.dart';
import 'package:cancha_mobile/viewmodel/auth_viewmodel.dart';
import 'package:cancha_mobile/viewmodel/court_schedule_viewmodel.dart';
import 'package:cancha_mobile/viewmodel/booking_viewmodel.dart';

class CourtDetailPage extends StatefulWidget {
  final Court court;
  final Establishment establishment;

  const CourtDetailPage({
    super.key,
    required this.court,
    required this.establishment,
  });

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
  List<CourtBooking> _bookingsOnSelectedDate = [];

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
      });
      await _loadBookingsForDate(picked);
      _generateTimeSlots(picked);
    }
  }

  Future<void> _loadBookingsForDate(DateTime date) async {
    try {
      final bookings = await _bookingVM.fetchBookingsByCourtAndDate(
        widget.court.id,
        date,
      );
      setState(() => _bookingsOnSelectedDate = bookings);
    } catch (e) {
      setState(() => _bookingsOnSelectedDate = []);
    }
  }

  void _generateTimeSlots(DateTime date) {
    if (_schedule == null) return;
    final slots = <TimeSlot>[];
    final opening = _parseTime(_schedule!.openingTime);
    final closing = _parseTime(_schedule!.closingTime);
    final duration = _schedule!.gameDuration;

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

    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    while (current.add(Duration(minutes: duration)).isBefore(endOfDay) ||
        current.add(Duration(minutes: duration)).isAtSameMomentAs(endOfDay)) {
      final start = current;
      final end = current.add(Duration(minutes: duration));

      bool isPast = isToday && start.isBefore(now);
      bool isOccupied = _bookingsOnSelectedDate.any(
        (booking) =>
            (booking.startTime.isBefore(end) && booking.endTime.isAfter(start)),
      );

      slots.add(
        TimeSlot(
          startTime: start,
          endTime: end,
          isAvailable: !isPast && !isOccupied,
          isSelected: false,
        ),
      );
      current = end;
    }

    setState(() => _timeSlots = slots);
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
    var shouldResetLoading = true;

    setState(() => _loadingSchedule = true);
    try {
      final available = await _bookingVM.checkAvailability(
        courtId: widget.court.id,
        startTime: slot.startTime,
        endTime: slot.endTime,
      );
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horário não está mais disponível')),
        );
        await _loadBookingsForDate(_selectedDate!);
        _generateTimeSlots(_selectedDate!);
        if (!mounted) return;
        setState(() => _loadingSchedule = false);
        shouldResetLoading = false;
        return;
      }

      await _bookingVM.createBooking(
        courtId: widget.court.id,
        userId: userId,
        startTime: slot.startTime,
        endTime: slot.endTime,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva confirmada!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadBookingsForDate(_selectedDate!);
      _generateTimeSlots(_selectedDate!);
      if (!mounted) return;
      setState(() => _selectedSlotIndex = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted && shouldResetLoading) {
        setState(() => _loadingSchedule = false);
      }
    }
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPage(
          latitude: widget.establishment.latitude,
          longitude: widget.establishment.longitude,
          name: widget.establishment.name,
        ),
      ),
    );
  }

  String _formatTimeWithoutSeconds(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.court.name)),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_schedule != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${_schedule!.priceBrl.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        Text(
                          'UYU ${_schedule!.priceUyu.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Funcionamento: ${_formatTimeWithoutSeconds(_schedule!.openingTime)} - ${_formatTimeWithoutSeconds(_schedule!.closingTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Ver localização no mapa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.18,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data desejada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDate == null
                                      ? 'Selecione uma data'
                                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: colorScheme.onSurface,
                            ),
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
                            primaryColor: primary,
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
                      backgroundColor: primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('CONFIRMAR RESERVA'),
                  ),
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

  String get formattedTime =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
}

class _TimeSlotBox extends StatelessWidget {
  final TimeSlot slot;
  final Color primaryColor;
  final VoidCallback onTap;

  const _TimeSlotBox({
    required this.slot,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor = colorScheme.surface;
    Color textColor = colorScheme.onSurface;

    if (!slot.isAvailable) {
      backgroundColor = colorScheme.onSurface.withValues(alpha: 0.12);
      textColor = colorScheme.onSurface.withValues(alpha: 0.72);
    } else if (slot.isSelected) {
      backgroundColor = primaryColor;
      textColor = colorScheme.onPrimary;
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
                ? primaryColor
                : colorScheme.onSurface.withValues(alpha: 0.18),
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
