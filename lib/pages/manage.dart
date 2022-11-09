import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:bsam_admin/models/athlete.dart';
import 'package:bsam_admin/models/live_msg.dart';

class Manage extends ConsumerStatefulWidget {
  const Manage({Key? key, required this.raceId}) : super(key: key);

  final String raceId;

  @override
  ConsumerState<Manage> createState() => _Manage();
}

class _Manage extends ConsumerState<Manage> {
  static const jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTkwODcxNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoibWFuYWdlIiwidXNlcl9pZCI6IjdkYTRlNjcwLTk5YmEtNGJhYi1iZDg0LTk3MzgwMjI5ODFiOSJ9.B0__b4LuwI_yXrPWeQuyHV6l1gVu6NnmSHNpJwcLQAc';

  static const users = {
    'e85c3e4d-21d8-4c42-be90-b79418419c40': '端末番号4',
    '925aea83-44e0-4ff3-9ce6-84a1c5190532': '端末番号5',
    '4aaee190-e8ef-4fb6-8ee9-510902b68cf4': '端末番号6',
    'd6e367e6-c630-410f-bcc7-de02da21dd3a': '端末番号7',
    'f3f4da8f-6ab0-4f0e-90a9-2689d72d2a4f': '端末番号8',
    '23d96555-5ff0-4c5d-8b03-2f1db89141f1': '端末番号9',
    'b0e968e9-8dd7-4e20-90a7-6c97834a4e88': '端末番号10',
    '605ded0a-ed1f-488b-b0ce-4ccf257c7329': '端末番号11',
    '0e9737f7-6d62-447f-ad00-bd36c4532729': '端末番号12',
    '55072870-f00e-4ab9-bc6c-1710eef5b0a0': '端末番号13',
    'a91bb4bf-1f2b-4316-9c64-1392a89a59f1': 'マーク1',
    'd09bd6b4-56e9-464d-952c-a7fbdf980d3a': 'マーク2',
    '0756bc89-71f8-440b-b680-57513d16dd29': 'マーク3'
  };

  static const marks = {
    1: ['上', 'かみ'],
    2: ['サイド', 'さいど'],
    3: ['下', 'しも']
  };

  late WebSocketChannel _channel;

  bool? _started;
  List<Athlete> _athletes = [];

  @override
  void initState() {
    super.initState();

    _connectWs();
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  _connectWs() {
    if (!mounted) {
      return;
    }

    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://sailing-assist-mie-api.herokuapp.com/v2/racing/${widget.raceId}'),
      pingInterval: const Duration(seconds: 1)
    );

    _channel.stream.listen(_readWsMsg,
      onDone: () {
        if (mounted) {
          debugPrint('reconnect');
          _connectWs();
        }
      }
    );

    try {
      _channel.sink.add(json.encode({
        'type': 'auth',
        'token': jwt
      }));
    } catch (_) {}
  }

  _receiveStartRace(dynamic msg) {
    // race status
    setState(() {
      _started = msg['started'];
    });
  }

  _receiveLive(LiveMsg msg) {
    // live data
    setState(() {
      _athletes = msg.athletes!;
    });
  }

  _readWsMsg(dynamic msg) {
    final body = json.decode(msg);

    switch (body['type']) {
    case 'start_race':
      _receiveStartRace(body);
      break;

    case 'live':
      _receiveLive(LiveMsg.fromJson(body));
      break;
    }
  }

  _startRace(bool started) {
    try {
      _channel.sink.add(json.encode({
        'type': 'start',
        'started': started
      }));
    } catch (_) {}

    setState(() {
      _started = started;
    });
  }

  _forcePassed(String userId, int markNo) {
    int nextMarkNo = markNo % 3 + 1;

    _setMarkNo(userId, markNo, nextMarkNo);
  }

  _setMarkNo(String userId, int markNo, int nextMarkNo) {
    try {
      _channel.sink.add(json.encode({
        'type': 'set_mark_no',
        'user_id': userId,
        'mark_no': markNo,
        'next_mark_no': nextMarkNo
      }));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: const Text("本当に戻りますか？"),
                  content: const Text("レースの真っ最中です。前の画面に戻るとレースを中断することになります。"),
                  actions: <Widget>[
                    // ボタン領域
                    TextButton(
                      child: const Text("いいえ"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("はい"),
                      onPressed: () {
                        int count = 0;
                        Navigator.popUntil(context, (_) => count++ >= 2);
                      }
                    ),
                  ],
                );
              },
            );
          }
        )
      ),
      body: Center(
        child: SizedBox(
          height: 650,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Text(
                      'ゴーリキマリンビレッジ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    (_started == null
                      ? const Text('読み込み中')
                      : (
                        Column(
                          children: [
                            Container(
                              child: (_started!
                                ? ElevatedButton(
                                    child: const Text(
                                      'レースを終了する'
                                    ),
                                    onPressed: () => _startRace(false)
                                  )
                                : ElevatedButton(
                                    child: const Text(
                                      'レースを開始する'
                                    ),
                                    onPressed: () => _startRace(true)
                                  )
                              )
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: width * 0.9,
                              child: Column(
                                children: [
                                  for (final athlete in _athletes)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Theme.of(context).colorScheme.secondary,
                                              width: 1
                                            )
                                          )
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  users[athlete.userId] ?? '不明',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Theme.of(context).colorScheme.tertiary,
                                                    fontWeight: FontWeight.bold
                                                  )
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20),
                                                  child: Text(
                                                    athlete.nextMarkNo != -1 ? '${marks[athlete.nextMarkNo!]![0]}マークの案内中' : '',
                                                    style: const TextStyle(
                                                      fontSize: 16
                                                    )
                                                  )
                                                )
                                              ]
                                            ),
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {_forcePassed(athlete.userId!, 1);},
                                                  child: const Text('上通過')
                                                ),
                                                TextButton(
                                                  onPressed: () {_forcePassed(athlete.userId!, 2);},
                                                  child: const Text('サイド通過')
                                                ),
                                                TextButton(
                                                  onPressed: () {_forcePassed(athlete.userId!, 3);},
                                                  child: const Text('下通過')
                                                ),
                                              ],
                                            )
                                          ]
                                        )
                                      )
                                    )
                                ]
                              )
                            )
                          ]
                        )
                      )
                    )
                  ],
                )
              )
            ]
          )
        )
      )
    );
  }
}
