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
    'a91bb4bf-1f2b-4316-9c64-1392a89a59f1': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTc0MzEyOTQsIm1hcmtfbm8iOi0xLCJyb2xlIjoibWFyayIsInVzZXJfaWQiOiJhOTFiYjRiZi0xZjJiLTQzMTYtOWM2NC0xMzkyYTg5YTU5ZjEifQ.9koy0GFTBA0cxct1AAUG6fTSkEff8EwIdILBdJCXRbw',
    'd09bd6b4-56e9-464d-952c-a7fbdf980d3a': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTc0MzEyOTQsIm1hcmtfbm8iOi0xLCJyb2xlIjoibWFyayIsInVzZXJfaWQiOiJkMDliZDZiNC01NmU5LTQ2NGQtOTUyYy1hN2ZiZGY5ODBkM2EifQ.xg0wL788QR4ftdkriubof3hjN5EbVB81SwoDTG5t7WU',
    '0756bc89-71f8-440b-b680-57513d16dd29': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTc0MzEyOTQsIm1hcmtfbm8iOi0xLCJyb2xlIjoibWFyayIsInVzZXJfaWQiOiIwNzU2YmM4OS03MWY4LTQ0MGItYjY4MC01NzUxM2QxNmRkMjkifQ.2QXYCN8c30lWnhkgVH6WdUYP79GcpZ6NIrkczJLyfjY',
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
          'ゴーリキマリンビレッジ',
          style: Theme.of(context).textTheme.headline1
        ),
        centerTitle: true
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // const Text('ユーザー'),
            // DropdownButton(
            //   items: const [
            //     DropdownMenuItem(
            //       value: 'a91bb4bf-1f2b-4316-9c64-1392a89a59f1',
            //       child: Text('マークA'),
            //     ),
            //     DropdownMenuItem(
            //       value: 'd09bd6b4-56e9-464d-952c-a7fbdf980d3a',
            //       child: Text('マークB'),
            //     ),
            //     DropdownMenuItem(
            //       value: '0756bc89-71f8-440b-b680-57513d16dd29',
            //       child: Text('マークC'),
            //     ),
            //   ],
            //   onChanged: _changeUser,
            //   value: _userName,
            // ),
            ElevatedButton(
              child: const Text(
                '上マークをおく'
              ),
              onPressed: () {
                _changeUser('a91bb4bf-1f2b-4316-9c64-1392a89a59f1');
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
                _changeUser('d09bd6b4-56e9-464d-952c-a7fbdf980d3a');
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
                _changeUser('0756bc89-71f8-440b-b680-57513d16dd29');
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
