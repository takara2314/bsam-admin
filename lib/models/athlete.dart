class Athlete {
  String? userId;
  double? lat;
  double? lng;
  double? acc;
  double? heading;
  double? headingFixing;
  double? compassDeg;
  int? markNo;
  int? nextMarkNo;
  double? courseLimit;

  Athlete({
    this.userId,
    this.lat,
    this.lng,
    this.acc,
    this.heading,
    this.headingFixing,
    this.compassDeg,
    this.markNo,
    this.nextMarkNo,
    this.courseLimit
  });

  Athlete.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
    acc = json['accuracy'].toDouble();
    heading = json['heading'].toDouble();
    headingFixing = json['heading_fixing'].toDouble();
    compassDeg = json['compass_degree'].toDouble();
    markNo = json['mark_no'];
    nextMarkNo = json['next_mark_no'];
    courseLimit = json['course_limit'].toDouble();
  }
}
