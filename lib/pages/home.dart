import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:bsam_admin/pages/marking.dart';
import 'package:bsam_admin/pages/manage.dart';
import 'package:bsam_admin/models/user.dart';
import 'package:bsam_admin/providers.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _Home();
}

class _Home extends ConsumerState<Home> {
  static final users = <User>[
    User(displayName: '上マーク', id: 'mark1', markNo: 1),
    User(displayName: 'サイドマーク', id: 'mark2', markNo: 2),
    User(displayName: '下マーク', id: 'mark3', markNo: 3)
  ];

  String? _assocId;

  @override
  void initState() {
    super.initState();

    () async {
      PermissionStatus permLocation = await Permission.location.status;

      if (permLocation == PermissionStatus.denied) {
        permLocation = await Permission.location.request();
      }

      _loadServerURL();
      _loadAssocInfo();
    }();
  }

  _loadServerURL() {
    final String? url = dotenv.maybeGet('BSAM_SERVER_URL');

    final provider = ref.read(serverUrlProvider.notifier);
    provider.state = url;
  }

  _loadAssocInfo() {
    final String? token = dotenv.maybeGet('BSAM_SERVER_TOKEN');
    Map<String, dynamic> payload = Jwt.parseJwt(token!);
    final String? id = payload['association_id'];

    final assocId = ref.read(assocIdProvider.notifier);
    final jwt = ref.read(jwtProvider.notifier);

    assocId.state = id;
    jwt.state = token;

    setState(() {
      _assocId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'セーリング団体名',
          style: Theme.of(context).textTheme.headline1
        ),
        centerTitle: true
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            for (final user in users)
              ElevatedButton(
                child: Text(
                  '${user.displayName}をおく'
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Marking(
                        assocId: _assocId!,
                        userId: user.id!,
                        markNo: user.markNo!
                      )
                    )
                  );
                }
              ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ElevatedButton(
                child: const Text(
                  'レースを管理する'
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Manage(assocId: _assocId!),
                    )
                  );
                }
              ),
            )
          ]
        )
      )
    );
  }
}
