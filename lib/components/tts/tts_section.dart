import 'package:axcess/components/tts/tts_button.dart';
import 'package:flutter/material.dart';

class Section {
  String title;
  List<Phrase> phrases;
  int tileCount;
  Color backgroundColor;

  Section(this.title, this.tileCount, this.phrases, this.backgroundColor);

  factory Section.fromJson(Map<String, dynamic> json) {
    var phrasesFromJson = json['phrases'] as List;
    List<Phrase> phraseList =
        phrasesFromJson.map((i) => Phrase.fromJson(i)).toList();

    return Section(json['title'], json['tileCount'] ?? 3, phraseList,
        json['backgroundColor'] ?? wcagColorPairs[0].backgroundColor);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'tileCount': tileCount,
      'phrases': phrases.map((e) => e.toJson()).toList(),
      'backoundColor': backgroundColor.value
    };
  }
}

class Phrase {
  String key;
  String label;

  Phrase(this.key, this.label);

  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(
      json['key'],
      json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
    };
  }
}
