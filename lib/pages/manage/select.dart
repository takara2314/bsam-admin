import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sailing_assist_mie_admin/pages/manage/manage.dart';

class Select extends StatefulWidget {
  const Select({Key? key}) : super(key: key);

  @override
  State<Select> createState() => _Select();
}

class _Select extends State<Select> {
  List<dynamic> races = [];

  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _getRaces();
  }

  _getRaces() {
    setState(() {
      _ready = false;
    });

    try {
      http.get(
        Uri.parse('https://sailing-assist-mie-api.herokuapp.com/races')
      )
        .then((res) {
          if (res.statusCode != 200) {
            throw Exception('Something occurred.');
          }
          final body = json.decode(res.body);

          body['races'].sort((a, b){
            return DateTime.parse(a['start_at']).compareTo(DateTime.parse(b['start_at']));
          });

          if (!mounted) {
            return;
          }
          setState(() {
            races = body['races'];
            _ready = true;
          });
        });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コース選択'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop()
        )
      ),
      body: SingleChildScrollView(
        child:
          (_ready)
          ? Container(
              child: Column(
                children: [
                  for (var race in races) Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: _RaceCard(
                      id: race['id'],
                      name: race['name'],
                      startAt: DateTime.parse(race['start_at']).toLocal(),
                      endAt: DateTime.parse(race['end_at']).toLocal(),
                      memo: race['memo'],
                      getRaces: _getRaces
                    )
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(25)
            )
          : Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Column(
                children: const [
                  SpinKitWave(
                    color: Color.fromRGBO(255, 84, 79, 1),
                    size: 80.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('レース情報を読み込んでいます…')
                  )
                ]
              )
            )
      )
    );
  }
}

class _RaceCard extends StatelessWidget {
  _RaceCard({
    Key? key,
    required this.id,
    required this.name,
    required this.startAt,
    required this.endAt,
    required this.getRaces,
    this.memo
  }) : super(key: key);

  final DateFormat timeFormat = DateFormat('H時m分');

  final String id;
  final String name;
  final DateTime startAt;
  final DateTime endAt;
  final String? memo;

  Function getRaces;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return DecoratedBox(
      child: Column(
        children: [
          SizedBox(
            width: _width,
            height: 100,
            child: const ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16)
              ),
              child: Image(
                image: AssetImage('images/sailing.jpg'),
                fit: BoxFit.cover
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Text(
                          timeFormat.format(startAt)
                          + ' 〜 '
                          + timeFormat.format(endAt),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(107, 107, 107, 1)
                          )
                        )
                      ]
                    )
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 42,
                    margin: const EdgeInsets.only(top: 3, left: 2, right: 3),
                    child: ElevatedButton(
                      child: const Text(
                        '選択する',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        )
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Manage(raceId: id, raceName: name),
                          )
                        );
                        getRaces();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromRGBO(4, 111, 171, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                      )
                    )
                  )
                )
              ]
            )
          ),
          Container(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
            alignment: Alignment.topLeft,
            child: Text(
              memo ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(107, 107, 107, 1)
              )
            )
          )
        ]
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(238, 238, 238, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 7.5,
            offset: Offset(0, 4)
          )
        ]
      )
    );
  }
}
