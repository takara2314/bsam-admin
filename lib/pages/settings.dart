import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailing_assist_mie_admin/providers.dart';

class UserInfo {
  late String userId;
  late String loginId;
  late String displayName;
  late String groupId;
  late String role;
  late String deviceId;
  late int sailNum;
  late double courseLimit;
  late String imageUrl;
  late String note;

  UserInfo({
    required this.userId,
    required this.loginId,
    required this.displayName,
    required this.groupId,
    required this.role,
    required this.deviceId,
    required this.sailNum,
    required this.courseLimit,
    required this.imageUrl,
    required this.note
  });
}

class Settings extends ConsumerStatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  ConsumerState<Settings> createState() => _Settings();
}

class _Settings extends ConsumerState<Settings> {
  bool _ready = false;
  late UserInfo _userInfo;

  Map<String, String> roleName = {
    'athlete': '競技者',
    'mark': 'マーク',
    'manage': '運営',
    'developer': '開発者'
  };

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  _handlerLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(context).pop();
  }

  _getUserInfo() {
    final userId = ref.read(userIdProvider);
    try {
      http.get(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/user/$userId')
      )
        .then((res) {
          if (res.statusCode != 200) {
            return;
          }

          final bodyInfo = json.decode(res.body)['info'];
          setState(() {
            _userInfo = UserInfo(
              userId: bodyInfo['user_id'],
              loginId: bodyInfo['login_id'],
              displayName: bodyInfo['display_name'],
              groupId: bodyInfo['group_id'],
              role: bodyInfo['role'],
              deviceId: bodyInfo['device_id'],
              sailNum: bodyInfo['sail_num'],
              courseLimit: bodyInfo['course_limit'].toDouble(),
              imageUrl: bodyInfo['image_url'],
              note: bodyInfo['note']
            );
            _ready = true;
          });
        });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop()
        )
      ),
      body: SingleChildScrollView(
        child: Center(
          child: (_ready)
            ? Container(
                child: Column(
                  children: [
                    SizedBox(
                      width: _width,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 10
                              ),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage(_userInfo.imageUrl != '' ? _userInfo.imageUrl : 'images/sample-icon.png')
                              )
                            )
                          ),
                          // Positioned(
                          //   bottom: -10,
                          //   right: 10,
                          //   child: TextButton(
                          //     child: const Text(
                          //       '画像を変更',
                          //       style: TextStyle(
                          //         color: Color.fromRGBO(100, 100, 100, 1),
                          //         fontSize: 16
                          //       )
                          //     ),
                          //     onPressed: () {}
                          //   )
                          // )
                        ]
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        _userInfo.displayName,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(roleName[_userInfo.role] ?? '不明')
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 25),
                      width: _width,
                      height: _height - 400,
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2.0),
                              1: FlexColumnWidth(3.0)
                            },
                            children: [
                              TableRow(
                                children: [
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Text('ユーザーID')
                                  ),
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(_userInfo.userId, style: const TextStyle(color: Color.fromRGBO(0, 94, 115, 1)))
                                  )
                                ]
                              ),
                              TableRow(
                                children: [
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Text('ログインID')
                                  ),
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(_userInfo.loginId, style: const TextStyle(color: Color.fromRGBO(0, 94, 115, 1)))
                                  )
                                ]
                              ),
                              TableRow(
                                children: [
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Text('グループID')
                                  ),
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(_userInfo.groupId, style: const TextStyle(color: Color.fromRGBO(0, 94, 115, 1)))
                                  )
                                ]
                              ),
                              TableRow(
                                children: [
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Text('デバイスID')
                                  ),
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(_userInfo.deviceId, style: const TextStyle(color: Color.fromRGBO(0, 94, 115, 1)))
                                  )
                                ]
                              ),
                              TableRow(
                                children: [
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Text('セイル番号')
                                  ),
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(_userInfo.sailNum.toString(), style: const TextStyle(color: Color.fromRGBO(0, 94, 115, 1)))
                                  )
                                ]
                              ),
                              TableRow(
                                children: [
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Text('コースリミット')
                                  ),
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(_userInfo.courseLimit.toString() + 'm', style: const TextStyle(color: Color.fromRGBO(0, 94, 115, 1)))
                                  )
                                ]
                              ),
                              TableRow(
                                children: [
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Text('備考')
                                  ),
                                  Container(
                                    height: 52,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(_userInfo.note, style: const TextStyle(color: Color.fromRGBO(0, 94, 115, 1)))
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      )
                    ),
                    TextButton(
                      child: const Text(
                        'ログアウトする',
                        style: TextStyle(
                          color: Color.fromRGBO(100, 100, 100, 1),
                          fontSize: 24
                        )
                      ),
                      onPressed: _handlerLogout
                    )
                  ],
                ),
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                alignment: Alignment.center,
              )
            : Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Column(
                  children: const [
                    SpinKitWave(
                      color: Color.fromRGBO(255, 84, 79, 1),
                      size: 80.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('ユーザー情報を読み込んでいます…')
                    )
                  ]
                )
              )
        )
      )
    );
  }
}
