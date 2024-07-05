import 'package:flutter/material.dart';
import 'package:personal_voice_flutter/personal_voice_flutter.dart';
import '../../components/tts/tts_button.dart';
import '../../components/tts/tts_section.dart';

class TTSContent extends StatefulWidget {
  final bool editMode;
  final Section section;
  final ValueChanged<List<Map<String, String>>> onTtsItemsChanged;

  const TTSContent({
    super.key,
    required this.editMode,
    required this.section,
    required this.onTtsItemsChanged,
  });

  @override
  State<StatefulWidget> createState() => _TTSContentState();
}

class _TTSContentState extends State<TTSContent> {
  List<Map<String, String>> _ttsItems = [];
  TextEditingController _customPhraseController = TextEditingController();
  var speechPermission = "";

  @override
  void initState() {
    super.initState();
    _ttsItems = widget.section.phrases;
    _requestSpeechPermission();
  }

  void _requestSpeechPermission() async {
    speechPermission =
        (await PersonalVoiceFlutter().requestPersonalVoiceAuthorization())!;
  }

  void _addCustomPhrase(String phrase) {
    setState(() {
      _ttsItems.add({"key": "custom_${_ttsItems.length}", "label": phrase});
      widget.onTtsItemsChanged(_ttsItems);
    });
  }

  void _removePhrase(int index) {
    setState(() {
      _ttsItems.removeAt(index);
      widget.onTtsItemsChanged(_ttsItems);
    });
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
                const SizedBox(height: 8),
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_customPhraseController.text.isNotEmpty) {
                            _addCustomPhrase(_customPhraseController.text);
                            _customPhraseController.clear();
                          }
                        },
                        child: Text("Add"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_customPhraseController.text.isNotEmpty) {
                            _customPhraseController.clear();
                          }
                        },
                        child: Text("Clear"),
                      ),
                    ),
                  ],
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
