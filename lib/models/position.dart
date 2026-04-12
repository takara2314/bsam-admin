import 'package:bsam_admin/models/position_source.dart';

class Position {
  double? lat;
  double? lng;
  double? acc;
  PositionSource? positionSource;

  Position({this.lat, this.lng, this.acc, this.positionSource});

  Position.fromJson(Map<String, dynamic> json) {
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
    acc = json['accuracy'].toDouble();
    positionSource = PositionSource.fromJsonValue(json['position_source']);

    if (positionSource == null && acc == 0.0) {
      positionSource = PositionSource.manual;
    }
  }

  bool get isManual => positionSource == PositionSource.manual;
}
