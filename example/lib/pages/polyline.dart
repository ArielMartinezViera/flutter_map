import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../widgets/drawer.dart';
import 'package:latlong/latlong.dart';

class PolylinePage extends StatefulWidget {
  static const String route = "polyline";
  @override
  State createState() => PolylinePageState();
}

class PolylinePageState extends State<PolylinePage> {
  String _eventMessage = "Tap on the map and its elements!";

  Widget build(BuildContext context) {
    var pointsA = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
      LatLng(48.8566, 2.3522),
    ];
    var pointsB = <LatLng>[
      LatLng(53.482761, -2.241135),
      LatLng(52.065709, 4.300589),
      LatLng(53.215497, 6.564996),
    ];
    return Scaffold(
      appBar: AppBar(title: Text("Polylines")),
      drawer: buildDrawer(context, PolylinePage.route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text("Polylines"),
            ),
            Text(
              "$_eventMessage",
              textAlign: TextAlign.center,
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(51.5, -0.09),
                  zoom: 5.0,
                  onTap: _handleMapTapped,
                  onLongPress: _handleMapLongPressed,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                        key: Key("route_a"),
                        points: pointsA,
                        strokeWidth: 10.0,
                        color: Colors.purple,
                        isDotted: true,
                        displayPoints: true,
                        pointsWidth: 8.0
                      ),
                      Polyline(
                        key: Key("route_b"),
                        points: pointsB,
                        strokeWidth: 10.0,
                        color: Colors.red,
                      ),
                    ],
                    onTap: _handleTap,
                    onLongPress: _handleLongPress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMapTapped(LatLng location) {
    var message = "Map tapped at ${location.latitude}, ${location.longitude}";
    print(message);
    setState(() {
      this._eventMessage = message;
    });
  }

  void _handleMapLongPressed(LatLng location) {
    var message =
        "Map long pressed at ${location.latitude}, ${location.longitude}";
    print(message);
    setState(() {
      this._eventMessage = message;
    });
  }

  void _handleTap(Polyline polyline, LatLng location) {
    var message = "Tapped on polyline #${polyline.key}. LatLng = $location";
    print(message);
    setState(() {
      this._eventMessage = message;
    });
  }

  void _handleLongPress(Polyline polyline, LatLng location) {
    var message = "Long Press on polyline #${polyline.key}. LatLng = $location";
    print(message);
    setState(() {
      this._eventMessage = message;
    });
  }
}
