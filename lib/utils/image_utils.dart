import '../model/court.dart';

String getDefaultSportImage(Sport sport) {
  switch (sport) {
    case Sport.soccer:
      return 'assets/images/default_soccer.jpg';
    case Sport.futsal:
      return 'assets/images/default_futsal.jpg';
    case Sport.padel:
      return 'assets/images/default_padel.jpg';
    case Sport.tennis:
      return 'assets/images/default_tennis.jpg';
  }
}
