import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class Manage extends ConsumerStatefulWidget {
  const Manage({Key? key, required this.raceId}) : super(key: key);

  final String raceId;

  @override
  ConsumerState<Manage> createState() => _Manage();
}

class _Manage extends ConsumerState<Manage> {
  static const jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2OTgwNDc4NjksIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiI3ZGE0ZTY3MC05OWJhLTRiYWItYmQ4NC05NzM4MDIyOTgxYjkifQ.XQk1_i4J-xSDhBogV7nwTwZxq6kwrnbxUOmDKS56lus';

  late WebSocketChannel _channel;

  bool? _started;

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

  _readWsMsg(dynamic msg) {
    final body = json.decode(msg);
    debugPrint(body.toString());

    switch (body['type']) {
    case 'start_race':
      _receiveStartRace(body);
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

  @override
  Widget build(BuildContext context) {
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
                      : (_started!
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
