import 'package:flutter/material.dart';

enum RoomType {
  lab,
  lectureHall,
  office,
  corridor,
  stairs,
  elevator,
  restroom,
  meetingRoom,
  entrance,
  room,
}

class Room {
  final String id;
  final String name;
  final String shortName;
  final RoomType type;
  final int floor;
  final double x;
  final double y;
  final double w;
  final double h;

  const Room({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.floor,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  Rect get rect => Rect.fromLTWH(x, y, w, h);
  Offset get center => rect.center;

  bool get isNavigable =>
      type != RoomType.corridor &&
      type != RoomType.stairs &&
      type != RoomType.elevator;
}

class NavNode {
  final String id;
  final double x;
  final double y;
  final int floor;
  final String? roomId;

  const NavNode({
    required this.id,
    required this.x,
    required this.y,
    required this.floor,
    this.roomId,
  });

  Offset get offset => Offset(x, y);
}

class NavEdge {
  final String fromId;
  final String toId;
  final double weight;
  final bool isFloorTransition;

  const NavEdge({
    required this.fromId,
    required this.toId,
    required this.weight,
    this.isFloorTransition = false,
  });
}

enum WallSide { north, south, east, west }

class DoorOpening {
  final String roomId;
  final WallSide side;
  final double position;
  final double width;

  const DoorOpening({
    required this.roomId,
    required this.side,
    this.position = 0.5,
    this.width = 0.2,
  });
}

String floorLabel(int floor) {
  switch (floor) {
    case 0:
      return 'الأرضي';
    case 1:
      return 'الأول';
    case 2:
      return 'الثاني';
    case 3:
      return 'الثالث';
    case 4:
      return 'الرابع';
    default:
      return 'طابق $floor';
  }
}

String floorShortLabel(int floor) {
  switch (floor) {
    case 0:
      return 'أ';
    case 1:
      return '١';
    case 2:
      return '٢';
    case 3:
      return '٣';
    case 4:
      return '٤';
    default:
      return '$floor';
  }
}
