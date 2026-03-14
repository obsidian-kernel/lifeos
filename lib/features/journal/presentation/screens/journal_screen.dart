import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/journal_entry.dart';
import '../providers/journal_providers.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.edit_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: entriesAsync.when(
                data: (entries) => entries.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 88, left: 12, right: 12),
                        itemCount: entries.length,
                        itemBuilder: (_, i) =>
                            _JournalCard(entry: entries[i], onTap: () {
                          _openEditor(context, existing: entries[i]);
                        }),
                      ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (_, __) => _buildError(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              style:
                  AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
              decoration: InputDecoration(
                hintText: 'Search journal...',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceMuted),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.onSurfaceMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (q) =>
                  ref.read(journalSearchQueryProvider.notifier).set(q),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.onSurfaceMuted),
            onPressed: () {
              _search.clear();
              ref.read(journalSearchQueryProvider.notifier).clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.book_outlined,
              size: 48, color: AppColors.onSurfaceDisabled),
          const SizedBox(height: 12),
          Text(
            'No entries yet',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the pen to write your first entry.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onSurfaceDisabled),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        'Failed to load entries',
        style:
            AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceMuted),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context,
      {JournalEntryEntity? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) =>
          JournalEditorSheet(existing: existing, parentContext: context),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry, required this.onTap});

  final JournalEntryEntity entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final moodIcon = _moodIcon(entry.mood);
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceElevated,
          child: Text(
            moodIcon ?? '✎',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(
          entry.title ?? 'Untitled',
          style:
              AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatDate(entry.entryDate),
          style:
              AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted),
        ),
        trailing: entry.isPinned
            ? const Icon(Icons.push_pin, color: AppColors.accent, size: 18)
            : null,
      ),
    );
  }

  String? _moodIcon(int? mood) => switch (mood) {
        5 => '😁',
        4 => '🙂',
        3 => '😐',
        2 => '😕',
        1 => '😟',
        _ => null,
      };

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class JournalEditorSheet extends ConsumerStatefulWidget {
  const JournalEditorSheet({super.key, this.existing, required this.parentContext});

  final JournalEntryEntity? existing;
  final BuildContext parentContext;

  @override
  ConsumerState<JournalEditorSheet> createState() => _JournalEditorSheetState();
}

class _JournalEditorSheetState extends ConsumerState<JournalEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _tags;
  int? _mood;
  bool _preview = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _body = TextEditingController(text: widget.existing?.body ?? '');
    _tags = TextEditingController(
        text: widget.existing?.tags.join(', ') ?? '');
    _mood = widget.existing?.mood;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _tags.dispose();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existing == null ? 'New Entry' : 'Edit Entry',
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.onBackground),
                ),
                IconButton(
                  icon: Icon(
                    _preview ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.onSurfaceMuted,
                  ),
                  onPressed: () => setState(() => _preview = !_preview),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _title,
              style:
                  AppTypography.bodyLarge.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(
                hintText: 'Title (optional)',
              ),
            ),
            const SizedBox(height: 12),
            _MoodSelector(
              selected: _mood,
              onSelected: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 12),
            if (_preview)
              Container(
                constraints: const BoxConstraints(minHeight: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MarkdownBody(
                  data: _body.text,
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: AppTypography.bodyMedium
                        .copyWith(color: AppColors.onBackground),
                  ),
                ),
              )
            else
              TextField(
                controller: _body,
                minLines: 10,
                maxLines: null,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onBackground),
                decoration: const InputDecoration(
                  hintText: 'Start writing in Markdown...',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _tags,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(
                hintText: 'Tags (comma separated)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                ),
                const SizedBox(width: 12),
                if (widget.existing != null)
                  TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final tags = _tags.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final result = await ref.read(journalEditorProvider.notifier).save(
          id: widget.existing?.id,
          title: _title.text,
          body: _body.text,
          mood: _mood,
          tags: tags,
          entryDate: widget.existing?.entryDate,
          createdAt: widget.existing?.createdAt,
          isPinned: widget.existing?.isPinned ?? false,
        );
    result.fold(
      onSuccess: (_) {
        if (widget.parentContext.mounted) {
          Navigator.of(widget.parentContext).pop();
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            const SnackBar(content: Text('Saved')),
          );
        }
      },
      onFailure: (e) => _showError(e.message),
    );
  }

  Future<void> _delete() async {
    if (widget.existing == null) return;
    final result =
        await ref.read(journalEditorProvider.notifier).delete(widget.existing!.id);
    result.fold(
      onSuccess: (_) {
        if (widget.parentContext.mounted) {
          Navigator.of(widget.parentContext).pop();
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            const SnackBar(content: Text('Deleted')),
          );
        }
      },
      onFailure: (e) => _showError(e.message),
    );
  }

  void _showError(String msg) {
    if (!widget.parentContext.mounted) return;
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    const moods = [
      (1, '😟'),
      (2, '😕'),
      (3, '😐'),
      (4, '🙂'),
      (5, '😁'),
    ];
    return Row(
      children: [
        Text('Mood:', style: AppTypography.bodyMedium.copyWith(
          color: AppColors.onBackground,
        )),
        const SizedBox(width: 8),
        Wrap(
          spacing: 8,
          children: moods
              .map((m) => ChoiceChip(
                    label: Text(m.$2),
                    selected: selected == m.$1,
                    onSelected: (_) => onSelected(m.$1),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
