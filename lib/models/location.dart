class Location {
  double? lat;
  double? lng;
  double? acc;
  double? heading;
  double? headingFixing;

  Location({
    this.lat,
    this.lng,
    this.acc,
    this.heading,
    this.headingFixing
  });

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
    acc = json['accuracy'].toDouble();
    heading = json['heading'].toDouble();
    headingFixing = json['heading_fixing'].toDouble();
  }
}
