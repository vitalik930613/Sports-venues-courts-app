import 'package:flutter/material.dart';
import '../../viewmodel/booking_viewmodel.dart';
import '../../viewmodel/court_viewmodel.dart';
import '../../viewmodel/establishment_viewmodel.dart';
import '../../model/court_booking.dart';
import '../../model/court.dart';
import '../../model/establishment.dart';

class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key});

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  final BookingViewModel _bookingVM = BookingViewModel();
  final CourtViewModel _courtVM = CourtViewModel();
  final EstablishmentViewModel _estabVM = EstablishmentViewModel();

  Future<CourtBooking?> _getNextBooking() async {
    final bookings = await _bookingVM.fetchUserBookings();
    final now = DateTime.now();
    final futureBookings = bookings
        .where((b) => b.endTime.isAfter(now))
        .toList();
    if (futureBookings.isEmpty) return null;
    futureBookings.sort((a, b) => a.startTime.compareTo(b.startTime));
    return futureBookings.first;
  }

  Future<Map<int, String>> _fetchCourtsMap() async {
    final courts = await _courtVM.fetchAllCourts();
    return {for (var c in courts) c.id: c.name};
  }

  Future<Map<int, String>> _fetchEstablishmentsMap() async {
    final establishments = await _estabVM.fetchEstablishments();
    return {for (var e in establishments) e.id: e.name};
  }

  Future<(String, String)> _getCourtAndEstablishmentNames(
    int courtId,
    Map<int, String> courtsMap,
    Map<int, String> estabsMap,
  ) async {
    final courtName = courtsMap[courtId] ?? 'Quadra #$courtId';
    try {
      final court = await _courtVM.fetchCourtById(courtId);
      final estabName = estabsMap[court.establishmentId] ?? 'Cancha Sports';
      return (courtName, estabName);
    } catch (e) {
      return (courtName, 'Cancha Sports');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Meu Relógio'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ClipOval(
          child: Container(
            width: 250,
            height: 250,
            color: Colors.black,
            child: FutureBuilder<CourtBooking?>(
              future: _getNextBooking(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }
                final booking = snapshot.data;
                if (booking == null) {
                  return const _NoBookingContent();
                }
                return FutureBuilder(
                  future: Future.wait([
                    _fetchCourtsMap(),
                    _fetchEstablishmentsMap(),
                  ]),
                  builder: (context, mapsSnapshot) {
                    if (!mapsSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      );
                    }
                    final courtsMap = mapsSnapshot.data![0];
                    final estabsMap = mapsSnapshot.data![1];
                    return FutureBuilder(
                      future: _getCourtAndEstablishmentNames(
                        booking.courtId,
                        courtsMap,
                        estabsMap,
                      ),
                      builder: (context, namesSnapshot) {
                        if (!namesSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          );
                        }
                        final (courtName, estabName) = namesSnapshot.data!;
                        return _BookingContent(
                          booking: booking,
                          courtName: courtName,
                          establishmentName: estabName,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NoBookingContent extends StatelessWidget {
  const _NoBookingContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sports_soccer, size: 48, color: Colors.grey),
        SizedBox(height: 12),
        Text(
          'SEM RESERVAS',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          'Agende uma quadra',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class _BookingContent extends StatelessWidget {
  final CourtBooking booking;
  final String courtName;
  final String establishmentName;

  const _BookingContent({
    required this.booking,
    required this.courtName,
    required this.establishmentName,
  });

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sports_soccer, size: 48, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          establishmentName,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          courtName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${booking.startTime.day}/${booking.startTime.month}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ver detalhes no smartphone'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('VER MAPA', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
