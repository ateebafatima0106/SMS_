/// Notice model matching API response from GET /Notice/Get-Notices.
///
/// API returns: {noticeId, note, date, notice, isSelected}
class NoticeModel {
  final int noticeId;
  final String title; // mapped from API 'note'
  final String description; // mapped from API 'notice'
  final DateTime date;
  final bool isSelected;
  bool isNew; // calculated locally

  NoticeModel({
    this.noticeId = 0,
    required this.title,
    required this.description,
    required this.date,
    this.isSelected = false,
    this.isNew = false,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return NoticeModel(
      noticeId: (json['noticeId'] ?? 0) is int
          ? json['noticeId']
          : int.tryParse(json['noticeId'].toString()) ?? 0,
      title: (json['note'] ?? json['title'] ?? '').toString().trim(),
      description: (json['notice'] ?? json['description'] ?? '')
          .toString()
          .trim(),
      date: parsedDate,
      isSelected: json['isSelected'] ?? false,
      isNew: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeId': noticeId,
      'note': title,
      'notice': description,
      'date': date.toIso8601String(),
      'isSelected': isSelected,
    };
  }
}