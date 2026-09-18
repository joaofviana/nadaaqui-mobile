import 'package:flutter_test/flutter_test.dart';
import 'package:nadaaqui/presentation/widgets/distance_chip.dart';

void main() {
  group('distanceBand', () {
    const radius = 150; // remote default — callers pass RemoteConfig value

    test('green / inRange when <= radius', () {
      expect(
        distanceBand(distanceMeters: 80, checkInRadiusMeters: radius),
        DistanceBand.inRange,
      );
      expect(
        distanceBand(distanceMeters: 150, checkInRadiusMeters: radius),
        DistanceBand.inRange,
      );
      expect(
        distanceBand(distanceMeters: 120, checkInRadiusMeters: radius),
        DistanceBand.inRange,
      );
    });

    test('amber / near when <= 2x radius', () {
      expect(
        distanceBand(distanceMeters: 151, checkInRadiusMeters: radius),
        DistanceBand.near,
      );
      expect(
        distanceBand(distanceMeters: 220, checkInRadiusMeters: radius),
        DistanceBand.near,
      );
      expect(
        distanceBand(distanceMeters: 300, checkInRadiusMeters: radius),
        DistanceBand.near,
      );
    });

    test('gray / far when > 2x radius', () {
      expect(
        distanceBand(distanceMeters: 301, checkInRadiusMeters: radius),
        DistanceBand.far,
      );
      expect(
        distanceBand(distanceMeters: 450, checkInRadiusMeters: radius),
        DistanceBand.far,
      );
    });
  });
}
