import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_audio_query_method_channel.dart';
import 'src/enums/artwork_type.dart';
import 'src/enums/permission_status.dart';
import 'src/enums/sort_type.dart';
import 'src/models/album_model.dart';
import 'src/models/artist_model.dart';
import 'src/models/playlist_member_model.dart';
import 'src/models/playlist_model.dart';
import 'src/models/song_model.dart';

export 'src/enums/artwork_type.dart';
export 'src/enums/permission_status.dart';
export 'src/enums/sort_type.dart';
export 'src/models/album_model.dart';
export 'src/models/artist_model.dart';
export 'src/models/playlist_member_model.dart';
export 'src/models/playlist_model.dart';
export 'src/models/song_model.dart';

abstract class DeviceAudioQueryPlatform extends PlatformInterface {
  DeviceAudioQueryPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceAudioQueryPlatform _instance = MethodChannelDeviceAudioQuery();

  /// The default instance of [DeviceAudioQueryPlatform] to use.
  static DeviceAudioQueryPlatform get instance => _instance;

  static set instance(DeviceAudioQueryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ─── Permission ─────────────────────────────────────────────────────────────

  Future<PermissionStatus> requestPermission() {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Future<PermissionStatus> checkPermission() {
    throw UnimplementedError('checkPermission() has not been implemented.');
  }

  // ─── Songs ───────────────────────────────────────────────────────────────────

  Future<List<SongModel>> querySongs({
    SongSortType sortType = SongSortType.title,
    OrderType orderType = OrderType.asc,
    UriType uriType = UriType.external,
    String? path,
  }) {
    throw UnimplementedError('querySongs() has not been implemented.');
  }

  // ─── Albums ──────────────────────────────────────────────────────────────────

  Future<List<AlbumModel>> queryAlbums({
    AlbumSortType sortType = AlbumSortType.album,
    OrderType orderType = OrderType.asc,
  }) {
    throw UnimplementedError('queryAlbums() has not been implemented.');
  }

  // ─── Artists ─────────────────────────────────────────────────────────────────

  Future<List<ArtistModel>> queryArtists({
    ArtistSortType sortType = ArtistSortType.artist,
    OrderType orderType = OrderType.asc,
  }) {
    throw UnimplementedError('queryArtists() has not been implemented.');
  }

  // ─── Playlists ───────────────────────────────────────────────────────────────

  Future<List<PlaylistModel>> queryPlaylists({
    PlaylistSortType sortType = PlaylistSortType.playlist,
    OrderType orderType = OrderType.asc,
  }) {
    throw UnimplementedError('queryPlaylists() has not been implemented.');
  }

  Future<List<PlaylistMemberModel>> queryPlaylistMembers({
    required int playlistId,
  }) {
    throw UnimplementedError(
      'queryPlaylistMembers() has not been implemented.',
    );
  }

  // ─── Filtered songs ──────────────────────────────────────────────────────────

  Future<List<SongModel>> queryAudiosWith({
    required AudiosFrom from,
    required int fromId,
    SongSortType sortType = SongSortType.title,
    OrderType orderType = OrderType.asc,
  }) {
    throw UnimplementedError('queryAudiosWith() has not been implemented.');
  }

  // ─── Artwork ─────────────────────────────────────────────────────────────────

  Future<Uint8List?> queryArtwork({
    required int id,
    required ArtworkType type,
    ArtworkFormat format = ArtworkFormat.jpeg,
    int size = 200,
  }) {
    throw UnimplementedError('queryArtwork() has not been implemented.');
  }
}
