import 'dart:convert';
import 'dart:io';

import 'package:axcess/pages/tts/tts_content.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../components/tts/tts_section.dart';

class TTSPage extends StatefulWidget {
  const TTSPage({super.key});

  @override
  _TTSPageState createState() => _TTSPageState();
}

class _TTSPageState extends State<TTSPage> {
  bool editMode = false;
  List<Section> _sections = [];
  int _selectedSectionIndex = 0;
  String? _jsonFilePath;

  @override
  void initState() {
    super.initState();
    _initJsonFile();
  }

  void toggleEditMode(bool value) {
    setState(() {
      editMode = value;
    });
  }

  void _addSection() {
    setState(() {
      String newSection = 'Section ${_sections.length + 1}';
      _sections.add(Section(newSection, []));
    });
    _updateJsonFile();
  }

  void _editSection() {
    final _sectionTitleController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Edit Section'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _sectionTitleController,
                    decoration: InputDecoration(labelText: 'Section Title'),
                  )
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
                      setState(() {
                        String oldSection =
                            _sections[_selectedSectionIndex].title;
                        _sections[_selectedSectionIndex].title =
                            _sectionTitleController.text;
                        _updateJsonFile();
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Edit'))
              ],
            ));
  }

  void _removeSection() {
    setState(() {
      _sections.removeAt(_selectedSectionIndex);
      _selectedSectionIndex = 0;
    });
    _updateJsonFile();
  }

  void _onSectionSelected(int index) {
    setState(() {
      _selectedSectionIndex = index;
    });
  }

  Future<void> _initJsonFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _jsonFilePath = '${directory.path}/tts_sections.json';
    final file = File(_jsonFilePath!);
    if (!await file.exists()) {
      await file.writeAsString(json.encode([]));
    } else {
      _loadSections();
    }
  }

  Future<void> _loadSections() async {
    final file = File(_jsonFilePath!);
    final String response = await file.readAsString();
    final List<dynamic> data = json.decode(response);
    setState(() {
      _sections = data.map((item) => Section.fromJson(item)).toList();
    });
  }

  Future<void> _updateJsonFile() async {
    try {
      final file = File(_jsonFilePath!);
      await file.writeAsString(
          json.encode(_sections.map((e) => e.toJson()).toList()));
    } catch (e) {
      print("Failed to update JSON file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure there are at least two sections
    if (_sections.isEmpty) {
      _sections = [
        Section('Section 1', []),
        Section('Section 2', []),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech'),
      ),
      body: Row(
        children: [
          if (editMode)
            Column(
              children: [
                SizedBox(height: 350),
                FloatingActionButton(
                  onPressed: _addSection,
                  child: Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: _editSection,
                  child: Icon(Icons.edit),
                ),
                FloatingActionButton(
                  onPressed: _removeSection,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          NavigationRail(
            selectedIndex: _selectedSectionIndex,
            onDestinationSelected: _onSectionSelected,
            labelType: NavigationRailLabelType.selected,
            destinations: [
              ..._sections.map((section) => NavigationRailDestination(
                    icon: Icon(
                      Icons.home,
                      size: 50,
                    ),
                    selectedIcon: Icon(
                      Icons.home_filled,
                      size: 100,
                    ),
                    label: SizedBox(
                      width: 200,
                      height: 100,
                      child: Text(
                        section.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  )),
            ],
          ),
          Expanded(
            child: TTSContent(
              editMode: editMode,
              section: _sections[_selectedSectionIndex],
              onTtsItemsChanged: (items) {
                setState(() {
                  _sections[_selectedSectionIndex].phrases = items;
                });
                _updateJsonFile();
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: SizedBox(
                child: Text('Admin'),
              ),
            ),
            Row(
              children: [
                const Padding(padding: EdgeInsets.all(16)),
                const Text('Edit Mode'),
                Switch(value: editMode, onChanged: toggleEditMode)
              ],
            )
          ],
        ),
      ),
    );
  }
}
