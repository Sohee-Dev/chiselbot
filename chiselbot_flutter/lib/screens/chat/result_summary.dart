import 'package:flutter/material.dart';
import '../../models/api_models.dart';

class ResultSummary extends StatelessWidget {
  final CoachFeedback fb;
  const ResultSummary({super.key, required this.fb});

  @override
  Widget build(BuildContext context) {
    final verdict = (fb.similarity >= 0.8)
        ? '합격 가능'
        : (fb.similarity >= 0.6)
            ? '보완 필요'
            : '미흡';
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${(fb.similarity * 100).round()}')),
        title: Text('판정: $verdict'),
        subtitle: Text('핵심 피드백: ${fb.feedback}'),
      ),
    );
  }
}
