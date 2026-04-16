import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/pomodoro_entity.dart';

/// Animated circular progress ring showing timer countdown.
/// Uses a custom painter for pixel-perfect arc rendering.
class PomodoroRing extends StatelessWidget {
  const PomodoroRing({super.key, required this.timerState});

  final PomodoroTimerState timerState;

  @override
  Widget build(BuildContext context) {
    final ringColor = _ringColor(timerState.sessionType);

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring track
          SizedBox.expand(
            child: CustomPaint(
              painter: _RingPainter(
                progress: 1.0,
                color: AppColors.surfaceElevated,
                strokeWidth: 10,
              ),
            ),
          ),
          // Animated progress arc
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: timerState.progress,
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, value, __) => CustomPaint(
                painter: _RingPainter(
                  progress: value,
                  color: ringColor,
                  strokeWidth: 10,
                ),
              ),
            ),
          ),
          // Timer text in center
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timerState.formattedTime,
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 52,
                  fontWeight: FontWeight.w300,
                  color: AppColors.onBackground,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusLabel(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel() {
    final (label, color) = switch (timerState.status) {
      PomodoroTimerStatus.running => ('Running', AppColors.success),
      PomodoroTimerStatus.paused => ('Paused', AppColors.warning),
      PomodoroTimerStatus.finished => ('Done!', AppColors.success),
      PomodoroTimerStatus.idle => ('Ready', AppColors.onSurfaceDisabled),
    };

    return Text(
      label,
      style: AppTypography.labelSmall.copyWith(color: color),
    );
  }

  Color _ringColor(PomodoroSessionType type) => switch (type) {
        PomodoroSessionType.work => AppColors.accent,
        PomodoroSessionType.shortBreak => AppColors.success,
        PomodoroSessionType.longBreak => AppColors.warning,
      };
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start at top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
