import 'package:bsam_admin/components/pop_app_bar.dart';
import 'package:bsam_admin/pages/manage/marks_area.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:bsam_admin/models/athlete.dart';
import 'package:bsam_admin/models/mark.dart';
import 'package:bsam_admin/models/live_msg.dart';
import 'package:bsam_admin/providers.dart';
import 'package:bsam_admin/pages/manage/athletes_area.dart';
import 'package:bsam_admin/pages/manage/start_stop_button.dart';
import 'package:bsam_admin/utils/random.dart';

class Manage extends ConsumerStatefulWidget {
  const Manage({super.key, required this.assocId});

  final String assocId;

  @override
  ConsumerState<Manage> createState() => _Manage();
}

class _Manage extends ConsumerState<Manage> {
  static const markNum = 3;

  static const markNames = {
    1: ['上', 'かみ', '①'],
    2: ['サイド', 'さいど', '②'],
    3: ['下', 'しも', '③']
  };

  late WebSocketChannel _channel;

  bool? _started;
  List<Athlete> _athletes = [];
  List<Mark> _marks = [];

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
      _marks = msg.marks!;
    });
  }

  _readWsMsg(dynamic msg) {
    final body = json.decode(msg);

    switch (body['type']) {
    case 'start_race':
      debugPrint('start_race');
      _receiveStartRace(body);
      break;

    case 'live':
      debugPrint('live');
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

  _forcePassed(String userId, int nextMarkNo) {
    nextMarkNo = nextMarkNo % markNum + 1;

    _setNextMarkNo(userId, nextMarkNo);
  }

  _cancelPassed(String userId, int nextMarkNo) {
    int previousMarkNo = nextMarkNo - 1 == 0 ? markNum : nextMarkNo - 1;

    _setNextMarkNo(userId, previousMarkNo);
  }

  _setNextMarkNo(String userId, int nextMarkNo) {
    try {
      _channel.sink.add(json.encode({
        'type': 'set_next_mark_no',
        'user_id': userId,
        'next_mark_no': nextMarkNo
      }));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PopAppBar(
        pageName: 'レース管理'
      ),
      body: SingleChildScrollView(
        child: Center(
          child: (_started == null
            ? const Text('読み込み中')
            : Column(
                children: [
                  StartStopButton(
                    started: _started!,
                    startRace: _startRace
                  ),
                  MarksArea(
                    markNames: markNames,
                    marks: _marks
                  ),
                  AthletesArea(
                    markNames: markNames,
                    athletes: _athletes,
                    forcePassed: _forcePassed,
                    cancelPassed: _cancelPassed
                  )
                ]
              )
            )
        )
      )
    );
  }
}
