import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../data/services/pomodoro_timer_engine.dart';
import '../providers/pomodoro_providers.dart';

class PomodoroSettingsSheet extends ConsumerStatefulWidget {
  const PomodoroSettingsSheet({super.key});

  @override
  ConsumerState<PomodoroSettingsSheet> createState() =>
      _PomodoroSettingsSheetState();
}

class _PomodoroSettingsSheetState extends ConsumerState<PomodoroSettingsSheet> {
  late int _workMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late int _sessionsBeforeLongBreak;
  late bool _autoStartBreaks;
  late bool _autoStartWork;

  @override
  void initState() {
    super.initState();
    final s = ref.read(pomodoroSettingsNotifierProvider);
    _workMinutes = s.workSeconds ~/ 60;
    _shortBreakMinutes = s.shortBreakSeconds ~/ 60;
    _longBreakMinutes = s.longBreakSeconds ~/ 60;
    _sessionsBeforeLongBreak = s.sessionsBeforeLongBreak;
    _autoStartBreaks = s.autoStartBreaks;
    _autoStartWork = s.autoStartWork;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timer Settings',
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.onBackground),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.onSurfaceMuted, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDurationRow('Focus', _workMinutes, 5, 90, (v) {
              setState(() => _workMinutes = v);
            }),
            _buildDurationRow('Short Break', _shortBreakMinutes, 1, 30, (v) {
              setState(() => _shortBreakMinutes = v);
            }),
            _buildDurationRow('Long Break', _longBreakMinutes, 5, 60, (v) {
              setState(() => _longBreakMinutes = v);
            }),
            _buildStepperRow(
              'Sessions before long break',
              _sessionsBeforeLongBreak,
              min: 2,
              max: 8,
              onChanged: (v) => setState(() => _sessionsBeforeLongBreak = v),
            ),
            const SizedBox(height: 12),
            _buildToggleRow(
              'Auto-start breaks',
              _autoStartBreaks,
              (v) => setState(() => _autoStartBreaks = v),
            ),
            _buildToggleRow(
              'Auto-start work sessions',
              _autoStartWork,
              (v) => setState(() => _autoStartWork = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationRow(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label (min)',
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
            ),
          ),
          _NumericStepper(
            value: value,
            min: min,
            max: max,
            step: 1,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperRow(
    String label,
    int value, {
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
            ),
          ),
          _NumericStepper(
            value: value,
            min: min,
            max: max,
            step: 1,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  void _save() {
    final newSettings = PomodoroSettings(
      workSeconds: _workMinutes * 60,
      shortBreakSeconds: _shortBreakMinutes * 60,
      longBreakSeconds: _longBreakMinutes * 60,
      sessionsBeforeLongBreak: _sessionsBeforeLongBreak,
      autoStartBreaks: _autoStartBreaks,
      autoStartWork: _autoStartWork,
    );
    final applied =
        ref.read(pomodoroActionsProvider.notifier).applySettings(newSettings);
    if (!applied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stop the timer before changing settings.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop();
  }
}

class _NumericStepper extends StatelessWidget {
  const _NumericStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepButton(
          Icons.remove_rounded,
          value > min ? () => onChanged(value - step) : null,
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style:
                AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
          ),
        ),
        _stepButton(
          Icons.add_rounded,
          value < max ? () => onChanged(value + step) : null,
        ),
      ],
    );
  }

  Widget _stepButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.surfaceElevated
              : AppColors.surfaceElevated.withOpacity(0.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color:
              onTap != null ? AppColors.onSurface : AppColors.onSurfaceDisabled,
        ),
      ),
    );
  }
}
