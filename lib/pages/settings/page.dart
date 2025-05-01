import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bsam_admin/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _version = '';
  DateTime? _jwtExpiryDate;
  bool _isLicenseActive = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkJwtExpiry();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  void _checkJwtExpiry() {
    final jwtToken = ref.read(jwtProvider);
    if (jwtToken != null) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(jwtToken);
        if (payload.containsKey('exp')) {
          final expiryTimestamp = payload['exp'] * 1000;
          _jwtExpiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
          _isLicenseActive = DateTime.now().isBefore(_jwtExpiryDate!);
          setState(() {});
        }
      } catch (e) {
        _isLicenseActive = false;
         setState(() {});
      }
    } else {
       _isLicenseActive = false;
       setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedExpiryDate = _jwtExpiryDate != null
        ? DateFormat('yyyy年M月d日', 'ja_JP').format(_jwtExpiryDate!)
        : '不明';

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // --- App Info Section ---
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'images/logo.svg',
                    semanticsLabel: 'B-SAM Logo',
                    width: 42,
                    height: 42,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'B-SAM 本部用',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('バージョン: $_version'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // --- License Info Section ---
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                     'ライセンス情報',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        _isLicenseActive ? Icons.check_circle : Icons.cancel,
                        color: _isLicenseActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLicenseActive ? 'ライセンスは有効です' : 'ライセンスは無効です',
                        style: TextStyle(
                          color: _isLicenseActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                   if (_jwtExpiryDate != null) ...[
                     const SizedBox(height: 5),
                     Row(
                       children: [
                         Text('有効期限: $formattedExpiryDate'),
                         if (!_isLicenseActive)
                           const Text(
                             '（有効期限切れ）',
                             style: TextStyle(color: Colors.red),
                           ),
                       ],
                     ),
                  ] else if (!_isLicenseActive) ... [
                     const SizedBox(height: 5),
                     const Text('有効なライセンスが設定されていません。'),
                  ]

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
