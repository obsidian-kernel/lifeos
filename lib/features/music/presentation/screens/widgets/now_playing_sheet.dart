import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../data/services/audio_player_service.dart'
    show PlaybackState, TrackRepeatMode;
import '../../providers/music_providers.dart';

class NowPlayingSheet extends ConsumerWidget {
  const NowPlayingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackAsync = ref.watch(playbackStateProvider);
    final state = playbackAsync.valueOrNull;

    if (state == null || !state.hasTrack) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Nothing playing')),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return _NowPlayingContent(
          state: state,
          scrollController: scrollController,
        );
      },
    );
  }
}

class _NowPlayingContent extends ConsumerWidget {
  const _NowPlayingContent({
    required this.state,
    required this.scrollController,
  });

  final PlaybackState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = state.currentTrack!;
    final durationMs = track.durationMs;
    final positionMs = state.position.inMilliseconds;
    final sliderValue =
        durationMs > 0 ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Album art placeholder
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 64,
                color: AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 32),

            // Track info
            Text(
              track.title,
              style: AppTypography.displayMedium
                  .copyWith(color: AppColors.onBackground),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              track.displayArtist,
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
            if (track.album != null) ...[
              const SizedBox(height: 2),
              Text(
                track.displayAlbum,
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onSurfaceDisabled),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),

            // Seek bar
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.surfaceElevated,
                thumbColor: AppColors.accent,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
                trackHeight: 3,
              ),
              child: Slider(
                value: sliderValue,
                onChanged: durationMs > 0
                    ? (v) {
                        final targetMs = (v * durationMs).round();
                        ref.read(playerActionsProvider.notifier).seekTo(
                              Duration(milliseconds: targetMs),
                            );
                      }
                    : null,
              ),
            ),

            // Position labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: AppTypography.labelSmall,
                  ),
                  Text(
                    _formatDuration(track.duration),
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Shuffle
                IconButton(
                  icon: Icon(
                    Icons.shuffle_rounded,
                    color: state.shuffleEnabled
                        ? AppColors.accent
                        : AppColors.onSurfaceMuted,
                    size: 22,
                  ),
                  onPressed: () =>
                      ref.read(playerActionsProvider.notifier).toggleShuffle(),
                ),
                // Previous
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: AppColors.onSurface,
                    size: 32,
                  ),
                  onPressed: () =>
                      ref.read(playerActionsProvider.notifier).skipPrevious(),
                ),
                // Play/Pause
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => ref
                        .read(playerActionsProvider.notifier)
                        .togglePlayPause(),
                  ),
                ),
                // Next
                IconButton(
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: AppColors.onSurface,
                    size: 32,
                  ),
                  onPressed: () =>
                      ref.read(playerActionsProvider.notifier).skipNext(),
                ),
                // Repeat
                IconButton(
                  icon: Icon(
                    _repeatIcon(state.repeatMode),
                    color: state.repeatMode != TrackRepeatMode.none
                        ? AppColors.accent
                        : AppColors.onSurfaceMuted,
                    size: 22,
                  ),
                  onPressed: () => ref
                      .read(playerActionsProvider.notifier)
                      .cycleRepeatMode(),
                ),
              ],
            ),
            if (state.queue.length > 1) ...[
              const SizedBox(height: 16),
              _UpNextList(
                state: state,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  IconData _repeatIcon(TrackRepeatMode mode) {
  return switch (mode) {
    TrackRepeatMode.none => Icons.repeat_rounded,
    TrackRepeatMode.all  => Icons.repeat_rounded,
    TrackRepeatMode.one  => Icons.repeat_one_rounded,
  };
  }
}

class _UpNextList extends ConsumerWidget {
  const _UpNextList({required this.state});

  final PlaybackState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(playerActionsProvider.notifier);
    final items = state.queue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Up Next',
              style: AppTypography.titleMedium
                  .copyWith(color: AppColors.onBackground),
            ),
            Text('${items.length - 1} tracks',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onSurfaceMuted)),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length - 1,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: AppColors.border,
          ),
          itemBuilder: (_, i) {
            final index = i + 1; // skip current
            final track = items[index];
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                track.title,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onBackground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track.displayArtist,
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onSurfaceMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded,
                        color: AppColors.onSurface, size: 20),
                    onPressed: () => actions.playFromQueue(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.onSurfaceMuted, size: 18),
                    onPressed: () => actions.removeFromQueue(index),
                  ),
                ],
              ),
              onTap: () => actions.playFromQueue(index),
            );
          },
        ),
      ],
    );
  }
}
