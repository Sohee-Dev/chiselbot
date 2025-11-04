import '../chat/quick_self_check.dart';
import '../chat/rotating_tips.dart';
import 'package:flutter/material.dart';
import '../../providers/app_providers.dart';
import '../../providers/qna_provider.dart';
import '../../widgets/message_bubble.dart';
import 'hint_panel.dart';
import 'model_with_diff.dart';
import 'result_summary.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  late QnaProvider qna;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    qna = AppProviders.of(context).qna;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<String> _splitForTyping(String text) {
    return text
        .split(RegExp(r'(?<=[.!?…\n])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 면접 코치')),
      body: AnimatedBuilder(
        animation: qna,
        builder: (context, _) {
          if (qna.currentQuestion == null) {
            return const Center(child: Text('질문이 없습니다. 메인에서 시작하세요.'));
          }
          final q = qna.currentQuestion!;
          final segments =
              _splitForTyping("[${q.categoryName}] ${q.questionText}");

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // 질문 말풍선(타자 효과)
                      MessageBubble(
                        isUser: false,
                        animatedSegments: qna.typingDone ? null : segments,
                        text: qna.typingDone
                            ? "[${q.categoryName}] ${q.questionText}"
                            : null,
                        onCompleted: () => qna.markTypingDone(),
                      ),
                      const SizedBox(height: 12),

                      // 입력창
                      TextField(
                        controller: _ctrl,
                        maxLines: 5,
                        enabled: qna.typingDone && !qna.loading,
                        decoration: const InputDecoration(
                          hintText: '답변을 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 액션 버튼
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: (!qna.typingDone || qna.loading)
                                  ? null
                                  : () async {
                                      await qna.submitAnswer(_ctrl.text.trim());
                                      if (qna.error != null && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('코칭 실패: ${qna.error}')),
                                        );
                                      }
                                    },
                              child: Text(qna.loading ? '분석 중…' : '코칭 받기'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: qna.loading ? null : qna.revealHint,
                              child: const Text('힌트 보기'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 다음 문제
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.skip_next),
                              label: const Text('다음 문제'),
                              onPressed: qna.loading
                                  ? null
                                  : () async {
                                      final cur = qna.currentQuestion;
                                      if (cur == null) return;

                                      // 현재와 동일한 카테고리/레벨로 새 질문 요청
                                      await qna.loadQuestion(
                                        categoryId: cur.categoryId,
                                        level: cur.interviewLevel, // "LEVEL_1"
                                      );

                                      _ctrl.clear(); // 입력창 초기화

                                      if (qna.error != null && mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '다음 문제 불러오기 실패: ${qna.error}')),
                                        );
                                      } else if (mounted) {
                                        // (선택) 같은 문제가 나올 수 있다는 안내
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('같은 문제가 나올 수 있습니다.')),
                                        );
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 로딩 중 표시 (셔머 스켈레톤 + 단계 메시지)
                      if (qna.loading) ...[
                        const _ShimmerCard(),
                        const SizedBox(height: 8),
                        const RotatingTips(
                          messages: [
                            '의도 분석 중...',
                            '핵심 키워드 추출 중...',
                            '구조 점검 중...',
                            '점수 계산 중...',
                          ],
                        ),
                      ],

                      // 결과 (피드백, 막대) — 시도 1회 정책: Diff 미표시
                      if (qna.lastFeedback != null && !qna.loading) ...[
                        ResultSummary(fb: qna.lastFeedback!),
                        const SizedBox(height: 8),
                        //  막대바(의도/키워드/구조) 제거
                        // SimilarityBars(fb: qna.lastFeedback!),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed:
                                (qna.lastFeedback?.questionAnswer != null)
                                    ? qna.toggleModelVisible
                                    : null,
                            icon: Icon(qna.modelVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            label:
                                Text(qna.modelVisible ? '모범답안 숨기기' : '모범답안 보기'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (qna.modelVisible &&
                            qna.lastFeedback?.questionAnswer != null)
                          ModelWithDiff(
                            model: qna.lastFeedback!.questionAnswer!,
                            user: qna.lastFeedback!.userAnswer,
                          ),

                        const SizedBox(height: 12),
                      ],

                      // 힌트(키워드 공개)
                      if (qna.hintVisible)
                        HintPanel(
                          fb: qna.lastFeedback,
                          question: qna.currentQuestion,
                          extraStep: qna.extraHintIndex,
                          onMore: qna.revealExtraHint,
                        ),

                      // 시도 전 빠른 셀프체크
                      if (!qna.loading &&
                          qna.lastFeedback == null &&
                          _ctrl.text.trim().isNotEmpty)
                        QuickSelfCheck(userAnswer: _ctrl.text),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 스켈레톤 카드 (로딩 상태용)
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

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
            _ShimmerLine(height: 18),
            SizedBox(height: 8),
            _ShimmerLine(),
            SizedBox(height: 8),
            _ShimmerLine(),
            SizedBox(height: 8),
            _ShimmerLine(),
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
