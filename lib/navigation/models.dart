import 'package:flutter/material.dart';

/// Types of rooms in the building
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

/// Represents a room on a specific floor of the building
class Room {
  final String id;
  final String name;
  final String shortName;
  final RoomType type;
  final int floor;
  final double x, y, w, h;

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

  Color get baseColor {
    switch (type) {
      case RoomType.lab:
        return const Color(0xFFBBDEFB);
      case RoomType.lectureHall:
        return const Color(0xFFD1C4E9);
      case RoomType.office:
        return const Color(0xFFFFE0B2);
      case RoomType.corridor:
        return const Color(0xFFEEEEEE);
      case RoomType.stairs:
        return const Color(0xFFC8E6C9);
      case RoomType.elevator:
        return const Color(0xFFB2DFDB);
      case RoomType.restroom:
        return const Color(0xFFB2EBF2);
      case RoomType.meetingRoom:
        return const Color(0xFFFFF9C4);
      case RoomType.entrance:
        return const Color(0xFFFFCDD2);
      case RoomType.room:
        return const Color(0xFFF5F5F5);
    }
  }

  /// Slightly darker version for wall sides
  Color get wallColor {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0, 1)).toColor();
  }

  /// Even darker for the side wall
  Color get sideColor {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0, 1)).toColor();
  }

  /// Whether this room is selectable as a navigation target
  bool get isNavigable =>
      type != RoomType.corridor &&
      type != RoomType.stairs &&
      type != RoomType.elevator;
}

/// A node in the navigation graph
class NavNode {
  final String id;
  final double x, y;
  final int floor;
  final String? roomId; // associated room, if any

  const NavNode({
    required this.id,
    required this.x,
    required this.y,
    required this.floor,
    this.roomId,
  });

  Offset get offset => Offset(x, y);
}

/// An edge in the navigation graph
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

/// A step along a navigation path
class PathStep {
  final NavNode node;
  final int floor;

  const PathStep({required this.node, required this.floor});
}

/// Which side of a room does a wall or door sit on
enum WallSide { north, south, east, west }

/// A door opening in a room wall
class DoorOpening {
  final String roomId;
  final WallSide side;
  /// Fractional position along the wall (0 = start corner, 1 = end corner)
  final double position;
  /// Fractional width of the opening (0..1)
  final double width;

  const DoorOpening({
    required this.roomId,
    required this.side,
    this.position = 0.5,
    this.width = 0.2,
  });
}

/// Explicit interior wall segment (for things like corridor dividers)
class WallSegment {
  final int floor;
  final double x1, y1, x2, y2;
  final double height;

  const WallSegment({
    required this.floor,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.height = 2.5,
  });
}

/// String labels for floor numbers
String floorLabel(int floor) {
  switch (floor) {
    case 0:
      return 'Ground';
    case 1:
      return '1st';
    case 2:
      return '2nd';
    case 3:
      return '3rd';
    case 4:
      return '4th';
    default:
      return 'Floor $floor';
  }
}
