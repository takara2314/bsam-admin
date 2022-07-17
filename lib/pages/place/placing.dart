import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'package:sailing_assist_mie_admin/providers.dart';

class Placing extends ConsumerStatefulWidget {
  const Placing({Key? key, required this.raceId, required this.raceName}) : super(key: key);

  final String raceId;
  final String raceName;

  @override
  ConsumerState<Placing> createState() => _Placing();
}

class _Placing extends ConsumerState<Placing> {
  static const marks = <int, List<String>>{
    1: ['①', '上マーク'],
    2: ['②', 'サイドマーク'],
    3: ['③', '下マーク']
  };

  late Timer _timer;
  late WebSocketChannel _channel;
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _mapMarkers = <Marker>{};

  double _latitude = 0.0;
  double _longitude = 0.0;

  int _pointNo = 1;
  bool _readyPointA = false;
  bool _readyPointB = false;
  bool _readyPointC = false;
  bool _pointRegistered = false;

  final List<BitmapDescriptor> _iconPoints = <BitmapDescriptor>[];

  final List<MarkerId> _markerIds = const <MarkerId>[
    MarkerId('pointA'),
    MarkerId('pointB'),
    MarkerId('pointC'),
  ];

  @override
  void initState() {
    super.initState();

    // Screen lock
    Wakelock.enable();

    _getPosition(null);
    _timer = Timer.periodic(
      const Duration(seconds: 5 * 60),
      _getPosition
    );

    () async {
      await getBytesFromAsset('images/icon_point_a.png', 64).then((onValue) {
        _iconPoints.add(BitmapDescriptor.fromBytes(onValue));
      });
      await getBytesFromAsset('images/icon_point_b.png', 64).then((onValue) {
        _iconPoints.add(BitmapDescriptor.fromBytes(onValue));
      });
      await getBytesFromAsset('images/icon_point_c.png', 64).then((onValue) {
        _iconPoints.add(BitmapDescriptor.fromBytes(onValue));
      });

      _createMarkerPos();
    }();

    _connectWs();
  }

  @override
  void dispose() {
    _timer.cancel();
    _channel.sink.close(status.goingAway);
    Wakelock.disable();
    super.dispose();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  _getPosition(Timer? timer) async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
    });

    () async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_latitude, _longitude),
            zoom: 19.151926040649414
          )
        )
      );
    }();

    try {
      _channel.sink.add(json.encode({
        'latitude': pos.latitude,
        'longitude': pos.longitude
      }));
    } catch (_) {}
  }

  _connectWs() {
    if (!mounted) {
      return;
    }

    // debugPrint('今から開始します！');

    final userId = ref.read(userIdProvider);
    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://sailing-assist-mie-api.herokuapp.com/racing/${widget.raceId}?user=$userId'),
      pingInterval: const Duration(seconds: 1)
    );

    _channel.stream.listen(_readWsMsg,
      onDone: () {
        if (!_pointRegistered) {
          // debugPrint('これは再接続ですね…！');
          _connectWs();
        }
      }
    );
  }

  _connectWsAsPoint() {
    if (!mounted) {
      return;
    }

    final userId = ref.read(userIdProvider);
    // debugPrint('実行！！');
    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://sailing-assist-mie-api.herokuapp.com/racing/${widget.raceId}?user=$userId&point=$_pointNo'),
      pingInterval: const Duration(seconds: 1)
    );

    _channel.stream.listen(_readWsMsgAsPoint,
      onDone: () {
        // debugPrint('これは再接続やで…！');
        _connectWsAsPoint();
      }
    );
  }

  _readWsMsg(dynamic message) {
    // debugPrint(message.toString());
    final body = json.decode(message);

    _availableCheck(body);
  }

  _createMarkerPos() {
    int counter = 0;
    for (List<String> info in marks.values) {
      _mapMarkers.add(
        Marker(
          markerId: _markerIds[counter],
          position: const LatLng(0.0, 0.0),
          icon: _iconPoints[counter]
        )
      );
      counter++;
    }
  }

  _changeMarkerPos(MarkerId id, LatLng pos) {
    final Set<Marker> tmp = <Marker>{};

    for (Marker m in _mapMarkers) {
      if (m.markerId != id) {
        tmp.add(m);
        continue;
      }

      tmp.add(
        Marker(
          markerId: m.markerId,
          position: pos,
          icon: m.icon
        )
      );
    }

    // debugPrint(tmp.length.toString());
    // debugPrint(tmp.toString());

    _mapMarkers.clear();
    _mapMarkers.addAll(tmp);
  }

  _availableCheck(dynamic body) {
    if (!body.containsKey('next')) {
      if (body['point_a']['device_id'] != '') {
        setState(() {
          _readyPointA = true;
        });
        _changeMarkerPos(_markerIds[0], LatLng(body['point_a']['latitude'], body['point_a']['longitude']));
      } else {
        setState(() {
          _readyPointA = false;
        });
      }

      if (body['point_b']['device_id'] != '') {
        setState(() {
          _readyPointB = true;
        });
        _changeMarkerPos(_markerIds[1], LatLng(body['point_b']['latitude'], body['point_b']['longitude']));
      } else {
        setState(() {
          _readyPointB = false;
        });
      }

      if (body['point_c']['device_id'] != '') {
        setState(() {
          _readyPointC = true;
        });
        _changeMarkerPos(_markerIds[2], LatLng(body['point_c']['latitude'], body['point_c']['longitude']));
      } else {
        setState(() {
          _readyPointC = false;
        });
      }
    }
  }

  _readWsMsgAsPoint(dynamic message) {
    // debugPrint(message);
    final body = json.decode(message);

    _availableCheck(body);
  }

  _registerPoint() {
    setState(() {
      _pointRegistered = true;
    });

    _channel.sink.close(status.goingAway);

    // debugPrint('では登録します！！ $_pointNo');

    _connectWsAsPoint();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.raceName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop()
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _width,
              height: 300,
              child: GoogleMap(
                mapType: MapType.satellite,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: _mapMarkers,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_latitude, _longitude),
                  zoom: 11.7
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                }
              )
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.0),
                  1: FlexColumnWidth(3.0)
                },
                children: [
                  TableRow(
                    children: [
                      Container(
                        height: 56,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 10),
                        child: const Text('マーク名')
                      ),
                      SizedBox(
                        height: 56,
                        // padding: const EdgeInsets.only(left: 20),
                        child: DecoratedBox(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: TextButton(
                                    child: Column(
                                      children: [
                                        Text(marks[1]![0], style: const TextStyle(color: Colors.black)),
                                        Text(marks[1]![1], style: const TextStyle(color: Colors.black, fontSize: 10))
                                      ]
                                    ),
                                    onPressed: () {
                                      setState(() {_pointNo = 1;});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: _pointNo == 1 ?const Color.fromRGBO(227, 248, 255, 1) : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      splashFactory: NoSplash.splashFactory
                                    )
                                  )
                                )
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: TextButton(
                                    child: Column(
                                      children: [
                                        Text(marks[2]![0], style: const TextStyle(color: Colors.black)),
                                        Text(marks[2]![1], style: const TextStyle(color: Colors.black, fontSize: 10))
                                      ]
                                    ),
                                    onPressed: () {
                                      setState(() {_pointNo = 2;});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: _pointNo == 2 ?const Color.fromRGBO(227, 248, 255, 1) : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      splashFactory: NoSplash.splashFactory
                                    )
                                  )
                                )
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: TextButton(
                                    child: Column(
                                      children: [
                                        Text(marks[3]![0], style: const TextStyle(color: Colors.black)),
                                        Text(marks[3]![1], style: const TextStyle(color: Colors.black, fontSize: 10))
                                      ]
                                    ),
                                    onPressed: () {
                                      setState(() {_pointNo = 3;});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: _pointNo == 3 ?const Color.fromRGBO(227, 248, 255, 1) : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      splashFactory: NoSplash.splashFactory
                                    )
                                  )
                                )
                              )
                            ]
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(222, 222, 222, 1),
                            borderRadius: BorderRadius.circular(6)
                          )
                        )
                      )
                    ]
                  ),
                  TableRow(
                    children: [
                      Container(
                        height: 56,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 10),
                        child: const Text('設定状況')
                      ),
                      SizedBox(
                        height: 56,
                        // padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _readyPointA
                                ? const Icon(Icons.done, size: 36, color: Color.fromRGBO(47, 160, 72, 1))
                                : const Icon(Icons.pending, size: 36, color: Color.fromRGBO(222, 222, 222, 1))
                            ),
                            Expanded(
                              flex: 1,
                              child: _readyPointB
                                ? const Icon(Icons.done, size: 36, color: Color.fromRGBO(47, 160, 72, 1))
                                : const Icon(Icons.pending, size: 36, color: Color.fromRGBO(222, 222, 222, 1))
                            ),
                            Expanded(
                              flex: 1,
                              child: _readyPointC
                                ? const Icon(Icons.done, size: 36, color: Color.fromRGBO(47, 160, 72, 1))
                                : const Icon(Icons.pending, size: 36, color: Color.fromRGBO(222, 222, 222, 1))
                            )
                          ]
                        )
                      )
                    ]
                  )
                ]
              )
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                child: Column(
                  children: [
                    const Text(
                      '現在地を',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    Text(
                      '${marks[_pointNo]![0]} ${marks[_pointNo]![1]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const Text(
                      'にする',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                      )
                    )
                  ]
                ),
                onPressed: _registerPoint,
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(0, 98, 104, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  minimumSize: const Size(280, 100)
                )
              )
            )
          ]
        )
      )
    );
  }
}
