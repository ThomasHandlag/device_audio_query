import 'dart:typed_data';

import 'package:device_audio_query/device_audio_query.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DeviceAudioQueryExampleApp());
}

class DeviceAudioQueryExampleApp extends StatelessWidget {
  const DeviceAudioQueryExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Audio Query',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const HomePage(),
    );
  }
}

// ─── Home Page ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _plugin = DeviceAudioQuery();
  late final TabController _tabController;

  PermissionStatus? _permission;
  bool _loading = false;

  List<SongModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<PlaylistModel> _playlists = [];

  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    setState(() => _loading = true);
    final status = await _plugin.checkPermission();
    setState(() {
      _permission = status;
      _loading = false;
    });
    if (status == PermissionStatus.granted) {
      await _loadAll();
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _loading = true);
    final status = await _plugin.requestPermission();
    setState(() {
      _permission = status;
      _loading = false;
    });
    if (status == PermissionStatus.granted) {
      await _loadAll();
    }
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _plugin.querySongs(sortType: SongSortType.title),
      _plugin.queryAlbums(sortType: AlbumSortType.album),
      _plugin.queryArtists(sortType: ArtistSortType.artist),
      _plugin.queryPlaylists(sortType: PlaylistSortType.playlist),
    ]);
    setState(() {
      _songs = results[0] as List<SongModel>;
      _albums = results[1] as List<AlbumModel>;
      _artists = results[2] as List<ArtistModel>;
      _playlists = results[3] as List<PlaylistModel>;
      _loading = false;
    });
  }

  List<SongModel> get _filteredSongs => _searchQuery.isEmpty
      ? _songs
      : _songs
          .where((s) =>
              (s.title).toLowerCase().contains(_searchQuery) ||
              (s.artist ?? '').toLowerCase().contains(_searchQuery))
          .toList();

  List<AlbumModel> get _filteredAlbums => _searchQuery.isEmpty
      ? _albums
      : _albums
          .where((a) =>
              a.album.toLowerCase().contains(_searchQuery) ||
              (a.artist ?? '').toLowerCase().contains(_searchQuery))
          .toList();

  List<ArtistModel> get _filteredArtists => _searchQuery.isEmpty
      ? _artists
      : _artists
          .where(
              (a) => a.artist.toLowerCase().contains(_searchQuery))
          .toList();

  List<PlaylistModel> get _filteredPlaylists => _searchQuery.isEmpty
      ? _playlists
      : _playlists
          .where((p) =>
              p.playlist.toLowerCase().contains(_searchQuery))
          .toList();

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: _permission == null || _permission != PermissionStatus.granted
          ? _buildPermissionGate(cs)
          : _buildMain(cs),
    );
  }

  // ─── Permission gate ───────────────────────────────────────────────────────

  Widget _buildPermissionGate(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.surface,
            cs.secondaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.4),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.library_music_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Device Audio Query',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _permission == PermissionStatus.deniedForever
                      ? 'Media permission was permanently denied.\nPlease enable it in Settings.'
                      : 'Grant access to your music library to explore songs, albums, artists, and playlists.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (_permission != PermissionStatus.deniedForever)
                  _GradientButton(
                    onPressed: _loading ? null : _requestPermission,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Grant Permission',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Main content ──────────────────────────────────────────────────────────

  Widget _buildMain(ColorScheme cs) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          floating: true,
          expandedHeight: 120,
          backgroundColor: cs.surface,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding:
                const EdgeInsets.only(left: 20, bottom: 56),
            title: Text(
              'My Library',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          actions: [
            if (_loading)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadAll,
                tooltip: 'Refresh',
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (q) => setState(
                    () => _searchQuery = q.toLowerCase()),
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Songs'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
                Tab(text: 'Playlists'),
              ],
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurface.withValues(alpha: 0.5),
              indicatorColor: cs.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: cs.surfaceContainerHighest,
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _SongList(songs: _filteredSongs, plugin: _plugin),
          _AlbumGrid(albums: _filteredAlbums, plugin: _plugin),
          _ArtistList(artists: _filteredArtists),
          _PlaylistList(playlists: _filteredPlaylists),
        ],
      ),
    );
  }
}

// ─── Tab bar delegate ─────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: 'Search…',
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
        prefixIcon: Icon(Icons.search_rounded,
            color: cs.onSurface.withValues(alpha: 0.4)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: cs.onSurface.withValues(alpha: 0.4)),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}

// ─── Song list ────────────────────────────────────────────────────────────────

class _SongList extends StatelessWidget {
  final List<SongModel> songs;
  final DeviceAudioQuery plugin;

  const _SongList({required this.songs, required this.plugin});

  String _formatDuration(int? ms) {
    if (ms == null) return '--:--';
    final s = ms ~/ 1000;
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const _EmptyState(label: 'No songs found');
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final song = songs[i];
        return ListTile(
          leading: _ArtworkThumbnail(
            id: song.id,
            type: ArtworkType.audio,
            plugin: plugin,
            size: 48,
            radius: 8,
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            song.artist ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55)),
          ),
          trailing: Text(
            _formatDuration(song.duration),
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        );
      },
    );
  }
}

// ─── Album grid ───────────────────────────────────────────────────────────────

class _AlbumGrid extends StatelessWidget {
  final List<AlbumModel> albums;
  final DeviceAudioQuery plugin;

  const _AlbumGrid({required this.albums, required this.plugin});

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const _EmptyState(label: 'No albums found');
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final album = albums[i];
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: _ArtworkThumbnail(
                  id: album.id,
                  type: ArtworkType.audio,
                  plugin: plugin,
                  size: 50,
                  radius: 0,
                  aspectRatio: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                child: Text(
                  album.album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: Text(
                  album.artist ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Artist list ──────────────────────────────────────────────────────────────

class _ArtistList extends StatelessWidget {
  final List<ArtistModel> artists;
  const _ArtistList({required this.artists});

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const _EmptyState(label: 'No artists found');
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final artist = artists[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Text(
              artist.artist.isNotEmpty
                  ? artist.artist[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            artist.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${artist.numberOfTracks ?? 0} tracks · '
            '${artist.numberOfAlbums ?? 0} albums',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55)),
          ),
        );
      },
    );
  }
}

// ─── Playlist list ────────────────────────────────────────────────────────────

class _PlaylistList extends StatelessWidget {
  final List<PlaylistModel> playlists;
  const _PlaylistList({required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const _EmptyState(label: 'No playlists found');
    }
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: playlists.length,
      itemBuilder: (_, i) {
        final playlist = playlists[i];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.queue_music_rounded,
                color: Colors.white, size: 24),
          ),
          title: Text(
            playlist.playlist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${playlist.numOfSongs ?? 0} songs',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55)),
          ),
        );
      },
    );
  }
}

// ─── Artwork thumbnail ────────────────────────────────────────────────────────

class _ArtworkThumbnail extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final DeviceAudioQuery plugin;
  final double size;
  final double radius;
  final double? aspectRatio;

  const _ArtworkThumbnail({
    required this.id,
    required this.type,
    required this.plugin,
    required this.size,
    required this.radius,
    this.aspectRatio,
  });

  @override
  State<_ArtworkThumbnail> createState() => _ArtworkThumbnailState();
}

class _ArtworkThumbnailState extends State<_ArtworkThumbnail> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await widget.plugin.queryArtwork(
        id: widget.id,
        type: widget.type,
        size: 200,
      );
      if (mounted) setState(() { _bytes = bytes; });
    } catch (_) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget child;

    if (_bytes != null) {
      child = Image.memory(_bytes!, fit: BoxFit.cover);
    } else {
      child = Container(
        color: cs.surfaceContainerHighest,
        child: Icon(
          Icons.music_note_rounded,
          color: cs.onSurface.withValues(alpha: 0.3),
          size: 22,
        ),
      );
    }

    if (widget.aspectRatio != null) {
      child = AspectRatio(aspectRatio: widget.aspectRatio!, child: child);
    } else {
      child = SizedBox(width: widget.size.toDouble(),
          height: widget.size.toDouble(), child: child);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: child,
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_off_rounded,
              size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.4),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _GradientButton({required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.tertiary],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
