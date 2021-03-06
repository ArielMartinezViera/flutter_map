import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/map.dart';
import 'package:latlong/latlong.dart' hide Path; // conflict with Path from UI

typedef PolygonCallback(Polygon polygon, LatLng location);

class PolygonLayerOptions extends LayerOptions {
  final List<Polygon> polygons;
  final PolygonCallback onTap;
  final PolygonCallback onLongPress;

  PolygonLayerOptions({
    this.polygons = const [],
    this.onTap,
    this.onLongPress,
  });
}

class Polygon {
  final Key key;
  final List<LatLng> points;
  final List<Offset> offsets = [];
  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final bool closeFigure;
  final bool displayPoints;
  final double pointsWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;

  Polygon({
    this.key,
    this.points,
    this.color = const Color(0xFF00FF00),
    this.borderStrokeWidth = 0.0,
    this.borderColor = const Color(0xFFFFFF00),
    this.closeFigure = false,
    this.displayPoints = false,
    this.pointsWidth = 0.0,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
  });
}

class PolygonLayer extends StatelessWidget {
  final PolygonLayerOptions polygonOpts;
  final MapState map;

  PolygonLayer(this.polygonOpts, this.map);

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        final size = Size(bc.maxWidth, bc.maxHeight);
        return _build(context, size);
      },
    );
  }

  Widget _build(BuildContext context, Size size) {
    return StreamBuilder<int>(
      stream: map.onMoved, // a Stream<int> or null
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        for (var polygonOpt in polygonOpts.polygons) {
          polygonOpt.offsets.clear();
          var i = 0;
          for (var point in polygonOpt.points) {
            var pos = map.project(point);
            pos = pos.multiplyBy(map.getZoomScale(map.zoom, map.zoom)) -
                map.getPixelOrigin();
            polygonOpt.offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
            if (i > 0 && i < polygonOpt.points.length) {
              polygonOpt.offsets
                  .add(Offset(pos.x.toDouble(), pos.y.toDouble()));
            }
            i++;
          }
        }
        return Container(
          child: Stack(
            children: _buildPolygons(context, size),
          ),
        );
      },
    );
  }

  List<Widget> _buildPolygons(BuildContext context, Size size) {
    var list = polygonOpts.polygons
        .where((it) => it.points.isNotEmpty)
        .map((it) => _buildPolygonWidget(context, it, size))
        .toList();
    return list;
  }

  Widget _buildPolygonWidget(BuildContext context, Polygon polygon, Size size) {
    return CustomPaint(
      key: polygon.key,
      painter: PolygonPainter(polygon),
      size: size,
    );
  }
}

class PolygonPainter extends CustomPainter {
  final Polygon polygonOpt;

  PolygonPainter(this.polygonOpt);

  @override
  void paint(Canvas canvas, Size size) {
    if (polygonOpt.offsets.isEmpty) {
      return;
    }
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = polygonOpt.color
      ..strokeCap = polygonOpt.strokeCap
      ..strokeJoin = polygonOpt.strokeJoin;
    final borderPaint = polygonOpt.borderStrokeWidth > 0.0
        ? (Paint()
          ..style = PaintingStyle.stroke
          ..color = polygonOpt.borderColor
          ..strokeWidth = polygonOpt.borderStrokeWidth
          ..strokeCap = polygonOpt.strokeCap
          ..strokeJoin = polygonOpt.strokeJoin)
        : null;
    _paintPolygon(canvas, polygonOpt.offsets, paint);
    if (polygonOpt.borderStrokeWidth > 0.0) {
      _paintLine(canvas, polygonOpt.offsets, borderPaint);
    }
  }

  void _paintLine(Canvas canvas, List<Offset> offsets, Paint paint) {
    if (polygonOpt.closeFigure) offsets.add(offsets.first);
    canvas.drawPoints(PointMode.lines, offsets, paint);
    if (polygonOpt.displayPoints && polygonOpt.pointsWidth > 0.0) {
      for (var offset in offsets) {
        canvas.drawCircle(offset, polygonOpt.pointsWidth, paint);
      }
    }
  }

  void _paintPolygon(Canvas canvas, List<Offset> offsets, Paint paint) {
    Path path = Path();
    path.addPolygon(offsets, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PolygonPainter other) => false;
}
