import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../widgets/drawer.dart';
import 'package:latlong/latlong.dart';

class PolygonPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const String route = "polygon";

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
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Polygons")),
      drawer: buildDrawer(context, PolygonPage.route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text("Polygons"),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(51.5, -0.09),
                  zoom: 5.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  PolygonLayerOptions(
                    polygons: [
                      Polygon(
                        points: pointsA,
                        borderStrokeWidth: 4.0,
                        borderColor: Colors.purple,
                        closeFigure: true,
                        color: Color(
                            0x509C27B0), // Colors.purple with less opacity
                      ),
                      Polygon(
                        points: pointsB,
                        borderStrokeWidth: 4.0,
                        borderColor: Colors.red,
                        closeFigure: true,
                        color:
                            Color(0x50F44336), // Colors.red with less opacity
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

  void _handleTap(Polygon polygon, LatLng location) {
    var message = "Tapped on polygon #${polygon.hashCode}. LatLng = $location";
    print(message);
    _showSnackBarMsg(message);
  }

  void _handleLongPress(Polygon polygon, LatLng location) {
    var message =
        "Long Press on polygon #${polygon.hashCode}. LatLng = $location";
    print(message);
    _showSnackBarMsg(message);
  }

  void _showSnackBarMsg(String text) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
