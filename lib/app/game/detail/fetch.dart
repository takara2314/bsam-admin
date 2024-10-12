import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bsam_admin/main.dart';
import 'package:http/http.dart' as http;

const timeoutSec = 30;

class Association {
  final String id;
  final String name;
  final String contractType;
  final DateTime expiresAt;

  Association({
    required this.id,
    required this.name,
    required this.contractType,
    required this.expiresAt,
  });

  factory Association.fromJson(Map<String, dynamic> json) {
    return Association(
      id: json['id'],
      name: json['name'],
      contractType: json['contract_type'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}

class RaceDetailResponse {
  final String associationId;
  final String name;
  final bool started;
  final DateTime startedAt;
  final DateTime finishedAt;
  final Association association;
  final List<String> athleteIds;
  final List<String> markIds;

  RaceDetailResponse({
    required this.associationId,
    required this.name,
    required this.started,
    required this.startedAt,
    required this.finishedAt,
    required this.association,
    required this.athleteIds,
    required this.markIds,
  });

  factory RaceDetailResponse.fromJson(Map<String, dynamic> json) {
    return RaceDetailResponse(
      associationId: json['association_id'],
      name: json['name'],
      started: json['started'],
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: DateTime.parse(json['finished_at']),
      association: Association.fromJson(json['association']),
      athleteIds: List<String>.from(json['athlete_ids']),
      markIds: List<String>.from(json['mark_ids']),
    );
  }
}

Future<RaceDetailResponse> fetchRaceDetail(String associationId, String token) async {
  final url = Uri.parse('$apiServerBaseUrl/races/$associationId');
  final client = http.Client();
  try {
    final response = await client.get(url, headers: {
      'Authorization': 'Bearer $token',
    }).timeout(
      const Duration(seconds: timeoutSec),
      onTimeout: () {
        throw TimeoutException('Connection timed out. Please try again.');
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return RaceDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch race details: ${response.statusCode}');
    }
  } finally {
    client.close();
  }
}
