import 'dart:math';

/// Extension helpers for trigonometry calculations in Haversine formula.
extension HaversineUtils on double {
  double toRadians() => this * (pi / 180);
  double cosValue() => cos(this);
  double sinValue() => sin(this);
  double asinValue() => asin(this);
  double sqrtValue() => sqrt(this);
  double sinHalf() => sin(this / 2);
}

/// Utility class for calculating distances using the Haversine formula.
class HaversineCalculator {
  static const double earthRadiusKm = 6371; // Earth's radius in kilometers

  /// Calculates the distance between two geographical coordinates using the Haversine formula.
  /// Returns the distance in kilometers.
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    double dLat = (lat2 - lat1).toRadians();
    double dLon = (lon2 - lon1).toRadians();

    double a = dLat.sinHalf() * dLat.sinHalf() +
        lat1.toRadians().cosValue() *
            lat2.toRadians().cosValue() *
            dLon.sinHalf() *
            dLon.sinHalf();

    double c = 2 * a.sqrtValue().asinValue();

    return earthRadiusKm * c;
  }
}