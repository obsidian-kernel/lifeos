import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/track_entity.dart';
import '../../providers/music_providers.dart';

class TrackListItem extends ConsumerWidget {
  const TrackListItem({
    super.key,
    required this.track,
    required this.allTracks,
    required this.indexInList,
  });

  final TrackEntity track;
  final List<TrackEntity> allTracks;
  final int indexInList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackAsync = ref.watch(playbackStateProvider);
    final isCurrentTrack = playbackAsync.valueOrNull?.currentTrack?.id == track.id;
    final isPlaying = isCurrentTrack &&
        (playbackAsync.valueOrNull?.isPlaying ?? false);

    return InkWell(
      onTap: () {
        ref
            .read(playerActionsProvider.notifier)
            .playQueue(allTracks, startIndex: indexInList);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isCurrentTrack
            ? AppColors.accentMuted
            : Colors.transparent,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildLeading(isCurrentTrack, isPlaying),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
            _buildDuration(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(bool isCurrent, bool isPlaying) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: isCurrent
              ? Icon(
                  isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.pause_rounded,
                  size: 18,
                  color: AppColors.accent,
                )
              : Icon(
                  Icons.music_note_rounded,
                  size: 16,
                  color: AppColors.onSurfaceMuted,
                ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          track.title,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.onBackground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (track.artist != null) ...[
          const SizedBox(height: 2),
          Text(
            track.displayArtist,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildDuration() {
    final d = track.duration;
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.onSurfaceMuted,
      ),
    );
  }
}