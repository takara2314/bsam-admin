import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:sailing_assist_mie_admin/pages/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sailing_assist_mie_admin/providers.dart';
import 'package:sailing_assist_mie_admin/pages/place/select.dart' as place;

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _Home();
}

class _Home extends ConsumerState<Home> {
  bool _isAllowedLocation = false;
  bool _requiredLogin = true;

  String _loginMessage = 'ログインしてください。';

  String _loginId = '';
  String _password = '';

  bool _ready = false;

  @override
  void initState() {
    super.initState();

    () async {
      PermissionStatus permLocation = await Permission.location.status;

      if (permLocation == PermissionStatus.denied) {
        permLocation = await Permission.location.request();
        setState(() {
          _isAllowedLocation = permLocation != PermissionStatus.denied;
        });

      } else {
        setState(() {
          _isAllowedLocation = true;
        });
      }

      await _checkAuth();
    }();
  }

  _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _requiredLogin = true;
      });
    } else {
      final valid = await _checkToken(token);

      if (valid) {
        final userId = ref.read(userIdProvider.notifier);
        userId.state = Jwt.parseJwt(token)['user_id'];
        setState(() {
          _requiredLogin = false;
        });
      }
    }

    setState(() {
      _ready = true;
    });
  }

  _updateDeviceId(String userId) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    try {
      http.put(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': androidInfo.androidId.toString()
        })
      );
    } catch (_) {}
  }

  _checkToken(String token) async {
    try {
      final res = await http.post(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token
        })
      );
      if (res.statusCode != 200) {
        return false;
      }
      return true;
    } catch (_) {}
  }

  _handlerLoginId(String loginId) {
    setState(() {
      _loginId = loginId;
    });
  }

  _handlerPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  _handlerLoginButton() {
    if (_loginId == '' || _password == '') {
      setState(() {
        _loginMessage = 'IDとパスワードの両方を入力してください。';
      });
      return;
    }

    try {
      http.post(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/auth/password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login_id': _loginId,
          'password': _password
        })
      )
        .then((res) {
          switch (res.statusCode) {
            case 200:
              final body = json.decode(res.body);
              final payload = Jwt.parseJwt(body['token']);
              setState(() {
                _requiredLogin = false;
              });
              () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', body['token']);
                await prefs.setString('userId', payload['user_id']);
              }();
              final userId = ref.read(userIdProvider.notifier);
              userId.state = payload['user_id'];
              _updateDeviceId(payload['user_id']);
              break;

            case 403:
              setState(() {
                _loginMessage = 'IDもしくはパスワードが間違っています。';
              });
              break;

            default:
              setState(() {
                _loginMessage = 'サーバーエラーが発生しました。';
              });
              break;
          }
        });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: (_ready)
            ? Column(
                children: [
                  Container(
                    child: const _Logo(),
                    margin: !_requiredLogin ? const EdgeInsets.only(top: 70, bottom: 70) : const EdgeInsets.only(top: 70, bottom: 40)
                  ),
                  (!_requiredLogin)?(
                    SizedBox(
                      child: Column(
                        children: [
                          ElevatedButton(
                            child: const Text(
                              'マークを設置',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500
                              )
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const place.Select(),
                                )
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromRGBO(0, 98, 104, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              minimumSize: const Size(280, 60)
                            )
                          ),
                          ElevatedButton(
                            child: const Text(
                              'マークを設定',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500
                              )
                            ),
                            onPressed: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => const manage.Select(),
                              //   )
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromRGBO(0, 98, 104, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              minimumSize: const Size(280, 60)
                            )
                          ),
                          ElevatedButton(
                            child: const Text(
                              'レースを企画する',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500
                              )
                            ),
                            onPressed: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => const Create(),
                              //   )
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromRGBO(0, 98, 104, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              minimumSize: const Size(280, 60)
                            )
                          ),
                          TextButton(
                            child: const Text(
                              '設定する',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500
                              )
                            ),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const Settings(),
                                )
                              );
                              await _checkAuth();
                            }
                          ),
                          Visibility(
                            visible: !_isAllowedLocation,
                            child: const Text(
                              '位置情報が有効になっていません！',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold
                              )
                            )
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      height: 300
                    )
                  ):(
                    SizedBox(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    _loginMessage,
                                    style: const TextStyle(
                                      fontSize: 20
                                    )
                                  )
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'ログインID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    )
                                  )
                                ),
                                TextField(
                                  style: const TextStyle(fontSize: 20),
                                  onChanged: _handlerLoginId
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Text(
                                    'パスワード',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    )
                                  )
                                ),
                                TextField(
                                  obscureText: true,
                                  style: const TextStyle(fontSize: 20),
                                  onChanged: _handlerPassword
                                )
                              ]
                            )
                          ),
                          ElevatedButton(
                            child: const Text(
                              'ログイン',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500
                              )
                            ),
                            onPressed: _handlerLoginButton,
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromRGBO(0, 98, 104, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              minimumSize: const Size(280, 60)
                            )
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      height: 300
                    )
                  )
                ]
              )
            : Padding(
                padding: const EdgeInsets.only(top: 300),
                child: Column(
                  children: const [
                    SpinKitWave(
                      color: Color.fromRGBO(255, 84, 79, 1),
                      size: 80.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('準備しています…')
                    )
                  ]
                )
              )
        )
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: const [
            Text(
              'Sailing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 42, 149, 1),
                fontSize: 60
              )
            ),
            Text(
              'Assist',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 42, 149, 1),
                fontSize: 60
              )
            ),
            Text(
              'Mie',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 42, 149, 1),
                fontSize: 60
              )
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start
        ),
        const Positioned(
          right: 0.0,
          bottom: 12.5,
          child: Text(
            '本部用',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(0, 119, 112, 6),
              fontSize: 25
            )
          )
        )
      ]
    );
  }
}
