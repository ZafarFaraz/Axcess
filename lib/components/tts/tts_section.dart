class Section {
  String title;
  List<Map<String, String>> phrases;

  Section(this.title, this.phrases);

  Map<String, dynamic> toJson() => {
        'title': title,
        'phrases': phrases,
      };

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        json['title'],
        List<Map<String, String>>.from(json['phrases']),
      );
}
