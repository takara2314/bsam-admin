import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:bsam_admin/constants/app_constants.dart';
import 'package:bsam_admin/models/user.dart';
import 'package:bsam_admin/providers.dart';
import 'package:bsam_admin/pages/home/app_bar.dart';
import 'package:bsam_admin/pages/home/race_name_area.dart';
import 'package:bsam_admin/pages/home/mark_button.dart';
import 'package:bsam_admin/pages/home/manage_button.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _Home();
}

class _Home extends ConsumerState<Home> {
  static final marks = <User>[
    User(displayName: '上マーク', id: 'mark1', markNo: 1),
    User(displayName: 'サイドマーク', id: 'mark2', markNo: 2),
    User(displayName: '下マーク', id: 'mark3', markNo: 3)
  ];

  String? _assocId;
  String _version = '';

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
      await _loadVersion();
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

  _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(
        assocName: AppConstants.assocName
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const RaceNameArea(
                raceName: AppConstants.raceName
              ),
              for (final mark in marks)
                MarkButton(
                  assocId: _assocId,
                  mark: mark
                ),
              ManageButton(
                assocId: _assocId
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 50),
                child: Text(
                  'アプリバージョン: $_version',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                  ),
                ),
              ),
            ]
          )
        )
      )
    );
  }
}
