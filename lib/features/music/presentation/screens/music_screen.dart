import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/track_entity.dart';
import '../providers/music_providers.dart';
import 'widgets/mini_player.dart';
import 'widgets/track_list_item.dart';

class MusicScreen extends ConsumerWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(child: _MusicBody()),
          const MiniPlayer(),
        ],
      ),
    );
  }
}

class _MusicBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MusicBody> createState() => _MusicBodyState();
}

class _MusicBodyState extends ConsumerState<_MusicBody> {
  bool _searchActive = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        _buildViewModeBar(),
        const Divider(height: 1, color: AppColors.border),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildTopBar() {
    final scanState = ref.watch(musicScanStateProvider);
    final mode = ref.watch(musicViewModeNotifierProvider);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          if (_searchActive)
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.onBackground),
                decoration: InputDecoration(
                  hintText: 'Search music…',
                  hintStyle: AppTypography.bodyLarge
                      .copyWith(color: AppColors.onSurfaceMuted),
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    ref.read(musicSearchQueryProvider.notifier).setQuery(q),
              ),
            )
          else ...[
            Text('Music',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.onBackground)),
            const Spacer(),
          ],
          // Scan loading indicator
          if (scanState.isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accent),
            ),
          IconButton(
            icon: Icon(
              _searchActive ? Icons.close : Icons.search,
              color: AppColors.onSurface,
              size: 20,
            ),
            onPressed: () {
              setState(() => _searchActive = !_searchActive);
              if (!_searchActive) {
                _searchController.clear();
                ref.read(musicSearchQueryProvider.notifier).clear();
              }
            },
          ),
          if (!_searchActive)
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined,
                  color: AppColors.accent, size: 20),
              tooltip: 'Add music folder',
              onPressed: () => _pickAndScanDirectory(context),
            ),
          if (!_searchActive && mode == MusicViewMode.playlists)
            IconButton(
              icon: const Icon(Icons.playlist_add_rounded,
                  color: AppColors.accent, size: 22),
              tooltip: 'Create playlist',
              onPressed: _promptNewPlaylist,
            ),
        ],
      ),
    );
  }

  Widget _buildViewModeBar() {
    final current = ref.watch(musicViewModeNotifierProvider);
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: MusicViewMode.values
            .map((mode) => _viewChip(
                  label: _viewModeLabel(mode),
                  selected: current == mode,
                  onTap: () => ref
                      .read(musicViewModeNotifierProvider.notifier)
                      .setMode(mode),
                ))
            .toList(),
      ),
    );
  }

  Widget _viewChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? Colors.white : AppColors.onSurfaceMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final query = ref.watch(musicSearchQueryProvider);
    if (query.isNotEmpty) return _buildSearchResults();

    final mode = ref.watch(musicViewModeNotifierProvider);
    return switch (mode) {
      MusicViewMode.library => _buildLibrary(),
      MusicViewMode.albums => _buildAlbumView(),
      MusicViewMode.artists => _buildArtistView(),
      MusicViewMode.playlists => _buildPlaylistView(),
    };
  }

  Widget _buildLibrary() {
    final tracksAsync = ref.watch(trackListStreamProvider);
    return tracksAsync.when(
      data: (tracks) => tracks.isEmpty
          ? _buildEmptyLibrary()
          : _buildTrackList(tracks),
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => _buildErrorState('Failed to load library'),
    );
  }

  Widget _buildTrackList(List<TrackEntity> tracks) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: tracks.length,
      itemBuilder: (_, i) => TrackListItem(
        track: tracks[i],
        allTracks: tracks,
        indexInList: i,
      ),
    );
  }

  Widget _buildSearchResults() {
    final resultsAsync = ref.watch(musicSearchResultsProvider);
    return resultsAsync.when(
      data: (tracks) => tracks.isEmpty
          ? _buildEmpty('No results found')
          : _buildTrackList(tracks),
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => _buildErrorState('Search failed'),
    );
  }

  Widget _buildAlbumView() {
    final tracksAsync = ref.watch(trackListStreamProvider);
    return tracksAsync.when(
      data: (tracks) {
        // Group by album
        final albums = <String, List<TrackEntity>>{};
        for (final t in tracks) {
          (albums[t.displayAlbum] ??= []).add(t);
        }
        if (albums.isEmpty) return _buildEmptyLibrary();
        final sortedAlbums = albums.keys.toList()..sort();
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: sortedAlbums.length,
          itemBuilder: (_, i) {
            final album = sortedAlbums[i];
            final albumTracks = albums[album]!;
            return _AlbumTile(
              album: album,
              artist: albumTracks.first.displayArtist,
              trackCount: albumTracks.length,
              onTap: () => ref
                  .read(playerActionsProvider.notifier)
                  .playQueue(albumTracks),
            );
          },
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => _buildErrorState('Failed to load albums'),
    );
  }

  Widget _buildArtistView() {
    final tracksAsync = ref.watch(trackListStreamProvider);
    return tracksAsync.when(
      data: (tracks) {
        final artists = <String, List<TrackEntity>>{};
        for (final t in tracks) {
          (artists[t.displayArtist] ??= []).add(t);
        }
        if (artists.isEmpty) return _buildEmptyLibrary();
        final sorted = artists.keys.toList()..sort();
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final artist = sorted[i];
            final artistTracks = artists[artist]!;
            return ListTile(
              tileColor: Colors.transparent,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person_rounded,
                    size: 20, color: AppColors.onSurfaceMuted),
              ),
              title: Text(artist,
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.onBackground)),
              subtitle: Text(
                '${artistTracks.length} tracks',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onSurfaceMuted),
              ),
              onTap: () => ref
                  .read(playerActionsProvider.notifier)
                  .playQueue(artistTracks),
            );
          },
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => _buildErrorState('Failed to load artists'),
    );
  }

  Widget _buildPlaylistView() {
    final playlistsAsync = ref.watch(playlistListStreamProvider);
    return playlistsAsync.when(
      data: (playlists) {
        if (playlists.isEmpty) {
          return _buildEmpty('No playlists yet.\nTap + to create one.');
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: playlists.length,
          itemBuilder: (_, i) {
            final p = playlists[i];
            return ListTile(
              tileColor: Colors.transparent,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.queue_music_rounded,
                    size: 20, color: AppColors.onSurfaceMuted),
              ),
              title: Text(
                p.name,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.onBackground),
              ),
              subtitle: Text(
                '${p.trackCount} tracks',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onSurfaceMuted),
              ),
              onTap: () => _playPlaylist(p),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.onSurfaceMuted),
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _promptRenamePlaylist(p);
                      break;
                    case 'delete':
                      _deletePlaylist(p.id);
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => _buildErrorState('Failed to load playlists'),
    );
  }

  Future<void> _promptNewPlaylist() async {
    final name = await _promptForText('New playlist');
    if (name == null || name.trim().isEmpty) return;
    final result =
        await ref.read(playlistActionsProvider.notifier).create(name.trim());
    result.fold(
      onSuccess: (_) => _showMessage('Playlist created'),
      onFailure: (e) => _showMessage('Failed: ${e.message}'),
    );
  }

  Future<void> _promptRenamePlaylist(PlaylistEntity playlist) async {
    final name =
        await _promptForText('Rename playlist', initial: playlist.name);
    if (name == null || name.trim().isEmpty) return;
    final result = await ref
        .read(playlistActionsProvider.notifier)
        .rename(playlist.id, name.trim());
    result.fold(
      onSuccess: (_) => _showMessage('Renamed'),
      onFailure: (e) => _showMessage('Failed: ${e.message}'),
    );
  }

  Future<void> _deletePlaylist(String id) async {
    final result =
        await ref.read(playlistActionsProvider.notifier).delete(id);
    result.fold(
      onSuccess: (_) => _showMessage('Playlist deleted'),
      onFailure: (e) => _showMessage('Failed: ${e.message}'),
    );
  }

  Future<void> _playPlaylist(PlaylistEntity playlist) async {
    final result =
        await ref.read(playlistActionsProvider.notifier).tracks(playlist.id);
    final tracks = result.fold(
      onSuccess: (t) => t,
      onFailure: (_) => <TrackEntity>[],
    );
    if (tracks.isEmpty) {
      _showMessage('Playlist is empty or failed to load');
      return;
    }
    await ref
        .read(playerActionsProvider.notifier)
        .playQueue(tracks, startIndex: 0);
  }

  Future<String?> _promptForText(String title, {String initial = ''}) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: initial);
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  Widget _buildEmptyLibrary() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.library_music_outlined,
              size: 48, color: AppColors.onSurfaceDisabled),
          const SizedBox(height: 16),
          Text(
            'No music indexed yet.',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the folder icon to add a music directory.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onSurfaceDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Text(
        message,
        style: AppTypography.bodyMedium
            .copyWith(color: AppColors.onSurfaceMuted),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorState(String msg) {
    return Center(
      child: Text(msg,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurfaceMuted)),
    );
  }

  String _viewModeLabel(MusicViewMode mode) => switch (mode) {
        MusicViewMode.library => 'All Tracks',
        MusicViewMode.albums => 'Albums',
        MusicViewMode.artists => 'Artists',
        MusicViewMode.playlists => 'Playlists',
      };

  Future<void> _pickAndScanDirectory(BuildContext context) async {
    final fs = ref.read(fileSystemServiceProvider);
    final result = await fs.pickDirectory();
    final path = result.valueOrNull;
    if (path == null) return;
    await ref.read(musicScanStateProvider.notifier).scan(path);
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
    required this.album,
    required this.artist,
    required this.trackCount,
    required this.onTap,
  });

  final String album;
  final String artist;
  final int trackCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.transparent,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.album_rounded,
            size: 20, color: AppColors.onSurfaceMuted),
      ),
      title: Text(album,
          style: AppTypography.bodyLarge
              .copyWith(color: AppColors.onBackground)),
      subtitle: Text(
        '$artist · $trackCount tracks',
        style: AppTypography.labelSmall
            .copyWith(color: AppColors.onSurfaceMuted),
      ),
      onTap: onTap,
    );
  }
}
