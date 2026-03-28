import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'building_data.dart';

/// Architectural-style 2-D floor-plan painter.
///
/// * Rooms are solid-filled rectangles.
/// * Walls are thick dark segments with gaps cut for doors.
/// * Door openings show a quarter-circle swing arc.
/// * Aisles (empty space between rooms) show a subtle tile grid.
/// * Routes run through the aisle space with animated chevrons.
class FloorPlanPainter extends CustomPainter {
  final int floor;
  final List<NavNode>? routePath;
  final String? sourceRoomId;
  final String? destRoomId;
  final String? highlightRoomId;
  final double animValue;
  final double pixelsPerUnit;

  FloorPlanPainter({
    required this.floor,
    this.routePath,
    this.sourceRoomId,
    this.destRoomId,
    this.highlightRoomId,
    this.animValue = 0,
    this.pixelsPerUnit = 18.0,
  });

  double _s(double v) => v * pixelsPerUnit;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(12, 12);

    _drawOuterBackground(canvas);
    _drawBuildingFloor(canvas);
    _drawAisleTiles(canvas);
    _drawRoomFills(canvas);
    _drawWallsWithDoors(canvas);
    _drawRoomLabels(canvas);

    if (routePath != null && routePath!.isNotEmpty) {
      _drawRoute(canvas);
      _drawEndpoints(canvas);
    }

    canvas.restore();
  }

  // ═══════════════════════════════════════════════════════════
  //  BACKGROUNDS
  // ═══════════════════════════════════════════════════════════

  void _drawOuterBackground(Canvas canvas) {
    final w = _s(BuildingData.buildingWidth);
    final h = _s(BuildingData.buildingDepth);
    // Soft shadow behind the plan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, -4, w + 8, h + 8),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  /// Off-white floor plate — blueprint paper background.
  void _drawBuildingFloor(Canvas canvas) {
    final w = _s(BuildingData.buildingWidth);
    final h = _s(BuildingData.buildingDepth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFF8F9FA),
    );
    // Thin border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(3),
      ),
      Paint()
        ..color = const Color(0xFF90A4AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  /// Fine cross-hatch grid for aisle areas.
  void _drawAisleTiles(Canvas canvas) {
    final w = _s(BuildingData.buildingWidth);
    final h = _s(BuildingData.buildingDepth);
    final paint = Paint()
      ..color = const Color(0xFFE8EAF0)
      ..strokeWidth = 0.4;
    const tile = 1.0;
    for (double x = 0; x <= BuildingData.buildingWidth; x += tile) {
      canvas.drawLine(Offset(_s(x), 0), Offset(_s(x), h), paint);
    }
    for (double y = 0; y <= BuildingData.buildingDepth; y += tile) {
      canvas.drawLine(Offset(0, _s(y)), Offset(w, _s(y)), paint);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  ROOMS
  // ═══════════════════════════════════════════════════════════

  void _drawRoomFills(Canvas canvas) {
    final rooms = BuildingData.roomsForFloor(floor);
    for (final room in rooms) {
      final rect = Rect.fromLTWH(
        _s(room.x), _s(room.y), _s(room.w), _s(room.h),
      );

      Color fill = _roomColor(room.type);
      final isSource = room.id == sourceRoomId;
      final isDest   = room.id == destRoomId;
      final isHL     = room.id == highlightRoomId;
      final onRoute  = _isRoomOnRoute(room.id);

      if (isSource) {
        fill = const Color(0xFF66BB6A).withValues(alpha: 0.45);
      } else if (isDest) {
        fill = const Color(0xFFEF5350).withValues(alpha: 0.45);
      } else if (onRoute) {
        fill = const Color(0xFF42A5F5).withValues(alpha: 0.22);
      } else if (isHL) {
        fill = const Color(0xFF42A5F5).withValues(alpha: 0.30);
      }

      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(3));
      canvas.drawRRect(rr, Paint()..color = fill);

      if (isSource || isDest || isHL) {
        final bc = isSource
            ? const Color(0xFF4CAF50)
            : isDest
                ? const Color(0xFFF44336)
                : const Color(0xFF1E88E5);
        canvas.drawRRect(
          rr,
          Paint()
            ..color = bc
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    }
  }

  Color _roomColor(RoomType type) {
    switch (type) {
      case RoomType.lab:         return const Color(0xFFDCEEFB);
      case RoomType.lectureHall: return const Color(0xFFE0D8F0);
      case RoomType.office:      return const Color(0xFFFFF8E1);
      case RoomType.stairs:      return const Color(0xFFD7ECD9);
      case RoomType.elevator:    return const Color(0xFFD5EDEA);
      case RoomType.restroom:    return const Color(0xFFD6EFF5);
      case RoomType.meetingRoom: return const Color(0xFFE8F5E9);
      case RoomType.entrance:    return const Color(0xFFFCE4EC);
      case RoomType.corridor:    return const Color(0xFFECEFF1);
      case RoomType.room:        return const Color(0xFFECEFF1);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  WALLS + DOOR OPENINGS
  //
  //  For each room, for each of the 4 sides we draw wall
  //  segments with gaps cut where doors are, then draw a
  //  quarter-circle door-swing arc in each gap.
  // ═══════════════════════════════════════════════════════════

  void _drawWallsWithDoors(Canvas canvas) {
    final rooms = BuildingData.roomsForFloor(floor);
    final wallPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    final doorLinePaint = Paint()
      ..color = const Color(0xFF546E7A)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final doorArcPaint = Paint()
      ..color = const Color(0xFF546E7A).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final room in rooms) {
      final roomDoors = BuildingData.doorsForRoom(room.id);

      for (final side in WallSide.values) {
        // Wall-line endpoints (building units)
        double x1, y1, x2, y2;
        switch (side) {
          case WallSide.north:
            x1 = room.x; y1 = room.y;
            x2 = room.x + room.w; y2 = room.y;
          case WallSide.south:
            x1 = room.x; y1 = room.y + room.h;
            x2 = room.x + room.w; y2 = room.y + room.h;
          case WallSide.west:
            x1 = room.x; y1 = room.y;
            x2 = room.x; y2 = room.y + room.h;
          case WallSide.east:
            x1 = room.x + room.w; y1 = room.y;
            x2 = room.x + room.w; y2 = room.y + room.h;
        }

        final onSide = roomDoors.where((d) => d.side == side).toList()
          ..sort((a, b) => a.position.compareTo(b.position));

        if (onSide.isEmpty) {
          // Full wall
          canvas.drawLine(
            Offset(_s(x1), _s(y1)),
            Offset(_s(x2), _s(y2)),
            wallPaint,
          );
        } else {
          // Wall with gaps
          double from = 0;
          for (final door in onSide) {
            final gs = (door.position - door.width / 2).clamp(0.0, 1.0);
            final ge = (door.position + door.width / 2).clamp(0.0, 1.0);

            // Wall segment before gap
            if (gs > from) {
              _seg(canvas, x1, y1, x2, y2, from, gs, wallPaint);
            }

            // Door indicator
            _drawDoor(canvas, x1, y1, x2, y2, gs, ge, side, doorLinePaint, doorArcPaint);
            from = ge;
          }
          // Wall after last gap
          if (from < 1.0) {
            _seg(canvas, x1, y1, x2, y2, from, 1.0, wallPaint);
          }
        }
      }
    }
  }

  /// Draw a wall sub-segment between fractional positions [t1] and [t2].
  void _seg(Canvas c, double x1, double y1, double x2, double y2,
      double t1, double t2, Paint p) {
    c.drawLine(
      Offset(_s(x1 + (x2 - x1) * t1), _s(y1 + (y2 - y1) * t1)),
      Offset(_s(x1 + (x2 - x1) * t2), _s(y1 + (y2 - y1) * t2)),
      p,
    );
  }

  /// Draw a simple door opening indicator (a colored line across the gap).
  void _drawDoor(
    Canvas canvas,
    double wx1, double wy1, double wx2, double wy2,
    double gs, double ge,
    WallSide side,
    Paint leafPaint,
    Paint arcPaint,
  ) {
    // Gap endpoints in pixels
    final gsx = _s(wx1 + (wx2 - wx1) * gs);
    final gsy = _s(wy1 + (wy2 - wy1) * gs);
    final gex = _s(wx1 + (wx2 - wx1) * ge);
    final gey = _s(wy1 + (wy2 - wy1) * ge);

    // Simple line across the gap to indicate a door opening
    final doorPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(gsx, gsy),
      Offset(gex, gey),
      doorPaint,
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  ROOM LABELS
  // ═══════════════════════════════════════════════════════════

  void _drawRoomLabels(Canvas canvas) {
    final rooms = BuildingData.roomsForFloor(floor);
    for (final room in rooms) {
      final cx = _s(room.x + room.w / 2);
      final cy = _s(room.y + room.h / 2);
      final area = room.w * room.h;
      final rw = _s(room.w);

      // Room number badge (top-left corner) for rooms with E- codes
      if (room.id.startsWith('E') || room.id.startsWith('G0')) {
        final code = room.id;
        final bp = TextPainter(
          text: TextSpan(
            text: code,
            style: const TextStyle(
              color: Color(0xFF546E7A),
              fontSize: 6.5,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        bp.paint(canvas, Offset(_s(room.x) + 3, _s(room.y) + 2));
      }

      // Functional name label
      final fs = area > 80
          ? 12.0
          : area > 40
              ? 10.5
              : area > 15
                  ? 9.0
                  : area > 6
                      ? 7.5
                      : 6.0;
      final tp = TextPainter(
        text: TextSpan(
          text: room.shortName,
          style: TextStyle(
            color: const Color(0xFF263238),
            fontSize: fs,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 3,
      )..layout(maxWidth: rw - 4);

      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
    }
  }

  // No more emoji icons — clean architectural style

  // ═══════════════════════════════════════════════════════════
  //  ROUTE
  // ═══════════════════════════════════════════════════════════

  void _drawRoute(Canvas canvas) {
    final nodesOnFloor = routePath!.where((n) => n.floor == floor).toList();
    if (nodesOnFloor.length < 2) return;

    final pts = nodesOnFloor.map((n) => Offset(_s(n.x), _s(n.y))).toList();

    // Glow
    canvas.drawPath(
      _pathFromPoints(pts),
      Paint()
        ..color = const Color(0xFF1E88E5).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Main line
    canvas.drawPath(
      _pathFromPoints(pts),
      Paint()
        ..color = const Color(0xFF1E88E5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dashed white centre
    _drawDashedPath(canvas, pts, 8, 6);

    // Animated chevrons
    _drawChevrons(canvas, pts);
  }

  Path _pathFromPoints(List<Offset> pts) {
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      p.lineTo(pts[i].dx, pts[i].dy);
    }
    return p;
  }

  void _drawDashedPath(Canvas c, List<Offset> pts, double dash, double gap) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < pts.length - 1; i++) {
      final s = pts[i];
      final e = pts[i + 1];
      final d = (e - s).distance;
      if (d == 0) continue;
      final dir = (e - s) / d;
      double drawn = 0;
      while (drawn < d) {
        final a = s + dir * drawn;
        final b = s + dir * min(drawn + dash, d);
        c.drawLine(a, b, paint);
        drawn += dash + gap;
      }
    }
  }

  void _drawChevrons(Canvas canvas, List<Offset> pts) {
    double totalLen = 0;
    final segs = <double>[];
    for (int i = 1; i < pts.length; i++) {
      final l = (pts[i] - pts[i - 1]).distance;
      segs.add(l);
      totalLen += l;
    }
    if (totalLen == 0) return;

    const count = 4;
    for (int d = 0; d < count; d++) {
      final t = (animValue + d / count) % 1.0;
      double target = t * totalLen;
      double acc = 0;
      for (int i = 0; i < segs.length; i++) {
        if (acc + segs[i] >= target) {
          final frac = (target - acc) / segs[i];
          final pt = pts[i] + (pts[i + 1] - pts[i]) * frac;
          final dir = pts[i + 1] - pts[i];
          _drawChevron(canvas, pt, atan2(dir.dy, dir.dx), 7);
          break;
        }
        acc += segs[i];
      }
    }
  }

  void _drawChevron(Canvas c, Offset center, double angle, double s) {
    final ca = cos(angle), sa = sin(angle);
    Offset r(double x, double y) =>
        center + Offset(x * ca - y * sa, x * sa + y * ca);
    final p = Path()
      ..moveTo(r(s, 0).dx, r(s, 0).dy)
      ..lineTo(r(-s * 0.4, -s * 0.6).dx, r(-s * 0.4, -s * 0.6).dy)
      ..lineTo(r(0, 0).dx, r(0, 0).dy)
      ..lineTo(r(-s * 0.4, s * 0.6).dx, r(-s * 0.4, s * 0.6).dy)
      ..close();
    c.drawPath(p, Paint()..color = Colors.white);
    c.drawPath(
        p,
        Paint()
          ..color = const Color(0xFF1E88E5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  // ═══════════════════════════════════════════════════════════
  //  ENDPOINTS  (A / B pins + floor-transition badges)
  // ═══════════════════════════════════════════════════════════

  void _drawEndpoints(Canvas canvas) {
    final onFloor = routePath!.where((n) => n.floor == floor).toList();
    if (onFloor.isEmpty) return;

    NavNode? startNode, endNode;
    for (final n in routePath!) {
      if (n.floor == floor) {
        startNode ??= n;
        endNode = n;
      }
    }

    if (startNode != null && startNode == routePath!.first) {
      _pin(canvas, Offset(_s(startNode.x), _s(startNode.y)),
          const Color(0xFF4CAF50), 'A');
    }
    if (endNode != null && endNode == routePath!.last) {
      _pin(canvas, Offset(_s(endNode.x), _s(endNode.y)),
          const Color(0xFFF44336), 'B');
    }

    _drawFloorTransitions(canvas);
  }

  void _pin(Canvas c, Offset pos, Color color, String label) {
    c.drawCircle(
        pos + const Offset(1, 2),
        11,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    c.drawCircle(pos, 11, Paint()..color = color);
    c.drawCircle(pos, 8, Paint()..color = Colors.white);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawFloorTransitions(Canvas canvas) {
    if (routePath == null) return;
    for (int i = 1; i < routePath!.length; i++) {
      final prev = routePath![i - 1];
      final curr = routePath![i];
      if (prev.floor == curr.floor) continue;
      final node =
          prev.floor == floor ? prev : (curr.floor == floor ? curr : null);
      if (node == null) continue;

      final pos = Offset(_s(node.x), _s(node.y));
      final isUp = curr.floor > prev.floor;
      final arrow = isUp ? '↑' : '↓';
      final target = isUp ? curr.floor : prev.floor;

      final br = Rect.fromCenter(
          center: pos - const Offset(0, 20), width: 50, height: 18);
      canvas.drawRRect(
          RRect.fromRectAndRadius(br, const Radius.circular(9)),
          Paint()..color = const Color(0xFF1565C0));
      final tp = TextPainter(
        text: TextSpan(
          text: '$arrow ${floorLabel(target)}',
          style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, br.center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  bool _isRoomOnRoute(String roomId) =>
      routePath?.any((n) => n.roomId == roomId) ?? false;

  @override
  bool shouldRepaint(covariant FloorPlanPainter old) =>
      old.floor != floor ||
      old.routePath != routePath ||
      old.sourceRoomId != sourceRoomId ||
      old.destRoomId != destRoomId ||
      old.highlightRoomId != highlightRoomId ||
      old.animValue != animValue;
}
