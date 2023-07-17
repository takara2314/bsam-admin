import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:wakelock/wakelock.dart';

import 'package:bsam_admin/providers.dart';
import 'package:bsam_admin/pages/mark/pop_dialog.dart';
import 'package:bsam_admin/pages/mark/app_bar.dart';
import 'package:bsam_admin/pages/mark/debug_area.dart';
import 'package:bsam_admin/pages/mark/map_area.dart';
import 'package:bsam_admin/pages/mark/sending_area.dart';

class Mark extends ConsumerStatefulWidget {
  const Mark({
    Key? key,
    required this.assocId,
    required this.userId,
    required this.markNo
  }) : super(key: key);

  final String assocId;
  final String userId;
  final int markNo;

  @override
  ConsumerState<Mark> createState() => _Mark();
}

class _Mark extends ConsumerState<Mark> {
  late WebSocketChannel _channel;

  late Timer _timerSendPos;
  late Timer _timerBattery;

  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _mapMarkers = <Marker>{};
  final Battery battery = Battery();

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

    _sendBattery(null);
    _timerBattery = Timer.periodic(
      const Duration(seconds: 10),
      _sendBattery
    );

    _connectWs();
  }

  @override
  void dispose() {
    _timerSendPos.cancel();
    _timerBattery.cancel();
    _channel.sink.close(status.goingAway);
    Wakelock.disable();
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

    final jwt = ref.read(jwtProvider);
    try {
      _channel.sink.add(json.encode({
        'type': 'auth',
        'token': jwt,
        'user_id': widget.userId,
        'role': 'mark',
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

    if (pos.accuracy > 30.0 || !mounted) {
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
        'longitude': _lng,
        'accuracy': _accuracy
      }));
    } catch (_) {}
  }

  _sendBattery(Timer? timer) async {
    final level = await _getBattery();

    try {
      _channel.sink.add(json.encode({
        'type': 'battery',
        'level': level
      }));
    } catch (_) {}
  }

  Future<int> _getBattery() async {
    return await battery.batteryLevel;
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
    return WillPopScope(
      onWillPop: () async {
        isPopDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: const MarkAppBar(),
        body: Center(
          child: SizedBox(
            height: 650,
            child: Column(
              children: [
                SendingArea(
                  markNo: widget.markNo
                ),
                DebugArea(
                  latitude: _lat,
                  longitude: _lng,
                  accuracy: _accuracy,
                  manual: _manual
                ),
                MapArea(
                  latitude: _lat,
                  longitude: _lng,
                  accuracy: _accuracy,
                  manual: _manual,
                  autoMoveMap: _autoMoveMap,
                  mapMarkers: _mapMarkers,
                  onMapCreated: _handleMapCreated,
                  onCameraMove: _handleMapMove,
                  changeToManual: _changeToManual,
                  changeToAuto: _changeToAuto
                )
              ]
            )
          )
        )
      )
    );
  }
}
