import 'package:flutter/material.dart';

class Section {
  String title;
  int tileCount;
  List<Phrase> phrases;
  Color backgroundColor;

  Section(this.title, this.tileCount, this.phrases, this.backgroundColor);

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      json['title'],
      json['tileCount'],
      (json['phrases'] as List).map((i) => Phrase.fromJson(i)).toList(),
      Color(json['backgroundColor']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'tileCount': tileCount,
        'phrases': phrases.map((e) => e.toJson()).toList(),
        'backgroundColor': backgroundColor.value,
      };
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

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
      };
}
