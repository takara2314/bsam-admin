import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  State<Create> createState() => _Create();
}

class _Create extends State<Create> {
  String _name = '';
  String _memo = '';

  String _message = '';

  DateTime _startAt = DateTime.now();
  DateTime _endAt = DateTime.now().add(Duration(hours: 1));

  final DateFormat dateFormat = DateFormat('y年M月d日');
  final DateFormat timeFormat = DateFormat('H時m分');

  @override
  void initState() {
    super.initState();
  }

  // _getUserInfo() {
  //   final userId = ref.read(userIdProvider);
  //   try {
  //     http.get(
  //       Uri.parse('https://sailing-assist-mie-api.herokuapp.com/user/$userId')
  //     )
  //       .then((res) {
  //         if (res.statusCode != 200) {
  //           return;
  //         }

  //         final bodyInfo = json.decode(res.body)['info'];
  //         setState(() {
  //           _userInfo = UserInfo(
  //             userId: bodyInfo['user_id'],
  //             loginId: bodyInfo['login_id'],
  //             displayName: bodyInfo['display_name'],
  //             groupId: bodyInfo['group_id'],
  //             role: bodyInfo['role'],
  //             deviceId: bodyInfo['device_id'],
  //             sailNum: bodyInfo['sail_num'],
  //             courseLimit: bodyInfo['course_limit'].toDouble(),
  //             imageUrl: bodyInfo['image_url'],
  //             note: bodyInfo['note']
  //           );
  //           _ready = true;
  //         });
  //       });
  //   } catch (_) {}
  // }

  _handlerName(String name) {
    setState(() {
      _name = name;
    });
  }

  _handlerMemo(String memo) {
    setState(() {
      _memo = memo;
    });
  }

  _handlerStartAt() {
    DatePicker.showDateTimePicker(context,
      showTitleActions: true,
      onConfirm: (DateTime date) {
        setState(() {
          _startAt = date;
        });
      },
      currentTime: _startAt,
      locale: LocaleType.jp
    );
  }

  _handlerEndAt() {
    DatePicker.showDateTimePicker(context,
      showTitleActions: true,
      onConfirm: (DateTime date) {
        setState(() {
          _endAt = date;
        });
      },
      currentTime: _endAt,
      locale: LocaleType.jp
    );
  }

  _handlerCreate() {
    if (_name == '') {
      setState(() {
        _message = 'タイトルを入力してください。';
      });
      return;
    }

    try {
      http.post(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/races'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _name,
          'start_at': _startAt.toString(),
          'end_at': _endAt.toString(),
          'memo': _memo,
          'is_holding': false
        })
      )
        .then((res) {
          if (res.statusCode != 200) {
            setState(() {
              _message = 'サーバーエラーが発生しました。';
            });
            return;
          }

          setState(() {
            _message = 'レースを登録しました。';
            _name = '';
            _memo = '';
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
        title: const Text('レースを企画する'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop()
        )
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                child: Text(_message),
                height: 50
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: const Text('タイトル', style: TextStyle(fontWeight: FontWeight.bold))
                )
              ),
              TextField(
                style: const TextStyle(fontSize: 20),
                onChanged: _handlerName
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: const Text('開始', style: TextStyle(fontWeight: FontWeight.bold))
                            )
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: ElevatedButton(
                              child: Column(
                                children: [
                                  Text(dateFormat.format(_startAt), style: const TextStyle(color: Colors.black)),
                                  Text(timeFormat.format(_startAt), style: const TextStyle(color: Colors.black))
                                ]
                              ),
                              onPressed: _handlerStartAt,
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(209, 238, 248, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                elevation: 0,
                                minimumSize: const Size(140, 50)
                              )
                            )
                          )
                        ]
                      )
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: const Text('終了', style: TextStyle(fontWeight: FontWeight.bold))
                            )
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: ElevatedButton(
                              child: Column(
                                children: [
                                  Text(dateFormat.format(_endAt), style: const TextStyle(color: Colors.black)),
                                  Text(timeFormat.format(_endAt), style: const TextStyle(color: Colors.black))
                                ]
                              ),
                              onPressed: _handlerEndAt,
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(209, 238, 248, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                elevation: 0,
                                minimumSize: const Size(140, 50)
                              )
                            )
                          )
                        ]
                      )
                    )
                  ]
                )
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: const Text('メモ', style: TextStyle(fontWeight: FontWeight.bold))
                )
              ),
              TextField(
                style: const TextStyle(fontSize: 20),
                onChanged: _handlerMemo
              ),
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: ElevatedButton(
                  child: const Text(
                    '作成する',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                    )
                  ),
                  onPressed: _handlerCreate,
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(4, 111, 171, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    minimumSize: const Size(100, 50)
                  )
                )
              )
            ],
          ),
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.topLeft,
        )
      )
    );
  }
}
