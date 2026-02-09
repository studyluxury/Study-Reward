import 'log_item.dart';
import 'reward_item.dart';
import 'settings.dart';
import 'stamp.dart';

class AppState {
  int points;
  Settings settings;
  List<LogItem> logs;
  List<RewardItem> rewards;

  /// stamps["YYYY-MM"]["YYYY-MM-DD"] = Stamp
  Map<String, Map<String, Stamp>> stamps;

  /// lastUndo = last logged item id (simple)
  String? lastUndoLogId;

  AppState({
    required this.points,
    required this.settings,
    required this.logs,
    required this.rewards,
    required this.stamps,
    required this.lastUndoLogId,
  });

  factory AppState.defaults() => AppState(
        points: 0,
        settings: Settings.defaults(),
        logs: [],
        rewards: [],
        stamps: {},
        lastUndoLogId: null,
      );

  Map<String, dynamic> toJson() => {
        "points": points,
        "settings": settings.toJson(),
        "logs": logs.map((e) => e.toJson()).toList(),
        "rewards": rewards.map((e) => e.toJson()).toList(),
        "stamps": stamps.map((ym, days) => MapEntry(
              ym,
              days.map((ymd, st) => MapEntry(ymd, st.toJson())),
            )),
        "lastUndoLogId": lastUndoLogId,
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    final settings = Settings.fromJson((json["settings"] ?? {}) as Map<String, dynamic>);

    final logs = ((json["logs"] ?? []) as List)
        .map((e) => LogItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final rewards = ((json["rewards"] ?? []) as List)
        .map((e) => RewardItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawStamps = (json["stamps"] ?? {}) as Map<String, dynamic>;
    final stamps = <String, Map<String, Stamp>>{};
    for (final ym in rawStamps.keys) {
      final days = (rawStamps[ym] as Map<String, dynamic>);
      stamps[ym] = days.map((ymd, st) => MapEntry(ymd, Stamp.fromJson(st as Map<String, dynamic>)));
    }

    return AppState(
      points: (json["points"] ?? 0) as int,
      settings: settings,
      logs: logs,
      rewards: rewards,
      stamps: stamps,
      lastUndoLogId: (json["lastUndoLogId"] as String?),
    );
  }
}
