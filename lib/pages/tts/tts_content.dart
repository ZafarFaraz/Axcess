import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_voice_flutter/personal_voice_flutter.dart';

import '../../components/tts_button.dart';

class TTSContent extends StatefulWidget {
  final bool editMode;
  final String section;
  final VoidCallback onAddSection;

  const TTSContent(
      {super.key,
      required this.editMode,
      required this.section,
      required this.onAddSection});

  @override
  State<StatefulWidget> createState() => _TTSContentState();
}

class _TTSContentState extends State<TTSContent> {
  List<Map<String, String>> _ttsItems = [];
  TextEditingController _customPhraseController = TextEditingController();
  var speechPermission = "";
  String? _jsonFilePath;

  @override
  void initState() {
    super.initState();
    _initJsonFile();
  }

  Future<void> _initJsonFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _jsonFilePath = '${directory.path}/tts_${widget.section}.json';
    final file = File(_jsonFilePath!);
    if (!await file.exists()) {
      await file.writeAsString(await DefaultAssetBundle.of(context)
          .loadString('lib/assets/tts.json'));
    }
    _loadTTSItems();
  }

  Future<void> _loadTTSItems() async {
    final file = File(_jsonFilePath!);
    final String response = await file.readAsString();
    final List<dynamic> data = await json.decode(response);
    speechPermission =
        (await PersonalVoiceFlutter().requestPersonalVoiceAuthorization())!;
    setState(() {
      _ttsItems = data.map((item) => Map<String, String>.from(item)).toList();
    });
  }

  Future<void> _addCustomPhrase(String phrase) async {
    setState(() {
      _ttsItems.add({"key": "custom_${_ttsItems.length}", "label": phrase});
    });
    await _updateJsonFile();
  }

  Future<void> _removePhrase(int index) async {
    setState(() {
      _ttsItems.removeAt(index);
    });
    await _updateJsonFile();
  }

  Future<void> _updateJsonFile() async {
    try {
      final file = File(_jsonFilePath!);
      await file.writeAsString(json.encode(_ttsItems));
    } catch (e) {
      print("Failed to update JSON file: $e");
    }
  }

  void ttsSpeak(String label) async {
    if (speechPermission == 'authorized') {
      await PersonalVoiceFlutter().speak(label);
    }
    print('Speaking: $label');
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black, Colors.grey[800]!]
              : [Colors.white, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customPhraseController,
                        decoration: InputDecoration(
                          labelText: "Enter custom phrase",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        if (_customPhraseController.text.isNotEmpty) {
                          ttsSpeak(_customPhraseController.text);
                        }
                      },
                      child: Text("Speak"),
                    )),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        if (_customPhraseController.text.isNotEmpty) {
                          _addCustomPhrase(_customPhraseController.text);
                          _customPhraseController.clear();
                        }
                      },
                      child: Text("Add"),
                    )),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        if (_customPhraseController.text.isNotEmpty) {
                          _customPhraseController.clear();
                        }
                      },
                      child: Text("Clear"),
                    ))
                  ],
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of items per row
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 2.5, // Aspect ratio for each item
              ),
              itemCount: _ttsItems.length,
              itemBuilder: (context, index) {
                final ttsItem = _ttsItems[index];
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black54
                                  : Colors.grey.withOpacity(0.3),
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(
                            top:
                                16.0), // Add margin to make space for the button
                        child: TTSButton(
                            text: ttsItem['label']!,
                            onPressed: () {
                              ttsSpeak(ttsItem['label']!);
                              print('Button Pressed');
                            },
                            onLongPress: () {}),
                      ),
                    ),
                    if (widget.editMode)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.red,
                          onPressed: () {
                            _removePhrase(index);
                          },
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
