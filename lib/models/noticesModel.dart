class NoticeModel {
  final String title;
  final String description;
  final DateTime date;
  bool isNew; // calculated locally

  NoticeModel({
    required this.title,
    required this.description,
    required this.date,
    this.isNew = false,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      title: json['notice'] ?? "No Title",
      description: json['note'] ?? "",
      date: DateTime.tryParse(json['date'] ?? "") ?? DateTime.now(),
      isNew: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notice': title,
      'note': description,
      'date': date.toIso8601String(),
      'isNew': isNew,
    };
  }
}