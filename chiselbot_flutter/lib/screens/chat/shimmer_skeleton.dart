import 'package:flutter/material.dart';

class ShimmerLine extends StatefulWidget {
  final double height;
  final double radius;
  const ShimmerLine({super.key, this.height = 16, this.radius = 6});

  @override
  State<ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _c.value * 2, 0),
              end: const Alignment(1.0, 0),
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.06),
              ],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('AI 분석 중...', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            // 제목줄 굵게
            ShimmerLine(height: 18),
            SizedBox(height: 8),
            ShimmerLine(),
            SizedBox(height: 8),
            ShimmerLine(),
            SizedBox(height: 8),
            ShimmerLine(),
          ],
        ),
      ),
    );
  }
}
