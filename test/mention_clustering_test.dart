import 'package:flutter_test/flutter_test.dart';
import 'package:tt_club_ua/api/routs/Dto/MentionLocationPointDto.dart';
import 'package:tt_club_ua/Helpers/mention_clustering.dart';

void main() {
  group('aggregateByCoordinate', () {
    test('merges duplicate coordinates into a single point with summed count', () {
      final points = [
        MentionLocationPointDto(latitude: 50.1, longitude: 30.1, count: 2),
        MentionLocationPointDto(latitude: 50.1, longitude: 30.1, count: 3),
        MentionLocationPointDto(latitude: 50.2, longitude: 30.2, count: 1),
      ];

      final result = aggregateByCoordinate(points);

      expect(result.length, 2);
      final merged = result.firstWhere((p) => p.latitude == 50.1);
      expect(merged.count, 5);
      final untouched = result.firstWhere((p) => p.latitude == 50.2);
      expect(untouched.count, 1);
    });

    test('returns an empty list for an empty input', () {
      expect(aggregateByCoordinate([]), isEmpty);
    });
  });

  group('computeClusters', () {
    test('groups points within the pixel threshold into one cluster', () {
      final points = [
        MentionLocationPointDto(latitude: 50.1, longitude: 30.1, count: 1),
        MentionLocationPointDto(latitude: 50.1001, longitude: 30.1001, count: 2),
      ];
      // Both points project close together on screen.
      final screenPositions = {
        '50.1,30.1': const Offset(100, 100),
        '50.1001,30.1001': const Offset(110, 105),
      };

      final clusters = computeClusters(
        points,
        projectToScreen: (lat, lng) => screenPositions['$lat,$lng'],
      );

      expect(clusters.length, 1);
      expect(clusters.single.isCluster, isTrue);
      expect(clusters.single.totalCount, 3);
    });

    test('keeps far-apart points as separate, non-cluster entries', () {
      final points = [
        MentionLocationPointDto(latitude: 50.1, longitude: 30.1, count: 1),
        MentionLocationPointDto(latitude: 51.0, longitude: 31.0, count: 2),
      ];
      final screenPositions = {
        '50.1,30.1': const Offset(0, 0),
        '51.0,31.0': const Offset(500, 500),
      };

      final clusters = computeClusters(
        points,
        projectToScreen: (lat, lng) => screenPositions['$lat,$lng'],
      );

      expect(clusters.length, 2);
      expect(clusters.every((c) => !c.isCluster), isTrue);
    });

    test('skips points that fail to project (outside viewport)', () {
      final points = [
        MentionLocationPointDto(latitude: 50.1, longitude: 30.1, count: 1),
        MentionLocationPointDto(latitude: 99.0, longitude: 99.0, count: 5),
      ];

      final clusters = computeClusters(
        points,
        projectToScreen: (lat, lng) =>
            lat == 50.1 ? const Offset(10, 10) : null,
      );

      expect(clusters.length, 1);
      expect(clusters.single.totalCount, 1);
    });
  });
}
