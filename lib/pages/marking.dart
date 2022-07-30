import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wakelock/wakelock.dart';

import 'package:bsam_admin/providers.dart';

class Marking extends ConsumerStatefulWidget {
  const Marking({Key? key, required this.raceId}) : super(key: key);

  final String raceId;

  @override
  ConsumerState<Marking> createState() => _Marking();
}

class _Marking extends ConsumerState<Marking> {
  late WebSocketChannel _channel;
  late Timer _timerSendPos;

  double _lat = 0.0;
  double _lng = 0.0;
  double _accuracy = 0.0;

  @override
  void initState() {
    super.initState();

    // Screen lock
    Wakelock.enable();

    _sendPosition(null);
    _timerSendPos = Timer.periodic(
      const Duration(seconds: 1),
      _sendPosition
    );

    _connectWs();
  }

  @override
  void dispose() {
    _timerSendPos.cancel();
    _channel.sink.close(status.goingAway);
    Wakelock.disable();
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

    final jwt = ref.read(jwtProvider);
    try {
      _channel.sink.add(json.encode({
        'type': 'auth',
        'token': jwt
      }));
    } catch (_) {}
  }

  _readWsMsg(dynamic msg) {
    final body = json.decode(msg);
    debugPrint(body.toString());
  }

  _getPosition() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    if (pos.accuracy > 15.0 || !mounted) {
      return;
    }

    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _accuracy = pos.accuracy;
    });
  }

  _sendPosition(Timer? timer) async {
    await _getPosition();

    try {
      _channel.sink.add(json.encode({
        'type': 'position',
        'latitude': _lat,
        'longitude': _lng
      }));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop()
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              '送信中です',
              style: TextStyle(
                fontSize: 28
              )
            )
          ]
        )
      )
    );
  }
}
