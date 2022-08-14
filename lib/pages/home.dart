import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsam_admin/pages/marking.dart';
import 'package:bsam_admin/providers.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _Home();
}

class _Home extends ConsumerState<Home> {
  static const jwts = {
    'a91bb4bf-1f2b-4316-9c64-1392a89a59f1': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjY5MTkwODEsIm1hcmtfbm8iOjEsInJvbGUiOiJtYXJrIiwidXNlcl9pZCI6ImE5MWJiNGJmLTFmMmItNDMxNi05YzY0LTEzOTJhODlhNTlmMSJ9.cgPoNe9fJGBCfhun7-EgjriFj6w9xNoGT72OdeR7xEI',
    'd09bd6b4-56e9-464d-952c-a7fbdf980d3a': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjY5MTkwOTcsIm1hcmtfbm8iOjIsInJvbGUiOiJtYXJrIiwidXNlcl9pZCI6ImQwOWJkNmI0LTU2ZTktNDY0ZC05NTJjLWE3ZmJkZjk4MGQzYSJ9.ZqPYibIS3c_DCIQKgz2cpjvWucJjg-Xgl6EWiNEZGYQ',
    '0756bc89-71f8-440b-b680-57513d16dd29': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjY5MTkxMTMsIm1hcmtfbm8iOjMsInJvbGUiOiJtYXJrIiwidXNlcl9pZCI6IjA3NTZiYzg5LTcxZjgtNDQwYi1iNjgwLTU3NTEzZDE2ZGQyOSJ9.7yumSW_xJpB97BI5E9cdgqg5CyzH_HMCjt3_sXE92B0'
  };

  static const raceId = '3ae8c214-eb72-481c-b110-8e8f32ecf02d';

  String? _userName;

  @override
  void initState() {
    super.initState();

    () async {
      PermissionStatus permLocation = await Permission.location.status;

      if (permLocation == PermissionStatus.denied) {
        permLocation = await Permission.location.request();
      }
    }();
  }

  _changeUser(String? value) {
      final userId = ref.read(userIdProvider.notifier);
      final jwt = ref.read(jwtProvider.notifier);

      userId.state = value;
      jwt.state = jwts[value];

      setState(() {
        _userName = value;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ゴーリキテスト',
          style: Theme.of(context).textTheme.headline1
        ),
        centerTitle: true
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text('ユーザー'),
            DropdownButton(
              items: const [
                DropdownMenuItem(
                  value: 'a91bb4bf-1f2b-4316-9c64-1392a89a59f1',
                  child: Text('マークA'),
                ),
                DropdownMenuItem(
                  value: 'd09bd6b4-56e9-464d-952c-a7fbdf980d3a',
                  child: Text('マークB'),
                ),
                DropdownMenuItem(
                  value: '0756bc89-71f8-440b-b680-57513d16dd29',
                  child: Text('マークC'),
                ),
              ],
              onChanged: _changeUser,
              value: _userName,
            ),
            ElevatedButton(
              child: const Text(
                '上マークをおく'
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Marking(raceId: raceId, markNo: 1),
                  )
                );
              }
            ),
            ElevatedButton(
              child: const Text(
                'サイドマークをおく'
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Marking(raceId: raceId, markNo: 2),
                  )
                );
              }
            ),
            ElevatedButton(
              child: const Text(
                '下マークをおく'
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Marking(raceId: raceId, markNo: 3),
                  )
                );
              }
            ),
          ]
        )
      )
    );
  }
}
