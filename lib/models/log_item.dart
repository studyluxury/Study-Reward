class LogItem {
  String id;
  String date; // YYYY-MM-DD
  String subject;
  int minutes;
  int pages;
  String memo;
  int pointsEarned;

  LogItem({
    required this.id,
    required this.date,
    required this.subject,
    required this.minutes,
    required this.pages,
    required this.memo,
    required this.pointsEarned,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "subject": subject,
        "minutes": minutes,
        "pages": pages,
        "memo": memo,
        "pointsEarned": pointsEarned,
      };

  factory LogItem.fromJson(Map<String, dynamic> json) => LogItem(
        id: json["id"] as String,
        date: json["date"] as String,
        subject: json["subject"] as String,
        minutes: (json["minutes"] ?? 0) as int,
        pages: (json["pages"] ?? 0) as int,
        memo: (json["memo"] ?? "") as String,
        pointsEarned: (json["pointsEarned"] ?? 0) as int,
      );
}
