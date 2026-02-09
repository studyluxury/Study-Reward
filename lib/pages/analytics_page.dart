import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/app_state.dart';
import '../widgets/card_shell.dart';

class AnalyticsPage extends StatefulWidget {
  final AppState state;
  const AnalyticsPage({super.key, required this.state});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int rangeDays = 7;

  DateTime parseYmd(String s) => DateFormat("yyyy-MM-dd").parse(s);
  String ymd(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day).subtract(Duration(days: rangeDays - 1));

    final logs = widget.state.logs.where((l) {
      final d = parseYmd(l.date);
      return !d.isBefore(from) && !d.isAfter(now);
    }).toList();

    final totalMin = logs.fold<int>(0, (a, b) => a + b.minutes);
    final totalPt = logs.fold<int>(0, (a, b) => a + b.pointsEarned);
    final avgMin = rangeDays == 0 ? 0 : (totalMin / rangeDays).round();

    // by day
    final dayMap = <String, int>{};
    for (int i = 0; i < rangeDays; i++) {
      final d = DateTime(from.year, from.month, from.day).add(Duration(days: i));
      dayMap[ymd(d)] = 0;
    }
    for (final l in logs) {
      dayMap[l.date] = (dayMap[l.date] ?? 0) + l.minutes;
    }

    // by subject
    final subjMap = <String, int>{};
    for (final l in logs) {
      subjMap[l.subject] = (subjMap[l.subject] ?? 0) + l.minutes;
    }
    final topSubject = subjMap.entries.isEmpty
        ? "-"
        : (subjMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;

    final days = dayMap.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      spots.add(FlSpot(i.toDouble(), dayMap[days[i]]!.toDouble()));
    }

    final bars = subjMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topBars = bars.take(8).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: Text("分析", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text("直近7日")),
                  ButtonSegment(value: 30, label: Text("直近30日")),
                ],
                selected: {rangeDays},
                onSelectionChanged: (s) => setState(() => rangeDays = s.first),
              ),
            ]),
            const SizedBox(height: 14),

            CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Stat(name: "合計（分）", val: "$totalMin"),
                      _Stat(name: "合計（pt）", val: "$totalPt"),
                      _Stat(name: "平均（分/日）", val: "$avgMin"),
                      _Stat(name: "最多科目", val: topSubject),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text("勉強時間（推移）", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: rangeDays <= 7 ? 1 : 5,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                                final d = DateFormat("MM/dd").format(DateFormat("yyyy-MM-dd").parse(days[i]));
                                return Text(d, style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            dotData: const FlDotData(show: false),
                            barWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("科目別合計（分）", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= topBars.length) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(topBars[i].key, style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: [
                          for (int i = 0; i < topBars.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(toY: topBars[i].value.toDouble(), width: 18),
                              ],
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String name;
  final String val;
  const _Stat({required this.name, required this.val});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.sizeOf(context).width - 14 * 2 - 10) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}
