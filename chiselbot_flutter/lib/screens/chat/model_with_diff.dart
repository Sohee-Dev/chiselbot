import 'package:flutter/material.dart';

class ModelWithDiff extends StatelessWidget {
  final String model;
  final String user;
  const ModelWithDiff({super.key, required this.model, required this.user});

  List<InlineSpan> _diffSpans(String a, String b) {
    final aToks = a.split(RegExp(r'\s+'));
    final bSet = b.split(RegExp(r'\s+')).toSet();
    return aToks.map<InlineSpan>((t) {
      final hit = bSet.contains(t);
      return TextSpan(
        text: '$t ',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: hit ? null : Colors.red.withOpacity(0.15),
          decoration: hit ? null : TextDecoration.underline,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('모범답안', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(text: TextSpan(children: _diffSpans(model, user))),
          const SizedBox(height: 8),
          const Text('빨간 밑줄/배경은 사용자 답변에 없는 부분입니다.',
              style: TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
      ),
    );
  }
}
