import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 認証関連のProvider ---
final serverUrlProvider = StateProvider<String?>((ref) => null);
final assocIdProvider = StateProvider<String?>((ref) => null);
final jwtProvider = StateProvider<String?>((ref) => null);
final userIdProvider = StateProvider<String?>((ref) => null);

// --- ネットワーク接続状態Provider ---
final connectivityProvider = StateProvider<ConnectivityResult>((ref) => ConnectivityResult.none);
