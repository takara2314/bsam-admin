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

  bool _autoMoveMap = true;

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
    // final body = json.decode(msg);
    // debugPrint(body.toString());
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
    if (!_autoMoveMap || !mounted) {
      return;
    }

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_lat, _lng),
          zoom: 18
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
      _autoMoveMap = false;
    });
  }

  _changeToManual() {
    setState(() {
      _manual = true;
      _lat = _latMap;
      _lng = _lngMap;
      _accuracy = 0.0;
    });
  }

  _changeToAuto() {
    setState(() {
      _manual = false;
      _autoMoveMap = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        isReturnDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => isReturnDialog(context)
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
                        'マーク ${widget.markNo}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        '送信中です',
                        style: TextStyle(
                          fontSize: 36,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ],
                  )
                ),
                Text(
                  !_manual ? '緯度 / 経度' : '緯度 / 経度 （手動設定）',
                  style: Theme.of(context).textTheme.headline3
                ),
                Text(
                  '${_lat.toStringAsFixed(6)} / ${_lng.toStringAsFixed(6)}'
                ),
                Text(
                  '位置情報の精度',
                  style: Theme.of(context).textTheme.headline3
                ),
                Text(
                  !_manual ? '$_accuracy m' : '---'
                ),
                Container(
                  width: width,
                  height: 300,
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Stack(
                    children: [
                      GoogleMap(
                        mapType: MapType.satellite,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        markers: _mapMarkers,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_lat, _lng),
                          zoom: 18
                        ),
                        onMapCreated: _handleMapCreated,
                        onCameraMove: _handleMapMove
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Opacity(
                            opacity: 0.75,
                            child: CustomPaint(
                              painter: MapCrossPainter(),
                            )
                          )
                        )
                      ),
                      Align(
                        alignment: const Alignment(0.8, 0.9),
                        child: Visibility(
                          visible: !_autoMoveMap,
                          child: ElevatedButton(
                            onPressed: _changeToManual,
                            child: const Text('ここをマークにする')
                          )
                        )
                      )
                    ]
                  )
                ),
                Visibility(
                  visible: _manual,
                  child: ElevatedButton(
                    onPressed: _changeToAuto,
                    child: const Text('現在位置をマークにする')
                  )
                ),
                Visibility(
                  visible: _autoMoveMap,
                  child: const Text('自動移動有効')
                )
              ]
            )
          )
        )
      )
    );
  }
}

class MapCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void isReturnDialog(BuildContext context) {
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
