import 'dart:ui';

import 'package:tt_club_ua/api/routs/Dto/MentionLocationPointDto.dart';

/// A group of one or more [MentionLocationPointDto] that are close enough on
/// screen at the current zoom to be shown as a single marker (FR-013, FR-015).
class MentionLocationCluster {
  final double centerLatitude;
  final double centerLongitude;
  final int totalCount;
  final List<MentionLocationPointDto> sourcePoints;

  MentionLocationCluster({
    required this.centerLatitude,
    required this.centerLongitude,
    required this.totalCount,
    required this.sourcePoints,
  });

  /// A cluster with a single source point is rendered as a regular marker.
  bool get isCluster => sourcePoints.length > 1;
}

/// Merges points that share the same `(latitude, longitude)` pair into a
/// single point with a combined `count` (FR-013).
List<MentionLocationPointDto> aggregateByCoordinate(
    List<MentionLocationPointDto> points) {
  final byCoordinate = <String, MentionLocationPointDto>{};

  for (final point in points) {
    final key = '${point.latitude},${point.longitude}';
    final existing = byCoordinate[key];
    if (existing == null) {
      byCoordinate[key] = MentionLocationPointDto(
        latitude: point.latitude,
        longitude: point.longitude,
        count: point.count,
      );
    } else {
      existing.count += point.count;
    }
  }

  return byCoordinate.values.toList();
}

/// Groups [points] into [MentionLocationCluster]s based on their projected
/// screen distance, so nearby points collapse into one marker at low zoom
/// and split apart as the map is zoomed in (FR-015, FR-016).
///
/// [projectToScreen] converts a point's `(latitude, longitude)` into a
/// screen [Offset] for the current camera position/zoom; points that fall
/// outside the visible viewport (returns null) are skipped.
List<MentionLocationCluster> computeClusters(
  List<MentionLocationPointDto> points, {
  required Offset? Function(double latitude, double longitude) projectToScreen,
  double pixelDistanceThreshold = 50,
}) {
  final projected = <_ProjectedPoint>[];
  for (final point in points) {
    final offset = projectToScreen(point.latitude, point.longitude);
    if (offset != null) {
      projected.add(_ProjectedPoint(point: point, screen: offset));
    }
  }

  final clusters = <MentionLocationCluster>[];
  final visited = List<bool>.filled(projected.length, false);
  final thresholdSquared = pixelDistanceThreshold * pixelDistanceThreshold;

  for (var i = 0; i < projected.length; i++) {
    if (visited[i]) continue;
    visited[i] = true;

    final group = <_ProjectedPoint>[projected[i]];
    for (var j = i + 1; j < projected.length; j++) {
      if (visited[j]) continue;
      final dx = projected[i].screen.dx - projected[j].screen.dx;
      final dy = projected[i].screen.dy - projected[j].screen.dy;
      if (dx * dx + dy * dy <= thresholdSquared) {
        visited[j] = true;
        group.add(projected[j]);
      }
    }

    clusters.add(_buildCluster(group));
  }

  return clusters;
}

class _ProjectedPoint {
  final MentionLocationPointDto point;
  final Offset screen;

  _ProjectedPoint({required this.point, required this.screen});
}

MentionLocationCluster _buildCluster(List<_ProjectedPoint> group) {
  final totalCount = group.fold<int>(0, (sum, p) => sum + p.point.count);
  // Fall back to an unweighted (simple) average when every point in the
  // group has a zero count, to avoid dividing by zero.
  final weight = totalCount > 0 ? totalCount : group.length;
  final countOrOne = totalCount > 0
      ? (MentionLocationPointDto p) => p.count
      : (MentionLocationPointDto p) => 1;
  final weightedLat = group.fold<double>(
          0, (sum, p) => sum + p.point.latitude * countOrOne(p.point)) /
      weight;
  final weightedLng = group.fold<double>(
          0, (sum, p) => sum + p.point.longitude * countOrOne(p.point)) /
      weight;

  return MentionLocationCluster(
    centerLatitude: weightedLat,
    centerLongitude: weightedLng,
    totalCount: totalCount,
    sourcePoints: group.map((p) => p.point).toList(),
  );
}
