import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:bsam_admin/models/athlete.dart';
import 'package:bsam_admin/models/live_msg.dart';
import 'package:bsam_admin/providers.dart';
import 'package:bsam_admin/utils/random.dart';

class Manage extends ConsumerStatefulWidget {
  const Manage({Key? key, required this.assocId}) : super(key: key);

  final String assocId;

  @override
  ConsumerState<Manage> createState() => _Manage();
}

class _Manage extends ConsumerState<Manage> {
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

    // Get server url
    final serverUrl = ref.read(serverUrlProvider);

    _channel = IOWebSocketChannel.connect(
      Uri.parse('$serverUrl/racing/${widget.assocId}'),
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

    final token = ref.read(jwtProvider);

    try {
      _channel.sink.add(json.encode({
        'type': 'auth',
        'token': token,
        'user_id': generateRandomStr(8),
        'role': 'manager'
      }));
    } catch (_) {}
  }

  _receiveStartRace(dynamic msg) {
    // race status
    if (!mounted){
      return;
    }

    setState(() {
      _started = msg['started'];
    });
  }

  _receiveLive(LiveMsg msg) {
    // live data
    if (!mounted){
      return;
    }

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

    _setNextMarkNo(userId, nextMarkNo);
  }

  _setNextMarkNo(String userId, int nextMarkNo) {
    try {
      _channel.sink.add(json.encode({
        'type': 'set_mark_no',
        'user_id': userId,
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
          onPressed: () => Navigator.pop(context)
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
                      'セーリング団体名',
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
                                                  athlete.userId!,
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
