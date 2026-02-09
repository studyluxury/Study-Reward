import 'package:flutter/material.dart';

Future<void> showGachaModal(BuildContext context, {required String result, required String hint}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🎁 ガチャ結果", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: [
                Colors.greenAccent.withValues(alpha: 0.4),
                Colors.amberAccent.withValues(alpha: 0.4),
              ]),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Text(result, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ),
          const SizedBox(height: 10),
          Text(hint, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
