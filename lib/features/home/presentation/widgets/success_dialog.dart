import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 만원 챌린지 성공 시 표시하는 축하 다이얼로그 (U-21 ~ U-22)
///
/// 사용 예시:
/// ```dart
/// showSuccessDialog(context, remainingAmount: 4800, acornCount: 2, streakDays: 7);
/// ```
void showSuccessDialog(
  BuildContext context, {
  required int remainingAmount,
  required int acornCount,
  required int streakDays,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: false,
    builder: (_) => _SuccessDialog(
      remainingAmount: remainingAmount,
      acornCount: acornCount,
      streakDays: streakDays,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 다이얼로그 본체
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  final int remainingAmount;
  final int acornCount;
  final int streakDays;

  const _SuccessDialog({
    required this.remainingAmount,
    required this.acornCount,
    required this.streakDays,
  });

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    // confetti 파티클 애니메이션 컨트롤러 (3초 후 자동 종료)
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // confetti 파티클 레이어 (다이얼로그 뒤에 렌더링)
        _ConfettiLayer(controller: _confettiController),

        // 다이얼로그 카드
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // X 닫기 버튼 (오른쪽 상단)
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextSub
                            : AppColors.textSub,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 🎉 이모지
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 56),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 16),

                  // 타이틀
                  Text(
                    '만원 챌린지 성공!',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextMain
                          : AppColors.textMain,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 300.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  // 절약 금액 메시지
                  Text(
                    '오늘 ${CurrencyFormatter.formatWithWon(widget.remainingAmount)}을 남겼어요!',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSub
                          : AppColors.textSub,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 300.ms),

                  const SizedBox(height: 24),

                  // 도토리 획득 항목
                  _RewardRow(
                    emoji: '🌰',
                    label: '도토리 획득',
                    value: '+${widget.acornCount}',
                    delay: 400.ms,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // 연속 성공 항목
                  _RewardRow(
                    emoji: '🔥',
                    label: '연속 성공',
                    value: '${widget.streakDays}일째',
                    delay: 500.ms,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 28),

                  // 확인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.darkTextMain : AppColors.textMain,
                        foregroundColor:
                            isDark ? AppColors.darkBackground : AppColors.card,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '확인',
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.card,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 300.ms)
                      .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 350.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 300.ms),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 보상 행 위젯
// ─────────────────────────────────────────────────────────────────────────────

class _RewardRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Duration delay;
  final bool isDark;

  const _RewardRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.delay,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextMain : AppColors.textMain,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay, duration: 300.ms).slideX(begin: -0.1, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confetti 파티클 레이어 (U-22)
// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiLayer extends StatelessWidget {
  final AnimationController controller;

  const _ConfettiLayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => CustomPaint(
        painter: _ConfettiPainter(progress: controller.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

/// confetti 파티클을 그리는 CustomPainter
/// 여러 색상의 작은 원/사각형이 위에서 아래로 떨어지며 3초 후 페이드아웃된다
class _ConfettiPainter extends CustomPainter {
  final double progress;

  // 파티클 색상 팔레트
  static const _colors = [
    AppColors.primary,
    AppColors.statusComfortable,
    AppColors.statusWarning,
    AppColors.categoryFood,
    AppColors.categoryTransport,
    AppColors.categoryShopping,
    Color(0xFFFFE66D),
    Color(0xFFFF6B6B),
  ];

  // 파티클 고정 설정값 (seed 기반으로 위치/크기/색상 결정)
  static const int _particleCount = 60;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // 고정 seed로 매 프레임 동일한 파티클 배치 유지

    // 3초 후 서서히 사라지는 alpha (마지막 0.5초 동안 fade)
    final opacity = progress < 0.8 ? 1.0 : (1.0 - progress) / 0.2;

    for (int i = 0; i < _particleCount; i++) {
      final color = _colors[i % _colors.length];
      final x = rng.nextDouble() * size.width;
      // 시간 경과에 따라 아래로 이동 (각 파티클마다 속도 다름)
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final y = -30 + (size.height + 60) * (progress * speed);
      final particleSize = 4.0 + rng.nextDouble() * 6.0;
      // 파티클 흔들림 효과 (sin 파형)
      final sway = math.sin(progress * math.pi * 4 + i) * 20;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      // 짝수 파티클 → 원형, 홀수 파티클 → 사각형
      if (i % 2 == 0) {
        canvas.drawCircle(
          Offset(x + sway, y),
          particleSize / 2,
          paint,
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x + sway, y),
            width: particleSize,
            height: particleSize * 0.6,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
