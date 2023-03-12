import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              'images/logo.svg',
              semanticsLabel: 'logo',
              width: 42,
              height: 42
            ),
            Container(
              width: width * 0.6,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999)
              ),
              child: Text(
                'セーリング団体名',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                )
              )
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 32,
              onPressed: () {}
            )
          ]
        )
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
             const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text('テストレース2023')
              ),
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
      )
    );
  }
}
