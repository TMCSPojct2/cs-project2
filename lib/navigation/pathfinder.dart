import 'dart:collection';

import 'building_data.dart';
import 'models.dart';

class Pathfinder {
  final Map<String, NavNode> _nodes = {};
  final Map<String, List<_Edge>> _adjacency = {};

  Pathfinder() {
    for (final node in BuildingData.allNodes) {
      _nodes[node.id] = node;
      _adjacency[node.id] = [];
    }
    for (final edge in BuildingData.buildEdges()) {
      _adjacency[edge.fromId]?.add(_Edge(edge.toId, edge.weight, edge.isFloorTransition));
      _adjacency[edge.toId]?.add(_Edge(edge.fromId, edge.weight, edge.isFloorTransition));
    }
  }

  List<NavNode>? findPath(String fromRoomId, String toRoomId) {
    final startNode = BuildingData.nodeForRoom(fromRoomId);
    final endNode = BuildingData.nodeForRoom(toRoomId);
    if (startNode == null || endNode == null) {
      return null;
    }
    return _dijkstra(startNode.id, endNode.id);
  }

  List<NavNode>? _dijkstra(String startId, String endId) {
    final distance = <String, double>{};
    final previous = <String, String?>{};
    final visited = <String>{};
    final queue = SplayTreeSet<_PriorityEntry>((left, right) {
      final compare = left.distance.compareTo(right.distance);
      return compare != 0 ? compare : left.id.compareTo(right.id);
    });

    for (final id in _nodes.keys) {
      distance[id] = double.infinity;
      previous[id] = null;
    }
    distance[startId] = 0;
    queue.add(_PriorityEntry(startId, 0));

    bool isRoomNode(String nodeId) {
      final node = _nodes[nodeId];
      if (node == null || node.roomId == null) {
        return false;
      }
      final room = BuildingData.allRooms.where((item) => item.id == node.roomId).firstOrNull;
      if (room == null) {
        return false;
      }
      return room.type != RoomType.corridor;
    }

    while (queue.isNotEmpty) {
      final current = queue.first;
      queue.remove(current);

      if (visited.contains(current.id)) {
        continue;
      }
      visited.add(current.id);

      if (current.id == endId) {
        break;
      }

      for (final edge in _adjacency[current.id] ?? const <_Edge>[]) {
        if (visited.contains(edge.toId)) {
          continue;
        }
        if (edge.toId != startId && edge.toId != endId && isRoomNode(edge.toId)) {
          continue;
        }

        final nextDistance = distance[current.id]! + edge.weight;
        if (nextDistance < distance[edge.toId]!) {
          distance[edge.toId] = nextDistance;
          previous[edge.toId] = current.id;
          queue.add(_PriorityEntry(edge.toId, nextDistance));
        }
      }
    }

    if (distance[endId] == double.infinity) {
      return null;
    }

    final path = <NavNode>[];
    String? current = endId;
    while (current != null) {
      path.add(_nodes[current]!);
      current = previous[current];
    }
    return path.reversed.toList();
  }
}

class _Edge {
  final String toId;
  final double weight;
  final bool isFloorTransition;

  const _Edge(this.toId, this.weight, this.isFloorTransition);
}

class _PriorityEntry {
  final String id;
  final double distance;

  const _PriorityEntry(this.id, this.distance);
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
