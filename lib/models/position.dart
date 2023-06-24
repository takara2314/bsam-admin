class Position {
  double? lat;
  double? lng;
  double? acc;

  Position({
    this.lat,
    this.lng,
    this.acc
  });

  Position.fromJson(Map<String, dynamic> json) {
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
    acc = json['accuracy'].toDouble();
  }
}
