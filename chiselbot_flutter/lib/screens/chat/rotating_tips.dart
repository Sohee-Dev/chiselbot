import 'package:flutter/material.dart';

//로딩 중 애니메이션

class RotatingTips extends StatefulWidget {
  final List<String> messages;
  const RotatingTips({super.key, required this.messages});

  @override
  State<RotatingTips> createState() => _RotatingTipsState();
}

class _RotatingTipsState extends State<RotatingTips> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => index = (index + 1) % widget.messages.length);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 8),
          Text(widget.messages[index]),
        ],
      );
}
