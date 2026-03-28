import 'package:flutter/material.dart';
import '../theme.dart';
import '../wayfinding_screen.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Navigation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => _showTutorial(context),
          ),
        ],
      ),
      body: const WayfindingScreen(),
    );
  }

  void _showTutorial(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Navigation Guide',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NabihTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _tutorialStep(
                '1',
                'Select Starting Point',
                'Tap the "From" dropdown to choose your current location or where you want to start navigating from.',
                Icons.trip_origin,
                NabihTheme.success,
              ),
              _tutorialStep(
                '2',
                'Select Destination',
                'Tap the "To" dropdown to choose where you want to go. You can search for rooms, labs, halls, or facilities.',
                Icons.location_on,
                NabihTheme.error,
              ),
              _tutorialStep(
                '3',
                'View Route',
                'The system calculates the optimal path and displays it on the floor plan with animated direction arrows.',
                Icons.route,
                NabihTheme.secondary,
              ),
              _tutorialStep(
                '4',
                'Switch Floors',
                'If your route spans multiple floors, use the floor tabs to see each segment. Look for floor transition indicators.',
                Icons.layers,
                NabihTheme.primary,
              ),
              _tutorialStep(
                '5',
                'Zoom & Pan',
                'Pinch to zoom in/out on the floor plan. Drag to pan around and see details of the building layout.',
                Icons.zoom_in,
                NabihTheme.accent,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Map Legend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _legendItem(const Color(0xFFDCEEFB), 'Lab'),
              _legendItem(const Color(0xFFE0D8F0), 'Lecture Hall'),
              _legendItem(const Color(0xFFFFF8E1), 'Office'),
              _legendItem(const Color(0xFFD7ECD9), 'Stairs'),
              _legendItem(const Color(0xFFD5EDEA), 'Elevator'),
              _legendItem(const Color(0xFFD6EFF5), 'Restroom'),
              _legendItem(const Color(0xFFFCE4EC), 'Entrance'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tutorialStep(String number, String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: color)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey[300]!)),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
