import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapArea extends StatelessWidget {
  const MapArea({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.manual,
    required this.autoMoveMap,
    required this.mapMarkers,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraMoveStarted,
    required this.changeToManual,
    required this.changeToAuto
  }) : super(key: key);

  final double latitude;
  final double longitude;
  final double accuracy;
  final bool manual;
  final bool autoMoveMap;
  final Set<Marker> mapMarkers;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function() onCameraMoveStarted;
  final Function() changeToManual;
  final Function() changeToAuto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MapView(
          latitude: latitude,
          longitude: longitude,
          autoMoveMap: autoMoveMap,
          mapMarkers: mapMarkers,
          onMapCreated: onMapCreated,
          onCameraMove: onCameraMove,
          onCameraMoveStarted: onCameraMoveStarted,
          changeToManual: changeToManual
        ),
        Visibility(
          visible: manual,
          child: ElevatedButton(
            onPressed: changeToAuto,
            child: const Text('現在位置をマークにする')
          )
        ),
        Visibility(
          visible: autoMoveMap,
          child: const Text('自動移動有効')
        )
      ]
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.autoMoveMap,
    required this.mapMarkers,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraMoveStarted,
    required this.changeToManual
  }) : super(key: key);

  final double latitude;
  final double longitude;
  final bool autoMoveMap;
  final Set<Marker> mapMarkers;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function() onCameraMoveStarted;
  final Function() changeToManual;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
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
            markers: mapMarkers,
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 18
            ),
            onMapCreated: onMapCreated,
            onCameraMove: onCameraMove,
            onCameraMoveStarted: onCameraMoveStarted
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
              visible: !autoMoveMap,
              child: ElevatedButton(
                onPressed: changeToManual,
                child: const Text('ここをマークにする')
              )
            )
          )
        ]
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
