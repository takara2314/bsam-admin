import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie_admin/providers/count.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageCourse extends HookConsumerWidget {
  const ManageCourse({Key? key, required String this.raceId}) : super(key: key);
  final String raceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _width = MediaQuery.of(context).size.width;

    final races = useState<List<dynamic>>([]);

    useEffect(() {
      http.get(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/races')
      )
        .then((res) {
          if (res.statusCode != 200) {
            throw Exception('Something occurred.');
          }
          final body = json.decode(res.body);
          races.value = body['races'];
        });
    }, const []);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(100, 100, 100, 1)
          ),
          onPressed: () => context.go('/manage/races')
        ),
        centerTitle: false,
        title: const Text(
          '伊勢湾レースA',
          style: TextStyle(
            color: Colors.black
          )
        ),
        elevation: 0,
        backgroundColor: Colors.transparent
      ),
      body: Stack(
        children: [
          const GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.773972, -122.431297),
              zoom: 11.7
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: _width,
              height: 128,
              child: Container(
                color: const Color.fromRGBO(0, 0, 0, 0.25),
                child: Column(
                  children: [
                    const Text(
                      'レース開始までお待ちください',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      )
                    ),
                    ElevatedButton(
                      child: const Text('スタート（仮）'),
                      onPressed: () => context.go('/race/navi/${raceId}')
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )
              )
            )
          )
        ]
      ),
      backgroundColor: const Color.fromRGBO(229, 229, 229, 1)
    );
  }
}
