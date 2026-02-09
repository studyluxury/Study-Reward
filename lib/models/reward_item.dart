class RewardItem {
  String id;
  String text;
  int cost;

  RewardItem({
    required this.id,
    required this.text,
    required this.cost,
  });

  Map<String, dynamic> toJson() => {"id": id, "text": text, "cost": cost};

  factory RewardItem.fromJson(Map<String, dynamic> json) => RewardItem(
        id: json["id"] as String,
        text: json["text"] as String,
        cost: (json["cost"] ?? 0) as int,
      );
}
