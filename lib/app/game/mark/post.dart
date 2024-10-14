import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bsam_admin/main.dart';
import 'package:http/http.dart' as http;

const timeoutSec = 30;

class GeolocationPostResponse {
  final String message;
  final Map<String, dynamic> geolocation;

  GeolocationPostResponse({
    required this.message,
    required this.geolocation,
  });

  factory GeolocationPostResponse.fromJson(Map<String, dynamic> json) {
    return GeolocationPostResponse(
      message: json['message'],
      geolocation: json['geolocation'],
    );
  }
}

Future<GeolocationPostResponse> postGeolocation({
  required String token,
  required String deviceId,
  required double latitude,
  required double longitude,
  required double altitudeMeter,
  required double accuracyMeter,
  required double altitudeAccuracyMeter,
  required double heading,
  required double speedMeterPerSec,
  required DateTime recordedAt,
}) async {
  final url = Uri.parse('$apiServerBaseUrl/geolocation');
  final client = http.Client();
  try {
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'device_id': deviceId,
        'latitude': latitude,
        'longitude': longitude,
        'altitude_meter': altitudeMeter,
        'accuracy_meter': accuracyMeter,
        'altitude_accuracy_meter': altitudeAccuracyMeter,
        'heading': heading,
        'speed_meter_per_sec': speedMeterPerSec,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
      }),
    ).timeout(
      const Duration(seconds: timeoutSec),
      onTimeout: () {
        throw TimeoutException('Connection timed out. Please try again.');
      },
    );

    if (response.statusCode == HttpStatus.created) {
      return GeolocationPostResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send location information: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  } finally {
    client.close();
  }
}
