class Mark {
  String? userId;
  double? lat;
  double? lng;

  Mark({
    this.userId,
    this.lat,
    this.lng
  });

  Mark.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
  }
}
