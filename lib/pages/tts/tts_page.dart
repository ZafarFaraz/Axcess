import 'package:axcess/pages/tts/tts_content.dart';
import 'package:flutter/material.dart';

class TTSPage extends StatefulWidget {
  const TTSPage({super.key});

  @override
  _TTSPageState createState() => _TTSPageState();
}

class _TTSPageState extends State<TTSPage> {
  bool editMode = false;
  List<String> _sections = ['Section 1', 'Section 2', 'Section 3'];
  int _selectedSectionIndex = 0;

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  void _addSection() {
    setState(() {
      _sections.add('Section ${_sections.length + 1}');
    });
  }

  void _onSectionSelected(int index) {
    setState(() {
      _selectedSectionIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech'),
      ),
      body: Row(
        children: [
          FloatingActionButton(
            onPressed: _addSection,
            child: Icon(Icons.add),
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
              child: Text('Edit Mode'),
            ),
            ListTile(
              title: Text('Edit Mode'),
              onTap: () {
                toggleEditMode();
                Navigator.of(context).pop();
                print(editMode);
              },
            ),
          ],
        ),
      ),
    );
  }
}
