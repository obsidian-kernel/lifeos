import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/datetime_utils.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsStream = ref.watch(habitsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _openHabitEditor(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: habitsStream.when(
          data: (habits) => habits.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                  itemCount: habits.length,
                  itemBuilder: (_, i) => HabitCard(habit: habits[i]),
                ),
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent)),
          error: (_, __) => _buildError(),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.loop_outlined,
                size: 48, color: AppColors.onSurfaceDisabled),
            const SizedBox(height: 12),
            Text('No habits yet',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.onSurfaceMuted)),
            Text('Tap + to create your first habit',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceDisabled)),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Text('Failed to load habits',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onSurfaceMuted)),
      );

  Future<void> _openHabitEditor(BuildContext context, WidgetRef ref,
      {HabitEntity? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HabitEditorSheet(existing: existing),
    );
  }
}

class HabitCard extends ConsumerWidget {
  const HabitCard({super.key, required this.habit});

  final HabitEntity habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaksFuture =
        ref.watch(habitLoggerProvider.notifier).streaks(habit.id);
    return Card(
      color: AppColors.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceElevated,
          child: Text(habit.icon ?? '✅'),
        ),
        title: Text(
          habit.title,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
        ),
        subtitle: FutureBuilder(
          future: streaksFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Current streak: –',
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.onSurfaceMuted));
            }
            final res = snapshot.data!;
            return res.fold(
              onSuccess: (tuple) => Text(
                'Current: ${tuple.$1}  |  Longest: ${tuple.$2}',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onSurfaceMuted),
              ),
              onFailure: (e) => Text(
                'Streak error',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.error),
              ),
            );
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline,
                  color: AppColors.accent),
              tooltip: 'Log today',
              onPressed: () async {
                final res = await ref
                    .read(habitLoggerProvider.notifier)
                    .logToday(habit.id);
                res.fold(
                  onSuccess: (_) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged')),
                  ),
                  onFailure: (e) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: ${e.message}')),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceMuted),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      builder: (_) => HabitEditorSheet(existing: habit),
                    );
                    break;
                  case 'delete':
                    ref
                        .read(habitEditorProvider.notifier)
                        .delete(habit.id);
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HabitEditorSheet extends ConsumerStatefulWidget {
  const HabitEditorSheet({super.key, this.existing});

  final HabitEntity? existing;

  @override
  ConsumerState<HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends ConsumerState<HabitEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _target;
  late final TextEditingController _unit;
  String _frequencyType = 'daily'; // daily | weekly
  final Set<int> _weeklyDays = {1, 2, 3, 4, 5, 6, 7}; // 1=Mon ... 7=Sun

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _description =
        TextEditingController(text: widget.existing?.description ?? '');
    _target =
        TextEditingController(text: widget.existing?.targetCount.toString() ?? '1');
    _unit = TextEditingController(text: widget.existing?.unit ?? '');
    _hydrateFrequency(widget.existing?.frequencyJson);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _target.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'New Habit' : 'Edit Habit',
              style:
                  AppTypography.titleMedium.copyWith(color: AppColors.onBackground),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _title,
              style:
                  AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target count'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unit,
              decoration: const InputDecoration(labelText: 'Unit (optional)'),
            ),
            const SizedBox(height: 8),
            _buildFrequencySelector(),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final target = int.tryParse(_target.text.trim());
    final frequencyJson = _buildFrequencyJson();
    final result = await ref.read(habitEditorProvider.notifier).save(
          id: widget.existing?.id,
          title: _title.text,
          description: _description.text,
          frequencyJson: frequencyJson,
          targetCount: target ?? 1,
          unit: _unit.text.trim().isEmpty ? null : _unit.text.trim(),
          sortOrder: widget.existing?.sortOrder ?? nowUtc().millisecondsSinceEpoch.toDouble(),
          isArchived: false,
        );
    result.fold(
      onSuccess: (_) => Navigator.of(context).pop(),
      onFailure: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onBackground)),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Daily'),
              selected: _frequencyType == 'daily',
              onSelected: (_) => setState(() => _frequencyType = 'daily'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Weekly'),
              selected: _frequencyType == 'weekly',
              onSelected: (_) => setState(() => _frequencyType = 'weekly'),
            ),
          ],
        ),
        if (_frequencyType == 'weekly') ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) => i + 1).map((day) {
              const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final selected = _weeklyDays.contains(day);
              return FilterChip(
                label: Text(labels[day - 1]),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _weeklyDays.remove(day);
                    } else {
                      _weeklyDays.add(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ]
      ],
    );
  }

  void _hydrateFrequency(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return;
    try {
      final map = json.decode(jsonString);
      final type = map['type'] as String? ?? 'daily';
      _frequencyType = type;
      if (type == 'weekly' && map['days'] is List) {
        _weeklyDays
          ..clear()
          ..addAll((map['days'] as List).whereType<int>());
      }
    } catch (_) {
      // ignore malformed
    }
  }

  String _buildFrequencyJson() {
    if (_frequencyType == 'daily') {
      return jsonEncode({'type': 'daily'});
    }
    final days = _weeklyDays.isEmpty ? [1, 2, 3, 4, 5, 6, 7] : _weeklyDays.toList()..sort();
    return jsonEncode({'type': 'weekly', 'days': days});
  }
}
