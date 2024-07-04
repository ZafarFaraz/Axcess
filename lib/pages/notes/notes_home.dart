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
  List<Subsection> _subsections = [];
  List<Map<String, dynamic>> _iosReminders = [];
  String? _jsonFilePath;
  String _selectedSection = 'note'; // Ensure this matches the type field values

  @override
  void initState() {
    super.initState();
    _initJsonFile();
    _loadReminders();
  }

  Future<void> _initJsonFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _jsonFilePath = '${directory.path}/notes.json';
    final file = File(_jsonFilePath!);
    if (!await file.exists()) {
      await file.writeAsString(json.encode(_initialSubsections()));
    }
    _loadSubsections();
  }

  Future<void> _loadSubsections() async {
    final file = File(_jsonFilePath!);
    final String response = await file.readAsString();
    final List<dynamic> data = await json.decode(response);
    setState(() {
      _subsections = data.map((item) => Subsection.fromJson(item)).toList();
    });
  }

  Future<void> _saveSubsections() async {
    final file = File(_jsonFilePath!);
    await file.writeAsString(
        json.encode(_subsections.map((e) => e.toJson()).toList()));
  }

  void _addSubsection(String title, String type, String content) {
    setState(() {
      _subsections.add(Subsection(title: title, type: type, content: content));
      _saveSubsections();
    });
  }

  void _removeSubsection(int index) {
    setState(() {
      _subsections.removeAt(index);
      _saveSubsections();
    });
  }

  void _showAddSubsectionDialog() {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    String _selectedType = 'note'; // Ensure this matches the type field values

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subsection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            DropdownButton<String>(
              value: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              items: [
                DropdownMenuItem(value: 'note', child: Text('Note')),
                DropdownMenuItem(value: 'reminder', child: Text('Reminder')),
              ],
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
              _addSubsection(_titleController.text, _selectedType,
                  _contentController.text);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  List<Subsection> _initialSubsections() {
    return [
      Subsection(
        title: 'Shopping List',
        type: 'note',
        content: 'Milk, Eggs, Bread, Butter',
      ),
      Subsection(
        title: 'Meeting Reminder',
        type: 'reminder',
        content: 'Team meeting at 10 AM on Monday',
      ),
    ];
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

  @override
  Widget build(BuildContext context) {
    List<Subsection> filteredSubsections = _subsections
        .where((subsection) => subsection.type == _selectedSection)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedSection == 'note' ? 0 : 1,
            onDestinationSelected: (index) {
              setState(() {
                _selectedSection = index == 0 ? 'note' : 'reminder';
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.note),
                label: Text('Notes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.alarm),
                label: Text('Reminders'),
              ),
            ],
          ),
          Expanded(
            child: filteredSubsections.isEmpty && _iosReminders.isEmpty
                ? Center(
                    child: Text(
                      'No subsections available',
                      style: TextStyle(fontSize: 24),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          3, // Adjust the number of columns as needed
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1, // Adjust the aspect ratio as needed
                    ),
                    itemCount:
                        filteredSubsections.length + _iosReminders.length,
                    itemBuilder: (context, index) {
                      if (index < filteredSubsections.length) {
                        final subsection = filteredSubsections[index];
                        return _buildSubsectionTile(subsection, index);
                      } else {
                        final reminder =
                            _iosReminders[index - filteredSubsections.length];
                        return _buildReminderTile(
                            reminder, index - filteredSubsections.length);
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubsectionDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubsectionTile(Subsection subsection, int index) {
    return Card(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(subsection.title,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _removeSubsection(index);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(subsection.content),
                  ],
                ),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          color: subsection.type == 'reminder'
              ? Colors.red.shade100
              : Colors.yellow.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subsection.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                subsection.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderTile(Map<String, dynamic> reminder, int index) {
    return Card(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(reminder['title'],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(reminder['notes'] ?? ''),
                    SizedBox(height: 16),
                    Text(reminder['completed'] ? 'Completed' : 'Not Completed'),
                  ],
                ),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.blue.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reminder['title'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                reminder['notes'] ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
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
}

class Subsection {
  final String title;
  final String type; // "reminder" or "note"
  final String content;

  Subsection({
    required this.title,
    required this.type,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type,
        'content': content,
      };

  factory Subsection.fromJson(Map<String, dynamic> json) => Subsection(
        title: json['title'],
        type: json['type'],
        content: json['content'],
      );
}
