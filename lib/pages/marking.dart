import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wakelock/wakelock.dart';

import 'package:bsam_admin/providers.dart';

class Marking extends ConsumerStatefulWidget {
  const Marking({Key? key, required this.raceId, required this.markNo}) : super(key: key);

  final String raceId;
  final int markNo;

  @override
  ConsumerState<Marking> createState() => _Marking();
}

class _Marking extends ConsumerState<Marking> {
  late WebSocketChannel _channel;
  late Timer _timerSendPos;
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _mapMarkers = <Marker>{};

  double _lat = 0.0;
  double _lng = 0.0;
  double _accuracy = 0.0;

  bool _manual = false;
  double _latMap = 0.0;
  double _lngMap = 0.0;

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
        'token': jwt,
        'mark_no': widget.markNo
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
    if (!_manual) {
      await _getPosition();
      _updateMapPosition();
    }

    try {
      _channel.sink.add(json.encode({
        'type': 'position',
        'latitude': _lat,
        'longitude': _lng
      }));
    } catch (_) {}
  }

  _updateMapPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_lat, _lng),
          zoom: 11.7
        )
      )
    );
  }

  _handleMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _handleMapMove(CameraPosition position) {
    setState(() {
      _latMap = position.target.latitude;
      _lngMap = position.target.longitude;
    });
  }

  _changeToManual() {
    setState(() {
      _manual = true;
    });
  }

  _changeToAuto() {
    setState(() {
      _manual = false;
      _lat = _latMap;
      _lng = _lngMap;
      _accuracy = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '送信中です',
              style: TextStyle(
                fontSize: 28
              )
            ),
            Text(
              '緯度: $_lat / 経度: $_lng'
            ),
            Text(
              '精度: $_accuracy m'
            ),
            SizedBox(
              width: width,
              height: 300,
              child: GoogleMap(
                mapType: MapType.satellite,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: _mapMarkers,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_lat, _lng),
                  zoom: 11.7
                ),
                onMapCreated: _handleMapCreated,
                onCameraMove: _handleMapMove
              )
            ),
            ElevatedButton(
              onPressed: !_manual ? _changeToManual : _changeToAuto,
              child: Text(
                !_manual ? '真ん中をマークの位置に固定する' : '現在位置をマークにする'
              )
            )
          ]
        )
      )
    );
  }
}
