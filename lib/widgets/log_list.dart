import 'package:flutter/material.dart';
import '../models/log_item.dart';
import 'card_shell.dart';

class LogList extends StatelessWidget {
  final List<LogItem> logs;
  const LogList({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Text("まだ記録がありません。", style: TextStyle(color: Colors.black54));
    }
    final view = logs.take(50).toList();
    return Column(
      children: view.map((l) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CardShell(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("${l.subject} ・ ${l.minutes}分",
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      "${l.date} / ${l.subject} / ${l.minutes}分"
                      "${l.pages > 0 ? " / +${l.pages}p" : ""}"
                      "${l.memo.isNotEmpty ? " / ${l.memo}" : ""}",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ]),
                ),
                Text("+${l.pointsEarned}pt", style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
