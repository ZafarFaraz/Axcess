import 'dart:convert';
import 'dart:io';
import 'package:axcess/components/base_widgets/scroll_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import '../../components/colors.dart';
import '../../components/tts/tts_section.dart';
import '../../components/tts/tts_button.dart';

class TTSPage extends StatefulWidget {
  const TTSPage({super.key});

  @override
  _TTSPageState createState() => _TTSPageState();
}

class _TTSPageState extends State<TTSPage> {
  List<Section> _sections = [];
  String? _jsonFilePath;
  int _selectedSectionIndex = 0;
  bool editMode = false;
  late FlutterTts flutterTts;
  final TextEditingController _phraseController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initJsonFile();
  }

  Future<void> _initJsonFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _jsonFilePath = '${directory.path}/tts.json';
    final file = File(_jsonFilePath!);

    if (!await file.exists()) {
      String jsonString = await rootBundle.loadString('lib/assets/tts.json');
      await file.writeAsString(jsonString);
      setState(() {
        _sections = (json.decode(jsonString) as List)
            .map((item) => Section.fromJson(item))
            .toList();
      });
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
    final file = File(_jsonFilePath!);
    await file
        .writeAsString(json.encode(_sections.map((e) => e.toJson()).toList()));
  }

  void _addSection() {
    setState(() {
      String newSectionTitle = 'Section ${_sections.length + 1}';
      _sections.add(Section(newSectionTitle, 3, [], Colors.white));
    });
    _updateJsonFile();
  }

  void _removeSection() {
    if (_sections.isNotEmpty) {
      setState(() {
        _sections.removeAt(_selectedSectionIndex);
        _selectedSectionIndex =
            (_selectedSectionIndex > 0) ? _selectedSectionIndex - 1 : 0;
      });
      _updateJsonFile();
    }
  }

  void _editSection() {
    if (_sections.isEmpty) return;

    final sectionTitleController = TextEditingController(
      text: _sections[_selectedSectionIndex].title,
    );

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Edit Section'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sectionTitleController,
                    decoration:
                        const InputDecoration(labelText: 'Section Title'),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _sections[_selectedSectionIndex].title =
                            sectionTitleController.text;
                        _updateJsonFile();
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Edit'))
              ],
            ));
  }

  void _addPhrase(int sectionIndex, String label) {
    if (_sections.isEmpty) return;

    setState(() {
      String newKey = 'custom_${_sections[sectionIndex].phrases.length}';
      _sections[sectionIndex].phrases.add(Phrase(newKey, label));
    });
    _updateJsonFile();
  }

  void _removePhrase(int sectionIndex, int phraseIndex) {
    if (_sections.isEmpty) return;

    setState(() {
      _sections[sectionIndex].phrases.removeAt(phraseIndex);
    });
    _updateJsonFile();
  }

  void _onSectionSelected(int index) {
    setState(() {
      _selectedSectionIndex = index;
    });
  }

  void toggleEditMode(bool value) {
    setState(() {
      editMode = value;
    });
    _updateJsonFile();
  }

  void _incrementTileCount() {
    if (_sections.isEmpty) return;

    setState(() {
      if (_sections[_selectedSectionIndex].tileCount < 4) {
        _sections[_selectedSectionIndex].tileCount++;
      }
    });
    _updateJsonFile();
  }

  void _decrementTileCount() {
    if (_sections.isEmpty) return;

    setState(() {
      if (_sections[_selectedSectionIndex].tileCount > 1) {
        _sections[_selectedSectionIndex].tileCount--;
      }
    });
    _updateJsonFile();
  }

  void _changeSectionColor(Color newColor) {
    if (_sections.isEmpty) return;

    setState(() {
      _sections[_selectedSectionIndex].backgroundColor = newColor;
    });
    _updateJsonFile();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Speech'),
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
            if (_sections.isNotEmpty)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.all(10)),
                      const Text('Edit Mode'),
                      Switch(value: editMode, onChanged: toggleEditMode)
                    ],
                  ),
                  if (editMode)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(padding: EdgeInsets.all(10)),
                            const Text('Tiles per Row: '),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _decrementTileCount,
                            ),
                            Text(
                                '${_sections[_selectedSectionIndex].tileCount}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _incrementTileCount,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(padding: EdgeInsets.all(10)),
                            DropdownButton<Color>(
                              value: _sections[_selectedSectionIndex]
                                  .backgroundColor,
                              items: wcagColorPairs
                                  .map((colorPair) => DropdownMenuItem<Color>(
                                        value: colorPair.backgroundColor,
                                        child: Container(
                                          width: 100,
                                          height: 20,
                                          color: colorPair.backgroundColor,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (Color? newColor) {
                                if (newColor != null) {
                                  _changeSectionColor(newColor);
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    )
                ],
              ),
          ],
        ),
      ),
      body: _sections.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                if (editMode)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: _addSection,
                        tooltip: 'Add Section',
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        onPressed: _editSection,
                        tooltip: 'Edit Section',
                        child: const Icon(Icons.edit),
                      ),
                      const SizedBox(height: 16),
                      if (_sections.length > 2)
                        FloatingActionButton(
                          onPressed: _removeSection,
                          tooltip: 'Remove Section',
                          child: const Icon(Icons.remove),
                        ),
                    ],
                  ),
                NavigationRail(
                  selectedIndex: _selectedSectionIndex,
                  onDestinationSelected: _onSectionSelected,
                  labelType: NavigationRailLabelType.selected,
                  destinations: _sections
                      .map((section) => NavigationRailDestination(
                            icon: Container(
                              width: 30,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: section.backgroundColor,
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            selectedIcon: Container(
                              width: 200,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: section.backgroundColor,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                child: Text(
                                  section.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: getTextColorForBackground(
                                          section.backgroundColor),
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            label: SizedBox(
                              width: 200,
                              height: 100,
                              child: Center(
                                child: Text(
                                  section.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                if (_sections.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _phraseController,
                                      decoration: InputDecoration(
                                        labelText: "Enter custom phrase",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (_phraseController
                                                  .text.isNotEmpty) {
                                                _speak(_phraseController.text);
                                              }
                                            },
                                            child: const Text("Speak"),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (_phraseController
                                                  .text.isNotEmpty) {
                                                _addPhrase(
                                                    _selectedSectionIndex,
                                                    _phraseController.text);
                                                _phraseController.clear();
                                              }
                                            },
                                            child: const Text("Add"),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _phraseController.clear();
                                            },
                                            child: const Text("Clear"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: GridView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16.0),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        _sections[_selectedSectionIndex]
                                            .tileCount,
                                    mainAxisSpacing: 16.0,
                                    crossAxisSpacing: 16.0,
                                    childAspectRatio: 2.5,
                                  ),
                                  itemCount: _sections[_selectedSectionIndex]
                                      .phrases
                                      .length,
                                  itemBuilder: (context, phraseIndex) {
                                    final phrase =
                                        _sections[_selectedSectionIndex]
                                            .phrases[phraseIndex];
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: TTSButton(
                                            text: phrase.label,
                                            backgroundColor:
                                                _sections[_selectedSectionIndex]
                                                    .backgroundColor,
                                            onPressed: () {
                                              _speak(phrase.label);
                                            },
                                            onLongPress:
                                                () {}, // Required but not used here
                                          ),
                                        ),
                                        if (editMode)
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: FloatingActionButton(
                                              mini: true,
                                              backgroundColor: Colors.red,
                                              onPressed: () => _removePhrase(
                                                  _selectedSectionIndex,
                                                  phraseIndex),
                                              child: const Icon(Icons.close,
                                                  size: 20),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        scrollBar(scrollController: _scrollController),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
