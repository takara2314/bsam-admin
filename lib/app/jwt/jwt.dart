import 'package:jwt_decoder/jwt_decoder.dart';

class Jwt {
  final String associationId;
  final String associationName;
  final DateTime iat;
  final DateTime exp;

  Jwt({
    required this.associationId,
    required this.associationName,
    required this.iat,
    required this.exp,
  });

  factory Jwt.fromJson(Map<String, dynamic> json) {
    return Jwt(
      associationId: json['association_id'],
      associationName: json['association_name'],
      iat: DateTime.fromMillisecondsSinceEpoch(json['iat'] * 1000),
      exp: DateTime.fromMillisecondsSinceEpoch(json['exp'] * 1000),
    );
  }

  factory Jwt.fromToken(String token) {
    return Jwt.fromJson(JwtDecoder.decode(token));
  }
}
