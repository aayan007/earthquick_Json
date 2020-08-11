import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class LocationModel {
  final String place;
  final double magnitude;

  LocationModel({this.place, this.magnitude});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(place: json["place"], magnitude: json["magnitude"]);
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LocationModel> placeObjects;

  Future getData() async {
    http.Response response = await http.get(
        'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2020-08-08&minmagnitude=2');
    if (response.statusCode == 200) {
      String data = response.body;

      var features = jsonDecode(data)['features'];
      placeObjects = [];
      print(features.length);
      features.forEach((value) {
        LocationModel model = LocationModel(
            place: value["properties"]["place"],
            magnitude: value["properties"]["mag"]);
        placeObjects.add(model);
      });

      // Iterator iterator = features.iterator;
      // print(features);
      // while (iterator.moveNext()) {
      //   LocationModel model = LocationModel(
      //       place: iterator.current["properties"]["place"], magnitude: iterator.current["properties"]["mag"]);
      //   placeObjects.add(model);
      // }
    } else {
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Earthquick'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CupertinoActivityIndicator());
          else if (snapshot.connectionState == ConnectionState.done)
            return ListView.builder(
              itemCount: placeObjects.length,
              itemBuilder: (context, index) {
                return ListTile(
//                        visualDensity: VisualDensity.compact,
                  title: new Text(placeObjects[index].place),
                  subtitle: new Text(placeObjects[index].magnitude.toString()),
                );
              },
            );
        },
      ),
    );
  }
}
