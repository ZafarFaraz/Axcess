import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  static const platform = MethodChannel('axcessibility_notify');
  List<Map<String, dynamic>> _iosReminders = [];
  String _selectedSection = 'due'; // Default to due reminders

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final List<dynamic> reminders =
          await platform.invokeMethod('loadReminders');
      setState(() {
        _iosReminders = reminders
            .map((reminder) => Map<String, dynamic>.from(reminder))
            .toList();
      });
    } on PlatformException catch (e) {
      print("Failed to load reminders: '${e.message}'.");
    }
  }

  Future<void> _addReminder(String title, String notes) async {
    try {
      await platform
          .invokeMethod('addReminder', {'title': title, 'notes': notes});
      _loadReminders();
    } on PlatformException catch (e) {
      print("Failed to add reminder: '${e.message}'.");
    }
  }

  Future<void> _updateReminder(Map<String, dynamic> reminder) async {
    try {
      await platform.invokeMethod('updateReminder', reminder);
      _loadReminders();
    } on PlatformException catch (e) {
      print("Failed to update reminder: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dueReminders =
        _iosReminders.where((reminder) => !reminder['completed']).toList();
    final List<Map<String, dynamic>> completedReminders =
        _iosReminders.where((reminder) => reminder['completed']).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedSection == 'due' ? 0 : 1,
            onDestinationSelected: (index) {
              setState(() {
                _selectedSection = index == 0 ? 'due' : 'completed';
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                  selectedIcon: Icon(
                    Icons.alarm,
                    size: 60,
                  ),
                  icon: Icon(
                    Icons.alarm,
                    size: 20,
                  ),
                  label: SizedBox(
                    width: 150,
                    height: 100,
                    child: Text(
                      'Due',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30),
                    ),
                  )),
              NavigationRailDestination(
                  icon: Icon(
                    Icons.check,
                    size: 40,
                  ),
                  label: SizedBox(
                    width: 150,
                    height: 100,
                    child: Text(
                      'Completed',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25),
                    ),
                  )),
            ],
          ),
          Expanded(
            child: _selectedSection == 'due'
                ? _buildRemindersGrid(
                    dueReminders, 'No due reminders available')
                : _buildRemindersGrid(
                    completedReminders, 'No completed reminders available'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildRemindersGrid(
      List<Map<String, dynamic>> reminders, String emptyMessage) {
    return reminders.isEmpty
        ? Center(
            child: Text(
              emptyMessage,
              style: TextStyle(fontSize: 24),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Adjust the number of columns as needed
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3, // Adjust the aspect ratio as needed
            ),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderTile(reminder, index);
            },
          );
  }

  Widget _buildReminderTile(Map<String, dynamic> reminder, int index) {
    return Card(
      child: InkWell(
        onTap: () {
          _showUpdateReminderDialog(reminder);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.blue.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reminder['title'],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              Text(
                reminder['notes'] ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                reminder['completed'] ? 'Completed' : 'Not Completed',
                style: TextStyle(
                    color: reminder['completed'] ? Colors.green : Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    final _titleController = TextEditingController();
    final _notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addReminder(_titleController.text, _notesController.text);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateReminderDialog(Map<String, dynamic> reminder) {
    final _titleController = TextEditingController(text: reminder['title']);
    final _notesController = TextEditingController(text: reminder['notes']);
    bool _completed = reminder['completed'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
            ),
            CheckboxListTile(
              title: Text('Completed'),
              value: _completed,
              onChanged: (bool? value) {
                setState(() {
                  _completed = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              reminder['title'] = _titleController.text;
              reminder['notes'] = _notesController.text;
              reminder['completed'] = _completed;
              _updateReminder(reminder);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
