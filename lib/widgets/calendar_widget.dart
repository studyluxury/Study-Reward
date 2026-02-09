import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stamp.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime viewDate;
  final Map<String, Stamp> monthStamps; // ymd -> stamp
  final void Function(DateTime day)? onTapDay;

  const CalendarWidget({
    super.key,
    required this.viewDate,
    required this.monthStamps,
    this.onTapDay,
  });

  static String ymd(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

  Color stampColor(String id) {
    switch (id) {
      case "p1":
        return const Color(0xFFB6D5FF);
      case "p2":
        return const Color(0xFFFFD6E7);
      case "p3":
        return const Color(0xFFD8FFE8);
      case "p4":
        return const Color(0xFFFFF2B6);
      case "p5":
        return const Color(0xFFE6D7FF);
      default:
        return const Color(0xFFB6D5FF);
    }
  }

  BorderRadius shapeRadius(String shape) {
    switch (shape) {
      case "round":
        return BorderRadius.circular(999);
      case "squircle":
        return BorderRadius.circular(12);
      case "diamond":
        return BorderRadius.circular(10);
      default:
        return BorderRadius.circular(12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final y = viewDate.year;
    final m0 = viewDate.month - 1;
    final first = DateTime(y, m0 + 1, 1);
    final startDow = first.weekday % 7; // Sun=0
    final start = first.subtract(Duration(days: startDow));

    final days = List.generate(42, (i) => start.add(Duration(days: i)));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, i) {
        final d = days[i];
        final isOther = d.month != (m0 + 1);
        final key = ymd(d);
        final stamp = monthStamps[key];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapDay == null ? null : () => onTapDay!(d),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Opacity(
              opacity: isOther ? 0.45 : 1,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text("${d.day}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black54)),
                  ),
                  if (stamp != null)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Transform.rotate(
                        angle: stamp.shape == "diamond" ? 0.785398 /*45deg*/ : 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: stampColor(stamp.color),
                            borderRadius: stamp.shape == "star" ? null : shapeRadius(stamp.shape),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                                color: Colors.black.withValues(alpha: 0.08),
                              )
                            ],
                          ),
                          child: Transform.rotate(
                            angle: stamp.shape == "diamond" ? -0.785398 : 0,
                            child: const Text("✓", style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
