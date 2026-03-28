import 'dart:collection';
import 'models.dart';
import 'building_data.dart';

/// Dijkstra-based pathfinder for the building navigation graph
class Pathfinder {
  final Map<String, NavNode> _nodes = {};
  final Map<String, List<_Edge>> _adjacency = {};

  Pathfinder() {
    // Index all nodes
    for (final node in BuildingData.allNodes) {
      _nodes[node.id] = node;
      _adjacency[node.id] = [];
    }
    // Build adjacency list (bidirectional)
    for (final edge in BuildingData.buildEdges()) {
      _adjacency[edge.fromId]?.add(_Edge(edge.toId, edge.weight, edge.isFloorTransition));
      _adjacency[edge.toId]?.add(_Edge(edge.fromId, edge.weight, edge.isFloorTransition));
    }
  }

  /// Find the shortest path between two rooms by their room IDs.
  /// Returns null if no path exists.
  List<NavNode>? findPath(String fromRoomId, String toRoomId) {
    final startNode = BuildingData.nodeForRoom(fromRoomId);
    final endNode = BuildingData.nodeForRoom(toRoomId);
    if (startNode == null || endNode == null) return null;
    return _dijkstra(startNode.id, endNode.id);
  }

  List<NavNode>? _dijkstra(String startId, String endId) {
    final dist = <String, double>{};
    final prev = <String, String?>{};
    final visited = <String>{};

    // Priority queue: (distance, nodeId)
    final pq = SplayTreeSet<_PQEntry>((a, b) {
      final cmp = a.dist.compareTo(b.dist);
      return cmp != 0 ? cmp : a.id.compareTo(b.id);
    });

    for (final id in _nodes.keys) {
      dist[id] = double.infinity;
      prev[id] = null;
    }
    dist[startId] = 0;
    pq.add(_PQEntry(startId, 0));

    // Helper to check if a node is a room (not a corridor/aisle)
    bool isRoomNode(String nodeId) {
      final node = _nodes[nodeId];
      if (node == null) return false;
      if (node.roomId == null) return false;
      Room? room;
      for (final r in BuildingData.allRooms) {
        if (r.id == node.roomId) {
          room = r;
          break;
        }
      }
      if (room == null) return false;
      return room.type != RoomType.corridor;
    }

    while (pq.isNotEmpty) {
      final current = pq.first;
      pq.remove(current);

      if (visited.contains(current.id)) continue;
      visited.add(current.id);

      if (current.id == endId) break;

      for (final edge in _adjacency[current.id] ?? []) {
        if (visited.contains(edge.toId)) continue;
        // Only allow passing through corridor/aisle nodes, except for start/end
        if (edge.toId != endId && edge.toId != startId && isRoomNode(edge.toId)) {
          continue;
        }
        final newDist = dist[current.id]! + edge.weight;
        if (newDist < dist[edge.toId]!) {
          dist[edge.toId] = newDist;
          prev[edge.toId] = current.id;
          pq.add(_PQEntry(edge.toId, newDist));
        }
      }
    }

    // Reconstruct path
    if (dist[endId] == double.infinity) return null;

    final path = <NavNode>[];
    String? current = endId;
    while (current != null) {
      path.add(_nodes[current]!);
      current = prev[current];
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

class _PQEntry {
  final String id;
  final double dist;
  const _PQEntry(this.id, this.dist);
}
