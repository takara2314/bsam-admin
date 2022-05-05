import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Manage extends StatefulWidget {
  const Manage({Key? key, required this.raceId, required this.raceName}) : super(key: key);

  final String raceId;
  final String raceName;

  @override
  State<Manage> createState() => _Manage();
}

class _Manage extends State<Manage> {
  String _name = '';
  String _memo = '';

  String _message = '';

  bool _ready = false;
  bool _isHolding = false;

  DateTime _startAt = DateTime.now();
  DateTime _endAt = DateTime.now().add(Duration(hours: 1));

  final DateFormat dateFormat = DateFormat('y年M月d日');
  final DateFormat timeFormat = DateFormat('H時m分');

  TextEditingController nameController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRaceInfo();
  }

  _loadRaceInfo() {
    try {
      http.get(Uri.parse('https://sailing-assist-mie-api.herokuapp.com/race/${widget.raceId}'),)
        .then((res) {
          if (res.statusCode != 200) {
            setState(() {
              _message = 'サーバーエラーが発生しました。';
            });
            return;
          }

          final body = json.decode(res.body);

          nameController.text = body['race']['name'];
          memoController.text = body['race']['memo'] ?? '';

          setState(() {
            _name = body['race']['name'];
            _memo = body['race']['memo'] ?? '';
            _startAt = DateTime.parse(body['race']['start_at']);
            _endAt = DateTime.parse(body['race']['end_at']);
            _isHolding = body['race']['is_holding'];
            _ready = true;
          });
        });
    } catch (_) {}
  }

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

  _handlerUpdate() {
    if (_name == '') {
      setState(() {
        _message = 'タイトルを入力してください。';
      });
      return;
    }

    try {
      http.put(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/race/${widget.raceId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _name,
          'start_at': _startAt.toString(),
          'end_at': _endAt.toString(),
          'memo': _memo,
          'is_holding': _isHolding
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
            _message = 'レースを更新しました。';
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
        title: Text(widget.raceName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop()
        )
      ),
      body: SingleChildScrollView(
        child:
          (_ready)
          ? Container(
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
                    onChanged: _handlerName,
                    controller: nameController
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
                    onChanged: _handlerMemo,
                    controller: memoController
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      child: const Text(
                        '更新する',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        )
                      ),
                      onPressed: _handlerUpdate,
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
          : Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Column(
                  children: const [
                    SpinKitWave(
                      color: Color.fromRGBO(255, 84, 79, 1),
                      size: 80.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('レース情報を読み込んでいます…')
                    )
                  ]
                )
              )
          )
      )
    );
  }
}
