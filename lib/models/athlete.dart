import 'package:bsam_admin/models/location.dart';

class Athlete {
  String? userId;
  int? nextMarkNo;
  double? courseLimit;
  int? batteryLevel;
  double? compassDeg;
  Location? location;

  Athlete({
    this.userId,
    this.nextMarkNo,
    this.courseLimit,
    this.batteryLevel,
    this.compassDeg,
    this.location
  });

  Athlete.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    nextMarkNo = json['next_mark_no'];
    courseLimit = json['course_limit'].toDouble();
    batteryLevel = json['battery_level'];
    compassDeg = json['compass_degree'].toDouble();
    location = Location.fromJson(json['location']);
  }
}
