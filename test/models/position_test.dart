import 'package:flutter_test/flutter_test.dart';
import 'package:bsam_admin/models/position.dart';
import 'package:bsam_admin/models/position_source.dart';

void main() {
  test('prefers explicit manual position source', () {
    final position = Position.fromJson({
      'latitude': 34.0,
      'longitude': 136.0,
      'accuracy': 3.0,
      'position_source': 'manual',
    });

    expect(position.positionSource, PositionSource.manual);
    expect(position.isManual, isTrue);
  });

  test('falls back to legacy manual accuracy for marks', () {
    final position = Position.fromJson({
      'latitude': 34.0,
      'longitude': 136.0,
      'accuracy': 0.0,
    });

    expect(position.positionSource, PositionSource.manual);
    expect(position.isManual, isTrue);
  });

  test('keeps gps source when provided', () {
    final position = Position.fromJson({
      'latitude': 34.0,
      'longitude': 136.0,
      'accuracy': 0.0,
      'position_source': 'gps',
    });

    expect(position.positionSource, PositionSource.gps);
    expect(position.isManual, isFalse);
  });
}
