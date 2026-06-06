import 'dart:math';

import 'package:flutter/material.dart';

import 'building_data.dart';
import 'models.dart';

class FloorPlanPainter extends CustomPainter {
  final int floor;
  final List<NavNode>? routePath;
  final String? sourceRoomId;
  final String? destRoomId;
  final String? highlightRoomId;
  final double animValue;
  final double pixelsPerUnit;
  final String? buildingTitle;

  static const _titleAreaH = 50.0;

  FloorPlanPainter({
    required this.floor,
    this.routePath,
    this.sourceRoomId,
    this.destRoomId,
    this.highlightRoomId,
    this.animValue = 0,
    this.pixelsPerUnit = 18,
    this.buildingTitle,
  });

  double get _topY => buildingTitle != null ? 12 + _titleAreaH : 12;

  double _s(double v) => v * pixelsPerUnit;

  static const _wallColor  = Color(0xFF28303C);
  static const _routeColor = Color(0xFF1558D6);
  static const _srcColor   = Color(0xFF2E7D32);
  static const _dstColor   = Color(0xFFC62828);

  @override
  void paint(Canvas canvas, Size size) {
    _drawExterior(canvas, size);
    _drawBuildingTitle(canvas, size);
    canvas.save();
    canvas.translate(12, _topY);
    _drawBuildingBase(canvas);
    _drawFloorWatermark(canvas);
    _drawRoomFills(canvas);
    _drawStairHatches(canvas);
    _drawFurniture(canvas);
    _drawWalls(canvas);
    _drawRoomLabels(canvas);
    if (routePath != null && routePath!.isNotEmpty) {
      _drawRoute(canvas);
      _drawEndpoints(canvas);
    }
    canvas.restore();
    _drawCompass(canvas, size);
    _drawScaleBar(canvas, size);
  }

  void _drawExterior(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFD8DBE0));
    const bx = 12.0;
    final by = _topY;
    final bw = _s(BuildingData.buildingWidth);
    final bh = _s(BuildingData.buildingDepth);
    canvas.drawRect(Rect.fromLTWH(bx + 3, by + 5, bw, bh), Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    final pathPaint = Paint()..color = const Color(0xFFC4C8CF);
    canvas.drawRect(Rect.fromLTWH(bx + _s(10), 0, _s(10), by), pathPaint);
    canvas.drawRect(Rect.fromLTWH(bx + _s(10), by + bh, _s(10), size.height - (by + bh)), pathPaint);
    canvas.drawRect(Rect.fromLTWH(bx + bw, by + _s(8), size.width - (bx + bw), _s(10)), pathPaint);
  }

  void _drawBuildingTitle(Canvas canvas, Size size) {
    if (buildingTitle == null) return;
    // Dark header band above the building
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, _topY),
      Paint()..color = const Color(0xFF18283A),
    );
    // Subtle bottom border line
    canvas.drawLine(
      Offset(0, _topY),
      Offset(size.width, _topY),
      Paint()..color = const Color(0xFF2E4A68)..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: buildingTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 32);
    tp.paint(canvas, Offset(
      (size.width - tp.width) / 2,
      (_topY - tp.height) / 2,
    ));
  }

  void _drawBuildingBase(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, _s(BuildingData.buildingWidth), _s(BuildingData.buildingDepth)), Paint()..color = Colors.white);
  }

  void _drawFloorWatermark(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(text: floorLabel(floor), style: const TextStyle(color: Color(0x07000000), fontSize: 180, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: _s(BuildingData.buildingWidth));
    tp.paint(canvas, Offset((_s(BuildingData.buildingWidth) - tp.width) / 2, (_s(BuildingData.buildingDepth) - tp.height) / 2));
  }

  void _drawRoomFills(Canvas canvas) {
    for (final room in BuildingData.roomsForFloor(floor)) {
      final rect = Rect.fromLTWH(_s(room.x), _s(room.y), _s(room.w), _s(room.h));
      final isSource = room.id == sourceRoomId;
      final isDest   = room.id == destRoomId;
      final isHigh   = room.id == highlightRoomId;
      final onRoute  = _onRoute(room.id);
      final fill = isSource ? const Color(0xFFC3E8CB)
                 : isDest   ? const Color(0xFFFFCDC8)
                 : onRoute  ? const Color(0xFFD2E4FF)
                 : isHigh   ? const Color(0xFFDBEAFF)
                 : _roomColor(room.type);
      canvas.drawRect(rect, Paint()..color = fill);
      if (room.w * room.h > 18 && !isSource && !isDest) {
        final hl = min(_s(room.h) * 0.35, 7.0);
        canvas.drawRect(Rect.fromLTWH(rect.left + 1, rect.top + 1, rect.width - 2, hl), Paint()..color = Colors.white.withValues(alpha: 0.35));
      }
      if (isSource || isDest || isHigh || onRoute) {
        final borderColor = isSource ? _srcColor : isDest ? _dstColor : _routeColor;
        canvas.drawRect(rect, Paint()
          ..color = borderColor.withValues(alpha: isSource || isDest ? 1.0 : 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSource || isDest ? 2.4 : 1.4);
      }
    }
  }

  Color _roomColor(RoomType t) {
    switch (t) {
      case RoomType.lectureHall:  return const Color(0xFFFBFBF8);
      case RoomType.lab:          return const Color(0xFFECF3FF);
      case RoomType.office:       return const Color(0xFFFFFBEE);
      case RoomType.meetingRoom:  return const Color(0xFFEEFBF2);
      case RoomType.stairs:       return const Color(0xFFEDEDEB);
      case RoomType.elevator:     return const Color(0xFFE6F3FD);
      case RoomType.restroom:     return const Color(0xFFE4F6F9);
      case RoomType.entrance:     return const Color(0xFFFFF6E6);
      case RoomType.corridor:
      case RoomType.room:         return const Color(0xFFF2EDE7);
    }
  }

  void _drawStairHatches(Canvas canvas) {
    final p = Paint()..color = const Color(0xFFB8B8B8) ..strokeWidth = 0.6 ..style = PaintingStyle.stroke;
    for (final room in BuildingData.roomsForFloor(floor).where((r) => r.type == RoomType.stairs)) {
      final rx = _s(room.x); final ry = _s(room.y);
      final rw = _s(room.w); final rh = _s(room.h);
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(rx + 1, ry + 1, rw - 2, rh - 2));
      var y = ry;
      while (y <= ry + rh) { canvas.drawLine(Offset(rx, y), Offset(rx + rw, y), p); y += 5.5; }
      canvas.restore();
    }
  }

  static final _fPaint = Paint()..color = const Color(0xFFCACACA) ..style = PaintingStyle.fill;

  void _drawFurniture(Canvas canvas) {
    for (final room in BuildingData.roomsForFloor(floor)) {
      if (room.w * room.h < 8) continue;
      final rx = _s(room.x); final ry = _s(room.y);
      final rw = _s(room.w); final rh = _s(room.h);
      switch (room.type) {
        case RoomType.lectureHall: _lectureSeats(canvas, rx, ry, rw, rh);
        case RoomType.office:      _officeDesk(canvas, rx, ry, rw, rh);
        case RoomType.meetingRoom: _confTable(canvas, rx, ry, rw, rh);
        case RoomType.restroom:    _restroomFixtures(canvas, rx, ry, rw, rh);
        default: break;
      }
    }
  }

  void _lectureSeats(Canvas canvas, double rx, double ry, double rw, double rh) {
    const sw = 5.0, sh = 3.5, cg = 8.0, rg = 7.5, mx = 8.0, my = 9.0;
    var y = ry + my;
    while (y + sh < ry + rh - my * 0.4) {
      var x = rx + mx;
      while (x + sw < rx + rw - mx * 0.4) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, sw, sh), const Radius.circular(1)), _fPaint);
        x += sw + cg;
      }
      y += sh + rg;
    }
  }

  void _officeDesk(Canvas canvas, double rx, double ry, double rw, double rh) {
    final dw = rw * 0.5, dh = rh * 0.26;
    canvas.drawRect(Rect.fromLTWH(rx + (rw - dw) / 2, ry + rh * 0.56, dw, dh), _fPaint);
    canvas.drawCircle(Offset(rx + rw / 2, ry + rh * 0.40), rh * 0.13, _fPaint);
  }

  void _confTable(Canvas canvas, double rx, double ry, double rw, double rh) {
    final c = Offset(rx + rw / 2, ry + rh / 2);
    final tw = rw * 0.52, th = rh * 0.44;
    canvas.drawOval(Rect.fromCenter(center: c, width: tw, height: th), _fPaint);
    for (var i = 0; i < 6; i++) {
      final a = 2 * pi * i / 6;
      canvas.drawCircle(Offset(c.dx + (tw / 2 + 5.5) * cos(a), c.dy + (th / 2 + 4.5) * sin(a)), 3.2, _fPaint);
    }
  }

  void _restroomFixtures(Canvas canvas, double rx, double ry, double rw, double rh) {
    final fw = min(rw * 0.22, 7.0), fh = min(rh * 0.52, 10.0);
    canvas.drawRect(Rect.fromLTWH(rx + rw * 0.14, ry + (rh - fh) / 2, fw, fh), _fPaint);
    if (rw > 12) canvas.drawRect(Rect.fromLTWH(rx + rw * 0.54, ry + (rh - fh) / 2, fw, fh), _fPaint);
  }

  void _drawWalls(Canvas canvas) {
    final wallPaint = Paint()
      ..color = _wallColor ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2 ..strokeCap = StrokeCap.square ..strokeJoin = StrokeJoin.miter;
    final drawnKeys = <String>{};
    for (final room in BuildingData.roomsForFloor(floor)) {
      final roomDoors = BuildingData.doorsForRoom(room.id);
      for (final side in WallSide.values) {
        double x1, y1, x2, y2;
        switch (side) {
          case WallSide.north: x1=room.x;       y1=room.y;        x2=room.x+room.w; y2=room.y;
          case WallSide.south: x1=room.x;       y1=room.y+room.h; x2=room.x+room.w; y2=room.y+room.h;
          case WallSide.west:  x1=room.x;       y1=room.y;        x2=room.x;        y2=room.y+room.h;
          case WallSide.east:  x1=room.x+room.w; y1=room.y;       x2=room.x+room.w; y2=room.y+room.h;
        }
        final key = _segKey(x1, y1, x2, y2);
        if (!drawnKeys.add(key)) continue;
        final doorsOnSide = roomDoors.where((d) => d.side == side).toList()..sort((a, b) => a.position.compareTo(b.position));
        if (doorsOnSide.isEmpty) { _seg(canvas, x1, y1, x2, y2, 0, 1, wallPaint); continue; }
        var from = 0.0;
        for (final door in doorsOnSide) {
          final gs = (door.position - door.width / 2).clamp(0.0, 1.0);
          final ge = (door.position + door.width / 2).clamp(0.0, 1.0);
          if (gs > from) _seg(canvas, x1, y1, x2, y2, from, gs, wallPaint);
          _drawDoorSwing(canvas, x1, y1, x2, y2, gs, ge, side);
          from = ge;
        }
        if (from < 1.0) _seg(canvas, x1, y1, x2, y2, from, 1.0, wallPaint);
      }
    }
  }

  static String _segKey(double x1, double y1, double x2, double y2) {
    if (y1 == y2) {
      final lx = min(x1, x2), rx = max(x1, x2);
      return 'H${lx.toStringAsFixed(2)},${y1.toStringAsFixed(2)},${rx.toStringAsFixed(2)}';
    } else {
      final ty = min(y1, y2), by = max(y1, y2);
      return 'V${x1.toStringAsFixed(2)},${ty.toStringAsFixed(2)},${by.toStringAsFixed(2)}';
    }
  }

  void _seg(Canvas canvas, double x1, double y1, double x2, double y2, double t1, double t2, Paint p) {
    canvas.drawLine(
      Offset(_s(x1 + (x2 - x1) * t1), _s(y1 + (y2 - y1) * t1)),
      Offset(_s(x1 + (x2 - x1) * t2), _s(y1 + (y2 - y1) * t2)),
      p,
    );
  }

  void _drawDoorSwing(Canvas canvas, double x1, double y1, double x2, double y2, double gs, double ge, WallSide side) {
    final hx = _s(x1 + (x2 - x1) * gs), hy = _s(y1 + (y2 - y1) * gs);
    final ex = _s(x1 + (x2 - x1) * ge), ey = _s(y1 + (y2 - y1) * ge);
    final r = sqrt(pow(ex - hx, 2) + pow(ey - hy, 2));
    final leafPaint = Paint()..color = _wallColor.withValues(alpha: 0.80) ..strokeWidth = 1.8 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    final arcPaint  = Paint()..color = _wallColor.withValues(alpha: 0.45) ..strokeWidth = 1.2 ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(hx, hy), Offset(ex, ey), leafPaint);
    final double startAngle, sweep;
    switch (side) {
      case WallSide.north: startAngle = 0;      sweep =  pi / 2;
      case WallSide.south: startAngle = 0;      sweep = -pi / 2;
      case WallSide.west:  startAngle = pi / 2; sweep = -pi / 2;
      case WallSide.east:  startAngle = pi / 2; sweep =  pi / 2;
    }
    canvas.drawArc(Rect.fromCircle(center: Offset(hx, hy), radius: r), startAngle, sweep, false, arcPaint);
  }

  void _drawRoomLabels(Canvas canvas) {
    for (final room in BuildingData.roomsForFloor(floor)) {
      if (room.type == RoomType.corridor) continue;
      final cx = _s(room.x + room.w / 2), cy = _s(room.y + room.h / 2);
      final rw = _s(room.w);
      final rh = _s(room.h);
      final area = room.w * room.h;

      // Start from area-based size; FittedBox scales ~0.5× so canvas fonts are 2× screen size.
      // Cap by both dimensions: width controls line wrap, height controls total lines.
      double maxFs = area > 60 ? 30.0 : area > 25 ? 25.0 : area > 10 ? 21.0 : 17.0;
      maxFs = min(maxFs, min(rh * 0.45, rw * 0.32)).clamp(7.0, 30.0);

      // Iteratively reduce font until ALL wrapped text fits inside the room height.
      // No maxLines cap — text wraps freely so Arabic words are never truncated.
      TextPainter? tp;
      for (var fs = maxFs; fs >= 7; fs -= 1.5) {
        final t = TextPainter(
          text: TextSpan(text: room.shortName, style: TextStyle(
            color: const Color(0xFF0A0C10), fontSize: fs,
            fontWeight: FontWeight.w800, letterSpacing: -0.2, height: 1.25,
          )),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        )..layout(maxWidth: rw - 6);
        if (t.height <= rh - 4) { tp = t; break; }
      }
      if (tp == null) continue;
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
    }
  }

  void _drawRoute(Canvas canvas) {
    final nodes = routePath!.where((n) => n.floor == floor).toList();
    if (nodes.length < 2) return;
    final pts = nodes.map((n) => Offset(_s(n.x), _s(n.y))).toList();
    final path = _toPath(pts);
    canvas.drawPath(path, Paint()..color = _routeColor.withValues(alpha: 0.09) ..style = PaintingStyle.stroke ..strokeWidth = 28 ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(path, Paint()..color = _routeColor.withValues(alpha: 0.20) ..style = PaintingStyle.stroke ..strokeWidth = 15 ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(path, Paint()..color = _routeColor ..style = PaintingStyle.stroke ..strokeWidth = 6.0 ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.62) ..style = PaintingStyle.stroke ..strokeWidth = 2.0 ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round);
    _drawAnimatedArrows(canvas, pts);
  }

  Path _toPath(List<Offset> pts) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) { p.lineTo(pts[i].dx, pts[i].dy); }
    return p;
  }

  void _drawAnimatedArrows(Canvas canvas, List<Offset> pts) {
    var total = 0.0;
    final segs = <double>[];
    for (var i = 1; i < pts.length; i++) { final l = (pts[i] - pts[i-1]).distance; segs.add(l); total += l; }
    if (total == 0) return;
    for (var a = 0; a < 5; a++) {
      final target = ((animValue + a / 5.0) % 1.0) * total;
      var acc = 0.0;
      for (var i = 0; i < segs.length; i++) {
        if (acc + segs[i] >= target) {
          final frac = (target - acc) / segs[i];
          final pt  = pts[i] + (pts[i+1] - pts[i]) * frac;
          final ang = atan2((pts[i+1] - pts[i]).dy, (pts[i+1] - pts[i]).dx);
          _arrowHead(canvas, pt, ang);
          break;
        }
        acc += segs[i];
      }
    }
  }

  void _arrowHead(Canvas canvas, Offset c, double angle) {
    const sz = 6.5;
    final co = cos(angle), si = sin(angle);
    Offset r(double x, double y) => c + Offset(x*co - y*si, x*si + y*co);
    final path = Path()
      ..moveTo(r(sz,0).dx,            r(sz,0).dy)
      ..lineTo(r(-sz*.45,-sz*.55).dx, r(-sz*.45,-sz*.55).dy)
      ..lineTo(r(-sz*.1,0).dx,        r(-sz*.1,0).dy)
      ..lineTo(r(-sz*.45, sz*.55).dx, r(-sz*.45, sz*.55).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  void _drawEndpoints(Canvas canvas) {
    if (routePath == null || routePath!.isEmpty) return;
    NavNode? start, end;
    for (final n in routePath!) {
      if (n.floor == floor) { start ??= n; end = n; }
    }
    if (start != null && start == routePath!.first) _pin(canvas, Offset(_s(start.x), _s(start.y)), _srcColor, 'A');
    if (end   != null && end   == routePath!.last)  _pin(canvas, Offset(_s(end.x),   _s(end.y)),   _dstColor, 'B');
    _drawFloorTransitions(canvas);
  }

  void _pin(Canvas canvas, Offset pos, Color color, String label) {
    canvas.drawCircle(pos + const Offset(2, 3), 16, Paint()..color = Colors.black.withValues(alpha: 0.18) ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(pos, 16, Paint()..color = Colors.white);
    canvas.drawCircle(pos, 16, Paint()..color = color ..style = PaintingStyle.stroke ..strokeWidth = 3);
    canvas.drawCircle(pos, 11, Paint()..color = color);
    final tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawFloorTransitions(Canvas canvas) {
    if (routePath == null) return;
    for (var i = 1; i < routePath!.length; i++) {
      final prev = routePath![i-1], curr = routePath![i];
      if (prev.floor == curr.floor) continue;
      final node = prev.floor == floor ? prev : (curr.floor == floor ? curr : null);
      if (node == null) continue;
      final pos = Offset(_s(node.x), _s(node.y));
      final isUp = curr.floor > prev.floor;
      const bw = 70.0, bh = 24.0;
      final br = Rect.fromCenter(center: pos - const Offset(0, 30), width: bw, height: bh);
      canvas.drawRRect(RRect.fromRectAndRadius(br, const Radius.circular(10)), Paint()..color = _routeColor);
      final tp = TextPainter(
        text: TextSpan(text: '${isUp ? '↑' : '↓'} ${floorLabel(isUp ? curr.floor : prev.floor)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, br.center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawCompass(Canvas canvas, Size size) {
    const r = 22.0;
    final cx = size.width - r - 12;
    final cy = r + _topY + 8;
    canvas.drawCircle(Offset(cx + 1, cy + 2), r + 2, Paint()..color = Colors.black.withValues(alpha: 0.14) ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFCCCCCC) ..style = PaintingStyle.stroke ..strokeWidth = 1.0);
    final tickPaint = Paint()..color = const Color(0xFFCCCCCC) ..strokeWidth = 1.0;
    for (var i = 0; i < 4; i++) {
      final a = i * pi / 2;
      canvas.drawLine(Offset(cx + (r - 4) * cos(a), cy + (r - 4) * sin(a)), Offset(cx + (r - 1) * cos(a), cy + (r - 1) * sin(a)), tickPaint);
    }
    canvas.drawPath(Path()..moveTo(cx, cy - r * .72) ..lineTo(cx - 3.8, cy + 1.5) ..lineTo(cx + 3.8, cy + 1.5) ..close(), Paint()..color = const Color(0xFFE53935));
    canvas.drawPath(Path()..moveTo(cx, cy + r * .72) ..lineTo(cx - 3.8, cy - 1.5) ..lineTo(cx + 3.8, cy - 1.5) ..close(), Paint()..color = const Color(0xFFBBBBBB));
    canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = const Color(0xFFE53935) ..style = PaintingStyle.stroke ..strokeWidth = 1.2);
    final tp = TextPainter(text: const TextSpan(text: 'N', style: TextStyle(color: Color(0xFFE53935), fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - r + 2));
  }

  void _drawScaleBar(Canvas canvas, Size size) {
    final barW = _s(5.0);
    const bx = 14.0;
    final by = size.height - 16.0;
    const segCount = 5;
    final segW = barW / segCount;
    const tick = 3.5;
    final fill = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < segCount; i++) {
      fill.color = i.isEven ? const Color(0xFF444444) : Colors.white;
      canvas.drawRect(Rect.fromLTWH(bx + i * segW, by - tick, segW, tick * 2), fill);
    }
    final outline = Paint()..color = const Color(0xFF444444) ..strokeWidth = 1.0 ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(bx, by - tick, barW, tick * 2), outline);
    canvas.drawLine(Offset(bx, by - tick - 2), Offset(bx, by + tick + 2), outline);
    canvas.drawLine(Offset(bx + barW, by - tick - 2), Offset(bx + barW, by + tick + 2), outline);
    final tp = TextPainter(text: const TextSpan(text: '5 م', style: TextStyle(color: Color(0xFF555555), fontSize: 13, fontWeight: FontWeight.w600)), textDirection: TextDirection.rtl)..layout();
    tp.paint(canvas, Offset(bx + barW / 2 - tp.width / 2, by - tick - tp.height - 1));
  }

  bool _onRoute(String id) => routePath?.any((n) => n.roomId == id) ?? false;

  @override
  bool shouldRepaint(covariant FloorPlanPainter old) =>
      old.floor != floor || old.routePath != routePath ||
      old.sourceRoomId != sourceRoomId || old.destRoomId != destRoomId ||
      old.highlightRoomId != highlightRoomId || old.animValue != animValue;
}
