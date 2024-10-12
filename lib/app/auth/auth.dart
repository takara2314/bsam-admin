import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bsam_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const timeoutSec = 30;

class AuthResponse {
  final String message;
  final String token;

  AuthResponse({required this.message, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      token: json['token'],
    );
  }
}

Future<AuthResponse> verifyPassword(String associationId, String password) async {
  final url = Uri.parse('$authServerBaseUrl/verify/password');
  final client = http.Client();
  try {
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'association_id': associationId,
        'password': password,
      }),
    ).timeout(const Duration(seconds: timeoutSec), onTimeout: () {
      throw TimeoutException('The connection has timed out, Please try again!');
    });

    if (response.statusCode == HttpStatus.ok) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to verify password: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint(e.toString());
    rethrow;
  } finally {
    client.close();
  }
}

Future<AuthResponse> verifyToken(String token) async {
  final url = Uri.parse('$authServerBaseUrl/verify/token');
  final client = http.Client();
  try {
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    ).timeout(const Duration(seconds: timeoutSec), onTimeout: () {
      throw TimeoutException('The connection has timed out, Please try again!');
    });

    if (response.statusCode == HttpStatus.ok) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to verify token: ${response.statusCode}');
    }
  } finally {
    client.close();
  }
}
