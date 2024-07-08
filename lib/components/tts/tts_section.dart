class Section {
  String title;
  List<Phrase> phrases;

  Section(this.title, this.phrases);

  factory Section.fromJson(Map<String, dynamic> json) {
    var phrasesFromJson = json['phrases'] as List;
    List<Phrase> phraseList =
        phrasesFromJson.map((i) => Phrase.fromJson(i)).toList();

    return Section(
      json['title'],
      phraseList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'phrases': phrases.map((e) => e.toJson()).toList(),
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
