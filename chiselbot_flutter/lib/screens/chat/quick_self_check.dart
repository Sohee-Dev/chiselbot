import 'package:flutter/material.dart';

// 셀프 체크 카드

class QuickSelfCheck extends StatelessWidget {
  final String userAnswer;
  const QuickSelfCheck({super.key, required this.userAnswer});

  @override
  Widget build(BuildContext context) {
    final sentences = userAnswer
        .split(RegExp(r'[.!?…\n]+'))
        .where((e) => e.trim().isNotEmpty)
        .length;
    final words = RegExp(r'[A-Za-z가-힣0-9_]+').allMatches(userAnswer).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('빠른 셀프 체크',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('문장 수: $sentences개  •  어휘 수(대략): $words개'),
            const SizedBox(height: 4),
            const Text('Tip: 정의 → 단계(2~3) → 예시(1) → 마무리 순으로 답해보세요.',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
