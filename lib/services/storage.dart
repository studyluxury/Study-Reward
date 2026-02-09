import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state.dart';

class Storage {
  static const key = "study_reward_v2_flutter";

  static Future<AppState?> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppState.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(AppState state) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(state.toJson()));
  }
}
