import 'package:bsam_admin/models/athlete.dart';
import 'package:bsam_admin/models/mark.dart';

class LiveMsg {
  List<Athlete>? athletes;
  List<Mark>? marks;

  LiveMsg({this.athletes, this.marks});

  LiveMsg.fromJson(Map<String, dynamic> json) {
    if (json['athletes'] != null) {
      athletes = <Athlete>[];
      json['athletes'].forEach((v) {
        athletes!.add(Athlete.fromJson(v));
      });
    }

    if (json['marks'] != null) {
      marks = <Mark>[];
      json['marks'].forEach((v) {
        marks!.add(Mark.fromJson(v));
      });
    }
  }
}
