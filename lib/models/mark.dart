import 'package:bsam_admin/models/position.dart';

class Mark {
  String? userId;
  int? markNo;
  int? batteryLevel;
  Position? position;

  Mark({
    this.userId,
    this.markNo,
    this.batteryLevel,
    this.position
  });

  Mark.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    markNo = json['mark_no'];
    batteryLevel = json['battery_level'];
    position = Position.fromJson(json['location']);
  }
}
