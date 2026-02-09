class Settings {
  int goalPoint;
  int dailyCap;
  double multiplier;

  Settings({
    required this.goalPoint,
    required this.dailyCap,
    required this.multiplier,
  });

  factory Settings.defaults() => Settings(goalPoint: 1500, dailyCap: 20000, multiplier: 1.2);

  Map<String, dynamic> toJson() => {
        "goalPoint": goalPoint,
        "dailyCap": dailyCap,
        "multiplier": multiplier,
      };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        goalPoint: (json["goalPoint"] ?? 1500) as int,
        dailyCap: (json["dailyCap"] ?? 20000) as int,
        multiplier: (json["multiplier"] ?? 1.2).toDouble(),
      );
}
