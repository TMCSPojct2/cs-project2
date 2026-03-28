import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/event_model.dart';
import '../data/demo_data.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _organizerController = TextEditingController();
  String _category = 'Academic';
  DateTime _date = DateTime.now().add(const Duration(days: 7));

  void _publish() {
    if (!_formKey.currentState!.validate()) return;

    final event = UniEvent(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: _date,
      time: _timeController.text.trim(),
      location: _locationController.text.trim(),
      category: _category,
      organizer: _organizerController.text.trim(),
    );

    Navigator.of(context).pop(event);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully!'), backgroundColor: NabihTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title', prefixIcon: Icon(Icons.title)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                items: DemoData.eventCategories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFF0F3F5),
                leading: const Icon(Icons.calendar_today, color: NabihTheme.primary),
                title: Text('${_date.day}/${_date.month}/${_date.year}'),
                subtitle: const Text('Tap to change date'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (e.g. 09:00 AM - 12:00 PM)', prefixIcon: Icon(Icons.access_time)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Organizer / Contact', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.publish),
                label: const Text('Publish Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _organizerController.dispose();
    super.dispose();
  }
}
