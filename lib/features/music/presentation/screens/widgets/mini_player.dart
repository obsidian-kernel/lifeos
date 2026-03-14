import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/music_providers.dart';
import 'now_playing_sheet.dart';

/// Persistent mini-player bar shown at the bottom of the music screen
/// whenever a track is loaded. Tapping it opens the full NowPlayingSheet.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackAsync = ref.watch(playbackStateProvider);
    final state = playbackAsync.valueOrNull;

    if (state == null || !state.hasTrack) return const SizedBox.shrink();

    final track = state.currentTrack!;
    final progress = state.currentTrack != null && track.durationMs > 0
        ? (state.position.inMilliseconds / track.durationMs).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => _openNowPlaying(context),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Column(
          children: [
            // Progress bar — thin line at top of mini player
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceElevated,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 2,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildAlbumArt(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTrackInfo(track.title, track.displayArtist)),
                    _buildControls(ref, state.isPlaying),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        size: 18,
        color: AppColors.onSurfaceMuted,
      ),
    );
  }

  Widget _buildTrackInfo(String title, String artist) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          artist,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(WidgetRef ref, bool isPlaying) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded,
              color: AppColors.onSurface, size: 22),
          onPressed: () =>
              ref.read(playerActionsProvider.notifier).skipPrevious(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        IconButton(
          icon: Icon(
            isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: AppColors.accent,
            size: 28,
          ),
          onPressed: () =>
              ref.read(playerActionsProvider.notifier).togglePlayPause(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded,
              color: AppColors.onSurface, size: 22),
          onPressed: () =>
              ref.read(playerActionsProvider.notifier).skipNext(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }

  void _openNowPlaying(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const NowPlayingSheet(),
    );
  }
}
