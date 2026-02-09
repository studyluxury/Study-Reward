import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/app_state.dart';
import '../models/log_item.dart';
import '../models/stamp.dart';
import '../widgets/card_shell.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/log_list.dart';

class HomePage extends StatefulWidget {
  final AppState state;
  final void Function(VoidCallback fn) onChanged;

  const HomePage({super.key, required this.state, required this.onChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const subjects = [
    "簿記1級","FP2級","FP1級","簿記論","財務諸表論","基本情報","大学院勉強","投資","応用情報","TOEIC"
  ];
  static const minutesList = [25,30,45,60,75,90,120,180,240];
  static const pageSteps = [0, 1, 5, 10, 50, 100];

  static const stampShapes = [
    ("round", "まる"),
    ("squircle", "角丸"),
    ("diamond", "ひし形"),
    ("star", "スター"),
  ];
  static const stampColors = [
    ("p1", "パステルブルー"),
    ("p2", "パステルピンク"),
    ("p3", "ミント"),
    ("p4", "レモン"),
    ("p5", "ラベンダー"),
  ];

  final memoCtrl = TextEditingController();

  String subject = subjects.first;
  int minutes = minutesList.first;
  int pages = 0;

  String stampShape = "round";
  String stampColor = "p1";

  DateTime viewDate = DateTime.now();

  String todayKey([DateTime? d]) => DateFormat("yyyy-MM-dd").format(d ?? DateTime.now());
  String monthKey(DateTime d) => DateFormat("yyyy-MM").format(d);

  int computeEarnedPoints(int minutes, int pages) {
    final base = (minutes * 10 * widget.state.settings.multiplier).round();
    final pageBonus = pages > 0 ? (pages * 8).round() : 0;
    return base + pageBonus;
  }

  int todayEarnedTotal() {
    final t = todayKey();
    return widget.state.logs.where((l) => l.date == t).fold<int>(0, (a, b) => a + b.pointsEarned);
  }

  ({int added, int blocked}) addPointsSafely(int pts) {
    final cap = widget.state.settings.dailyCap;
    final already = todayEarnedTotal();
    final allowed = (cap - already).clamp(0, cap);
    final add = pts > allowed ? allowed : pts;

    widget.state.points += add;
    return (added: add, blocked: pts - add);
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void saveLog() {
    final earned = computeEarnedPoints(minutes, pages);
    widget.onChanged(() {
      final r = addPointsSafely(earned);

      final log = LogItem(
        id: const Uuid().v4(),
        date: todayKey(),
        subject: subject,
        minutes: minutes,
        pages: pages,
        memo: memoCtrl.text.trim(),
        pointsEarned: r.added,
      );
      widget.state.logs.insert(0, log);
      if (widget.state.logs.length > 2000) {
        widget.state.logs = widget.state.logs.take(2000).toList();
      }
      widget.state.lastUndoLogId = log.id;

      memoCtrl.clear();
      pages = 0;
    });

    final blocked = (earned - widget.state.logs.first.pointsEarned);
    if (blocked > 0) toast("記録OK！ +${widget.state.logs.first.pointsEarned}pt（上限で ${blocked}pt は加算なし）");
    else toast("記録OK！ +${widget.state.logs.first.pointsEarned}pt");
  }

  void undo() {
    final id = widget.state.lastUndoLogId;
    if (id == null) return toast("取り消せる記録がありません");

    widget.onChanged(() {
      final idx = widget.state.logs.indexWhere((l) => l.id == id);
      if (idx >= 0) {
        final pts = widget.state.logs[idx].pointsEarned;
        widget.state.points = (widget.state.points - pts).clamp(0, 1 << 31);
        widget.state.logs.removeAt(idx);
      }
      widget.state.lastUndoLogId = null;
    });
    toast("直前の記録を取り消しました");
  }

  void manualAdd(int pts) {
    widget.onChanged(() {
      final r = addPointsSafely(pts);
      widget.state.lastUndoLogId = null;
      if (r.blocked > 0) toast("+${r.added}pt（上限で ${r.blocked}pt は加算なし）");
      else toast("+${r.added}pt");
    });
  }

  void stampToday() {
    final ymd = todayKey();
    final ym = monthKey(viewDate);

    widget.onChanged(() {
      widget.state.stamps.putIfAbsent(ym, () => {});
      widget.state.stamps[ym]![ymd] = Stamp(shape: stampShape, color: stampColor);
    });
    toast("今日にスタンプしました ✓");
  }

  void clearMonth() {
    final ym = monthKey(viewDate);
    widget.onChanged(() {
      widget.state.stamps.remove(ym);
    });
    toast("今月のスタンプを削除しました");
  }

  @override
  Widget build(BuildContext context) {
    final bg = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F7FF), Color(0xFFFFF8FB)],
        ),
      ),
    );

    final ym = monthKey(viewDate);
    final monthStamps = widget.state.stamps[ym] ?? {};

    return Stack(
      children: [
        bg,
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [Color(0xFFB6D5FF), Color(0xFFFFD6E7)]),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                      ),
                      alignment: Alignment.center,
                      child: const Text("SR", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Study Reward", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          SizedBox(height: 2),
                          Text("記録 → ポイント → ご褒美（ガチャ）", style: TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("所持ポイント", style: TextStyle(color: Colors.black54, fontSize: 12)),
                        Text("${widget.state.points}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2 cards grid -> mobile: stacked
                CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Expanded(child: Text("今日の勉強を記録", style: TextStyle(fontWeight: FontWeight.w900))),
                          Chip(label: Text("入力は全部プルダウンOK")),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: subject,
                        decoration: const InputDecoration(labelText: "科目"),
                        items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => subject = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: minutes,
                        decoration: const InputDecoration(labelText: "勉強時間（分）"),
                        items: minutesList.map((m) => DropdownMenuItem(value: m, child: Text("${m}分"))).toList(),
                        onChanged: (v) => setState(() => minutes = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: pages,
                        decoration: const InputDecoration(labelText: "ページ数（任意）"),
                        items: pageSteps.map((p) {
                          if (p == 0) return const DropdownMenuItem(value: 0, child: Text("なし"));
                          return DropdownMenuItem(value: p, child: Text("+$p"));
                        }).toList(),
                        onChanged: (v) => setState(() => pages = v ?? 0),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: memoCtrl,
                        decoration: const InputDecoration(labelText: "メモ（任意）", hintText: "例：第3章 過去問／復習"),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton(onPressed: () => manualAdd(25), child: const Text("+25pt")),
                          OutlinedButton(onPressed: () => manualAdd(50), child: const Text("+50pt")),
                          OutlinedButton(onPressed: () => manualAdd(100), child: const Text("+100pt")),
                          const Text("手動加点（気分が乗った日用）", style: TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: saveLog,
                              child: const Text("記録してポイント加算"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: undo,
                              child: const Text("直前の記録を取り消し"),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(colors: [
                            const Color(0xFFB6D5FF).withValues(alpha: 0.35),
                            const Color(0xFFFFD6E7).withValues(alpha: 0.35),
                          ]),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("今日のスタンプ", style: TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            const Text("好きな形＆色を選んで「今日にスタンプ」",
                                style: TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: stampShape,
                                    decoration: const InputDecoration(labelText: "形"),
                                    items: stampShapes
                                        .map((s) => DropdownMenuItem(value: s.$1, child: Text(s.$2)))
                                        .toList(),
                                    onChanged: (v) => setState(() => stampShape = v!),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: stampColor,
                                    decoration: const InputDecoration(labelText: "色"),
                                    items: stampColors
                                        .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                                        .toList(),
                                    onChanged: (v) => setState(() => stampColor = v!),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Expanded(child: Text("達成カレンダー", style: TextStyle(fontWeight: FontWeight.w900))),
                        Chip(label: Text(DateFormat("yyyy-MM").format(viewDate))),
                      ]),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => viewDate = DateTime(viewDate.year, viewDate.month - 1, 1)),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: Center(
                              child: Text("${viewDate.year}年${viewDate.month}月",
                                  style: const TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => viewDate = DateTime(viewDate.year, viewDate.month + 1, 1)),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CalendarWidget(viewDate: viewDate, monthStamps: monthStamps),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: FilledButton(onPressed: stampToday, child: const Text("今日にスタンプ"))),
                          const SizedBox(width: 10),
                          Expanded(child: OutlinedButton(onPressed: clearMonth, child: const Text("今月のスタンプ削除"))),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                const Text("履歴（最新50件）", style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                LogList(logs: widget.state.logs),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
