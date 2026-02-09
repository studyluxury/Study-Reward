import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_state.dart';
import '../models/reward_item.dart';
import '../widgets/card_shell.dart';
import '../widgets/gacha_modal.dart';

class RewardsPage extends StatefulWidget {
  final AppState state;
  final void Function(VoidCallback fn) onChanged;

  const RewardsPage({super.key, required this.state, required this.onChanged});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final goalCtrl = TextEditingController();
  final capCtrl = TextEditingController();
  final mulCtrl = TextEditingController();

  final rewardTextCtrl = TextEditingController();
  final rewardCostCtrl = TextEditingController(text: "500");

  @override
  void initState() {
    super.initState();
    goalCtrl.text = widget.state.settings.goalPoint.toString();
    capCtrl.text = widget.state.settings.dailyCap.toString();
    mulCtrl.text = widget.state.settings.multiplier.toStringAsFixed(1);
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void saveSettings() {
    widget.onChanged(() {
      widget.state.settings.goalPoint = max(0, int.tryParse(goalCtrl.text) ?? 0);
      widget.state.settings.dailyCap = max(0, int.tryParse(capCtrl.text) ?? 0);
      final m = double.tryParse(mulCtrl.text) ?? 1.2;
      widget.state.settings.multiplier = m.clamp(0.5, 3.0);
    });
    toast("設定を保存しました ✅");
  }

  void resetAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("全データ削除"),
        content: const Text("全データを削除します。よろしいですか？（元に戻せません）"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          FilledButton(
            onPressed: () {
              widget.onChanged(() {
                widget.state.points = 0;
                widget.state.logs.clear();
                widget.state.rewards.clear();
                widget.state.stamps.clear();
                widget.state.lastUndoLogId = null;
              });
              Navigator.pop(context);
              toast("全データを削除しました");
            },
            child: const Text("削除する"),
          )
        ],
      ),
    );
  }

  void addReward() {
    final text = rewardTextCtrl.text.trim();
    if (text.isEmpty) return toast("ご褒美内容を入力してね");
    final cost = max(0, int.tryParse(rewardCostCtrl.text) ?? 0);

    widget.onChanged(() {
      widget.state.rewards.add(RewardItem(id: const Uuid().v4(), text: text, cost: cost));
      rewardTextCtrl.clear();
    });
    toast("追加しました ✅");
  }

  void removeReward(String id) {
    widget.onChanged(() {
      widget.state.rewards.removeWhere((r) => r.id == id);
    });
  }

  Future<void> spinGacha() async {
    if (widget.state.rewards.isEmpty) return toast("ご褒美がまだありません");
    // 目安：各rewardのcost。払えるものだけ抽選対象
    final candidates = widget.state.rewards.where((r) => widget.state.points >= r.cost).toList();
    if (candidates.isEmpty) return toast("ポイントが足りないよ（どれも引けない）");

    final picked = candidates[Random().nextInt(candidates.length)];

    widget.onChanged(() {
      widget.state.points = (widget.state.points - picked.cost).clamp(0, 1 << 31);
    });

    await showGachaModal(
      context,
      result: picked.text,
      hint: "消費：-${picked.cost}pt ／ 残り：${widget.state.points}pt",
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.settings;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rewards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),

            CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(child: Text("ポイント設定", style: TextStyle(fontWeight: FontWeight.w900))),
                      Chip(label: Text("あなた用に調整")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: goalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "目標報酬（pt）"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: capCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "1日の獲得上限（pt）"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mulCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "倍率（おすすめ 1.2〜1.6）"),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: FilledButton(onPressed: saveSettings, child: const Text("設定を保存"))),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton(onPressed: resetAll, child: const Text("全データ削除"))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("現在：goal=${s.goalPoint} / dailyCap=${s.dailyCap} / multiplier=${s.multiplier}",
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 14),

            CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(child: Text("ご褒美（何個でもOK）", style: TextStyle(fontWeight: FontWeight.w900))),
                      Chip(label: Text("ポイントでガチャ")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rewardTextCtrl,
                    decoration: const InputDecoration(labelText: "ご褒美内容", hintText: "例：カフェ／ピアノ／YouTube 30分"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rewardCostCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "必要ポイント（引く時の目安）"),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: FilledButton(onPressed: addReward, child: const Text("追加"))),
                      const SizedBox(width: 10),
                      Expanded(child: FilledButton(onPressed: spinGacha, child: const Text("ガチャを回す"))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.state.rewards.isEmpty)
                    const Text("まだご褒美がありません。", style: TextStyle(color: Colors.black54))
                  else
                    Column(
                      children: widget.state.rewards.map((r) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.text, style: const TextStyle(fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 2),
                                      Text("目安：${r.cost}pt", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => removeReward(r.id),
                                  icon: const Icon(Icons.delete_outline),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
