import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/map.dart';
import 'package:latlong/latlong.dart' hide Path; // conflict with Path from UI

typedef PolylineCallback(Polyline polyline, LatLng location);

class PolylineLayerOptions extends LayerOptions {
  final List<Polyline> polylines;
  final PolylineCallback onTap;
  final PolylineCallback onLongPress;

  PolylineLayerOptions(
      {this.polylines = const [], this.onTap, this.onLongPress});
}

class Polyline {
  final Key key;
  final List<LatLng> points;
  final List<Offset> offsets = [];
  final double strokeWidth;
  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final bool isDotted;
  final bool displayPoints;
  final double pointsWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;

  Polyline({
    this.key,
    this.points,
    this.strokeWidth = 1.0,
    this.color = const Color(0xFF00FF00),
    this.borderStrokeWidth = 0.0,
    this.borderColor = const Color(0xFFFFFF00),
    this.isDotted = false,
    this.displayPoints = false,
    this.pointsWidth = 0.0,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
  });
}

class PolylineLayer extends StatelessWidget {
  final PolylineLayerOptions polylineOpts;
  final MapState map;

  PolylineLayer(this.polylineOpts, this.map);

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
      builder: (BuildContext context, _) {
        for (var polylineOpt in polylineOpts.polylines) {
          polylineOpt.offsets.clear();
          var i = 0;
          for (var point in polylineOpt.points) {
            var pos = map.project(point);
            pos = pos.multiplyBy(map.getZoomScale(map.zoom, map.zoom)) -
                map.getPixelOrigin();
            polylineOpt.offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
            if (i > 0 && i < polylineOpt.points.length) {
              polylineOpt.offsets
                  .add(Offset(pos.x.toDouble(), pos.y.toDouble()));
            }
            i++;
          }
        }

        return Container(
          child: Stack(
            children: _buildPolylines(context, size),
          ),
        );
      },
    );
  }

  List<Widget> _buildPolylines(BuildContext context, Size size) {
    var list = polylineOpts.polylines
        .where((polyline) => polyline.points.isNotEmpty)
        .map((polyline) => _buildPolylineWidget(context, polyline, size))
        .toList();
    return list;
  }

  Widget _buildPolylineWidget(
      BuildContext context, Polyline polyline, Size size) {
    return CustomPaint(
      key: polyline.key,
      painter: PolylinePainter(polyline),
      size: size,
    );
  }
}

class PolylinePainter extends CustomPainter {
  final Polyline polylineOpt;
  PolylinePainter(this.polylineOpt);

  @override
  void paint(Canvas canvas, Size size) {
    if (polylineOpt.offsets.isEmpty) {
      return;
    }
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final paint = Paint()
      ..color = polylineOpt.color
      ..strokeWidth = polylineOpt.strokeWidth
      ..strokeCap = polylineOpt.strokeCap
      ..strokeJoin = polylineOpt.strokeJoin;
    final borderPaint = polylineOpt.borderStrokeWidth > 0.0
        ? (Paint()
          ..color = polylineOpt.borderColor
          ..strokeCap = polylineOpt.strokeCap
          ..strokeJoin = polylineOpt.strokeJoin
          ..strokeWidth =
              polylineOpt.strokeWidth + polylineOpt.borderStrokeWidth)
        : null;
    double radius = polylineOpt.displayPoints &&
            polylineOpt.pointsWidth > 0.0 &&
            !polylineOpt.isDotted
        ? polylineOpt.pointsWidth
        : polylineOpt.strokeWidth / 2;
    double borderRadius = radius + (polylineOpt.borderStrokeWidth / 2);
    if (polylineOpt.isDotted) {
      double spacing = polylineOpt.strokeWidth * 1.5;
      if (borderPaint != null) {
        _paintDottedLine(
            canvas, polylineOpt.offsets, borderRadius, spacing, borderPaint);
      }
      _paintDottedLine(canvas, polylineOpt.offsets, radius, spacing, paint);
    } else {
      if (borderPaint != null) {
        _paintLine(canvas, polylineOpt.offsets, borderRadius, borderPaint);
      }
      _paintLine(canvas, polylineOpt.offsets, radius, paint);
    }
  }

  void _paintDottedLine(Canvas canvas, List<Offset> offsets, double radius,
      double stepLength, Paint paint) {
    double startDistance = 0.0;
    for (int i = 0; i < offsets.length - 1; i++) {
      Offset o0 = offsets[i];
      Offset o1 = offsets[i + 1];
      double totalDistance = _dist(o0.dx, o0.dy, o1.dx, o1.dy);
      double distance = startDistance;
      while (distance < totalDistance) {
        double f1 = distance / totalDistance;
        double f0 = 1.0 - f1;
        var offset = Offset(o0.dx * f0 + o1.dx * f1, o0.dy * f0 + o1.dy * f1);
        canvas.drawCircle(offset, radius, paint);
        distance += stepLength;
      }
      startDistance = distance < totalDistance
          ? stepLength - (totalDistance - distance)
          : distance - totalDistance;
    }
    canvas.drawCircle(polylineOpt.offsets.last, radius, paint);
  }

  void _paintLine(
      Canvas canvas, List<Offset> offsets, double radius, Paint paint) {
    canvas.drawPoints(PointMode.lines, offsets, paint);
    for (var offset in offsets) {
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(PolylinePainter other) => false;
}

double _dist(double x1, double y1, double x2, double y2) {
  return sqrt(_dist2(x1, y1, x2, y2));
}

double _dist2(double x1, double y1, double x2, double y2) {
  return _sqr(x1 - x2) + _sqr(y1 - y2);
}

double _sqr(double x) {
  return x * x;
}
