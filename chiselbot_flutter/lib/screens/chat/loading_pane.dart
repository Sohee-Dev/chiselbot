import 'dart:async';
import 'package:flutter/material.dart';

/// 로딩 UX: 최소 체류시간(진행도) + Shimmer + 느린 장문 팁 회전
class LoadingPane extends StatefulWidget {
  // 화면 하단을 채울 문장 팁들
  final List<String> tips;

  // 최소 노출 시간(진행률) — 기본 10초
  final Duration minDuration;

  // 팁 교체 주기 — 기본 3.2초(느리게)
  final Duration tipInterval;

  // 상단 카드 제목
  final String title;

  // 상단 여백 (기본 48px)
  final double topPadding;

  const LoadingPane({
    super.key,
    required this.tips,
    this.minDuration = const Duration(seconds: 10),
    this.tipInterval = const Duration(milliseconds: 3200),
    this.title = 'AI 분석 중...',
    this.topPadding = 60,
  });

  @override
  State<LoadingPane> createState() => _LoadingPaneState();
}

class _LoadingPaneState extends State<LoadingPane> {
  late final Stopwatch _watch;
  Timer? _tick;
  Timer? _tipTick;
  int _tipIndex = 0;
  double _progress = 0; // 0~1

  @override
  void initState() {
    super.initState();
    _watch = Stopwatch()..start();

    // 진행도(최소 체류시간) 갱신
    _tick = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final p =
          (_watch.elapsed.inMilliseconds / widget.minDuration.inMilliseconds)
              .clamp(0.0, 1.0);
      if (!mounted) return;
      setState(() => _progress = p);
    });

    // 긴 팁 문구 느리게 교체
    _tipTick = Timer.periodic(widget.tipInterval, (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % widget.tips.length);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _tipTick?.cancel();
    _watch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showIndeterminate = _progress >= 1.0; // 10초 지나면 무한 진행바
    final remain = (widget.minDuration.inSeconds * (1 - _progress)).ceil();

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12 + widget.topPadding, 12, 12),
      child: Column(
        children: [
          // 상단 Shimmer 카드
          _ShimmerCard(title: widget.title),
          const SizedBox(height: 12),

          // 진행도 + 남은 시간 안내
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                  value: showIndeterminate ? null : _progress),
              const SizedBox(height: 6),
              Text(
                showIndeterminate ? '조금만 더 기다려 주세요…' : '분석 준비 중… 약 ${remain}초',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ConstrainedBox(
                  key: ValueKey(_tipIndex),
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SelectableText(
                      widget.tips[_tipIndex],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 내부용 Shimmer 카드
class _ShimmerCard extends StatelessWidget {
  final String title;
  const _ShimmerCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const _ShimmerLine(height: 18),
            const SizedBox(height: 8),
            const _ShimmerLine(),
            const SizedBox(height: 8),
            const _ShimmerLine(),
            const SizedBox(height: 8),
            const _ShimmerLine(),
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  final double height;
  final double radius;
  const _ShimmerLine({this.height = 16, this.radius = 6});

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

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
