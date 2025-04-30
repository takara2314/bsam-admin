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
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:bsam_admin/constants/app_constants.dart';
import 'package:bsam_admin/providers.dart';
import 'package:bsam_admin/pages/mark/pop_dialog.dart';
import 'package:bsam_admin/pages/mark/app_bar.dart';
import 'package:bsam_admin/pages/mark/debug_area.dart';
import 'package:bsam_admin/pages/mark/map_area.dart';
import 'package:bsam_admin/pages/mark/sending_area.dart';

class Mark extends ConsumerStatefulWidget {
  const Mark({
    super.key,
    required this.assocId,
    required this.userId,
    required this.markNo
  });

  final String assocId;
  final String userId;
  final int markNo;

  @override
  ConsumerState<Mark> createState() => _Mark();
}

class _Mark extends ConsumerState<Mark> {
  late WebSocketChannel _channel;
  bool _disposed = false;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  Timer? _timerSendPos;
  Timer? _timerBattery;
  Timer? _timerAutoMapMove;

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
  bool _mapAnimating = false;
  bool _autoMovingMap = false;

  bool _receivedInfoServer = false;
  bool _sentPosition = false;

  @override
  void initState() {
    super.initState();

    // Screen lock
    WakelockPlus.enable();

    _startLocationTimer();
    _startBatteryTimer();
    _startAutoMapMoveTimer();
    _connectWs();
  }

  void _startLocationTimer() {
    _sendPosition(null);
    _timerSendPos = Timer.periodic(
      Duration(milliseconds: AppConstants.locationUpdateInterval),
      _sendPosition
    );
  }

  void _startBatteryTimer() {
    _sendBattery(null);
    _timerBattery = Timer.periodic(
      Duration(milliseconds: AppConstants.batteryUpdateInterval),
      _sendBattery
    );
  }

  void _startAutoMapMoveTimer() {
    _moveMapAutomatically(null);
    _timerAutoMapMove = Timer.periodic(
      const Duration(seconds: 10),
      _moveMapAutomatically
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelAllTimers();
    _closeWsConnection();
    _reconnectTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _cancelAllTimers() {
    _timerSendPos?.cancel();
    _timerBattery?.cancel();
    _timerAutoMapMove?.cancel();
  }

  void _closeWsConnection() {
    try {
      if (_isConnected) {
        _channel.sink.close(status.normalClosure);
        _isConnected = false;
      }
    } catch (e) {
      debugPrint('WebSocket切断エラー: $e');
    }
  }

  void _connectWs() {
    if (_disposed || !mounted) {
      return;
    }

    // 接続中なら一度閉じる
    _closeWsConnection();

    try {
      // Get server url
      final serverUrl = ref.read(serverUrlProvider);

      _channel = IOWebSocketChannel.connect(
        Uri.parse('$serverUrl/racing/${widget.assocId}'),
        pingInterval: const Duration(seconds: 1)
      );

      _isConnected = true;

      _channel.stream.listen(
        (msg) {
          _handleWsMessage(msg);
        },
        onDone: () {
          _handleWsDisconnection();
        },
        onError: (error) {
          debugPrint('WebSocketエラー: $error');
          _handleWsDisconnection();
        }
      );

      if (_disposed || !mounted) return;

      final jwt = ref.read(jwtProvider);
      _sendWsMessage({
        'type': 'auth',
        'token': jwt,
        'user_id': widget.userId,
        'role': 'mark',
        'mark_no': widget.markNo
      });
    } catch (e) {
      debugPrint('WebSocket接続エラー: $e');
      _scheduleReconnect();
    }
  }

  void _handleWsDisconnection() {
    if (_disposed) return;

    _isConnected = false;
    debugPrint('WebSocket切断: 再接続をスケジュール');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || !mounted) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      const Duration(seconds: AppConstants.wsReconnectInterval),
      () {
        if (!_disposed && mounted) {
          debugPrint('WebSocket再接続試行');
          _connectWs();
        }
      }
    );
  }

  void _handleWsMessage(dynamic msg) {
    if (_disposed || !mounted) return;

    try {
      _readWsMsg(msg);
    } catch (e) {
      debugPrint('メッセージ処理エラー: $e');
    }
  }

  void _sendWsMessage(Map<String, dynamic> message) {
    if (_disposed || !mounted || !_isConnected) return;

    try {
      _channel.sink.add(json.encode(message));
    } catch (e) {
      debugPrint('メッセージ送信エラー: $e');
      _handleWsDisconnection();
    }
  }

  void _readWsMsg(dynamic msg) {
    if (_disposed || !mounted) return;

    setState(() {
      _receivedInfoServer = true;
    });
  }

  Future<void> _getPosition() async {
    if (_disposed || !mounted) return;

    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      if (_disposed || !mounted) return;

      if (pos.accuracy > AppConstants.locationAccuracyThreshold) {
        return;
      }

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _accuracy = pos.accuracy;
      });
    } catch (e) {
      debugPrint('位置情報取得エラー: $e');
    }
  }

  void _sendPosition(Timer? timer) async {
    if (_disposed || !mounted) return;

    try {
      if (!_manual) {
        await _getPosition();
      }

      if (_disposed || !mounted) return;

      _sendWsMessage({
        'type': 'position',
        'latitude': _lat,
        'longitude': _lng,
        'accuracy': _accuracy
      });

      if (_disposed || !mounted) return;

      setState(() {
        _sentPosition = true;
      });
    } catch (e) {
      debugPrint('位置情報送信エラー: $e');
    }
  }

  void _moveMapAutomatically(Timer? timer) {
    if (_disposed || !mounted) return;

    if (!_manual) {
      _updateMapPosition();
    }
  }

  void _sendBattery(Timer? timer) async {
    if (_disposed || !mounted) return;

    try {
      final level = await _getBattery();

      if (_disposed || !mounted) return;

      _sendWsMessage({
        'type': 'battery',
        'level': level
      });
    } catch (e) {
      debugPrint('バッテリー情報送信エラー: $e');
    }
  }

  Future<int> _getBattery() async {
    try {
      return await battery.batteryLevel;
    } catch (e) {
      debugPrint('バッテリー情報取得エラー: $e');
      return 0;
    }
  }

  Future<void> _updateMapPosition() async {
    if (_disposed || !mounted) return;

    if (!_autoMoveMap || _mapAnimating) {
      return;
    }

    if (_lat == 0.0 && _lng == 0.0) {
      if (_disposed || !mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));

      if (_disposed || !mounted) return;

      return _updateMapPosition();
    }

    setState(() {
      _mapAnimating = true;
      _autoMovingMap = true;
    });

    try {
      final GoogleMapController controller = await _controller.future;

      if (_disposed || !mounted) return;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_lat, _lng),
            zoom: 18
          )
        )
      );

      if (_disposed || !mounted) return;

      await Future.delayed(const Duration(seconds: 2));

      if (_disposed || !mounted) return;

      setState(() {
        _mapAnimating = false;
        _autoMovingMap = false;
      });
    } catch (e) {
      debugPrint('マップ位置更新エラー: $e');

      if (_disposed || !mounted) return;

      setState(() {
        _mapAnimating = false;
        _autoMovingMap = false;
      });
    }
  }

  void _handleMapCreated(GoogleMapController controller) {
    if (_disposed || !mounted) return;

    _controller.complete(controller);
  }

  void _handleMapMove(CameraPosition position) {
    if (_disposed || !mounted) return;

    setState(() {
      _latMap = position.target.latitude;
      _lngMap = position.target.longitude;
    });
  }

  void _handleCameraMoveStarted() {
    if (_disposed || !mounted) return;
    
    if (_autoMovingMap) {
      return;
    }

    setState(() {
      _autoMoveMap = false;
    });
  }

  void _changeToManual() {
    if (_disposed || !mounted) return;

    setState(() {
      _manual = true;
      _lat = _latMap;
      _lng = _lngMap;
      _accuracy = 0.0;
    });
  }

  void _changeToAuto() {
    if (_disposed || !mounted) return;

    setState(() {
      _manual = false;
      _autoMoveMap = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          isPopDialog(context);
        }
      },
      child: Scaffold(
        appBar: const MarkAppBar(),
        body: Center(
          child: SizedBox(
            height: 650,
            child: Column(
              children: [
                SendingArea(
                  markNames: AppConstants.standardMarkNames,
                  markNo: widget.markNo,
                  receivedInfoServer: _receivedInfoServer,
                  sentPosition: _sentPosition,
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
                  onCameraMoveStarted: _handleCameraMoveStarted,
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
