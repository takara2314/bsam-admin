import 'package:bsam_admin/provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadToken(WidgetRef ref) async {
  final tokenNotifier = ref.watch(tokenProvider.notifier);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? tokenInSharedPreferences = prefs.getString('token');

  if (tokenInSharedPreferences == null) {
    return;
  }

  tokenNotifier.state = tokenInSharedPreferences;
}

Future<void> saveToken(WidgetRef ref, String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);

  final tokenNotifier = ref.watch(tokenProvider.notifier);
  tokenNotifier.state = token;
}

Future<void> deleteToken(WidgetRef ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');

  final tokenNotifier = ref.watch(tokenProvider.notifier);
  tokenNotifier.state = '';
}
