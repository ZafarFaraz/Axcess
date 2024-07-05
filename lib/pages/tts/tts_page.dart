import 'dart:convert';
import 'dart:io';

import 'package:axcess/pages/tts/tts_content.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TTSPage extends StatefulWidget {
  const TTSPage({super.key});

  @override
  _TTSPageState createState() => _TTSPageState();
}

class _TTSPageState extends State<TTSPage> {
  bool editMode = false;
  List<String> _sections = ['Section 1', 'Section 2', 'Section 3'];
  int _selectedSectionIndex = 0;
  String? _jsonFilePath;

  void toggleEditMode(bool value) {
    setState(() {
      editMode = value;
    });
  }

  void _addSection() {
    setState(() {
      _sections.add('Section ${_sections.length + 1}');
    });
    _updateJsonFile();
  }

  void _removeSection() {
    print(_selectedSectionIndex.toString());
    setState(() {
      _sections.removeAt(_selectedSectionIndex - 1);
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
    _jsonFilePath = '${directory.path}/tts_$_sections.json';
    final file = File(_jsonFilePath!);
    print(_jsonFilePath);
    if (!await file.exists()) {
      await file.writeAsString(await DefaultAssetBundle.of(context)
          .loadString('lib/assets/tts.json'));
    }
  }

  Future<void> _updateJsonFile() async {
    try {
      final file = File(_jsonFilePath!);
      await file.writeAsString(json.encode(_sections));
    } catch (e) {
      print("Failed to update JSON file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech'),
      ),
      body: Row(
        children: [
          if (editMode)
            Column(
              children: [
                SizedBox(
                  height: 375,
                ),
                FloatingActionButton(
                  onPressed: _addSection,
                  child: Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: _removeSection,
                  child: Icon(Icons.exposure_minus_1),
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
                        section,
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
              onAddSection: _addSection,
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
