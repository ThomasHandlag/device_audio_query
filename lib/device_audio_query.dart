import 'dart:typed_data';

import 'device_audio_query_platform_interface.dart';


export 'device_audio_query_platform_interface.dart'
    show
        AlbumModel,
        AlbumSortType,
        ArtistModel,
        ArtistSortType,
        ArtworkFormat,
        ArtworkType,
        AudiosFrom,
        OrderType,
        PermissionStatus,
        PlaylistMemberModel,
        PlaylistModel,
        PlaylistSortType,
        SongModel,
        SongSortType,
        UriType;

/// Main entry point for the device_audio_query plugin.
///
/// Example usage:
/// ```dart
/// final plugin = DeviceAudioQuery();
/// final status = await plugin.requestPermission();
/// if (status == PermissionStatus.granted) {
///   final songs = await plugin.querySongs();
/// }
/// ```
class DeviceAudioQuery {
  // ─── Permission ─────────────────────────────────────────────────────────────

  /// Requests storage/media permission from the OS.
  ///
  /// Returns a [PermissionStatus] indicating the result.
  Future<PermissionStatus> requestPermission() {
    return DeviceAudioQueryPlatform.instance.requestPermission();
  }

  Future<PermissionStatus> checkPermission() {
    return DeviceAudioQueryPlatform.instance.checkPermission();
  }

  // ─── Songs ───────────────────────────────────────────────────────────────────

  /// Queries all audio files from the device.
  ///
  /// - [sortType] controls which field to sort by (default: [SongSortType.title]).
  /// - [orderType] controls ascending/descending (default: [OrderType.asc]).
  /// - [uriType] selects external vs internal MediaStore (Android only).
  /// - [path] filters songs under a specific directory path (Android only).
  Future<List<SongModel>> querySongs({
    SongSortType sortType = SongSortType.title,
    OrderType orderType = OrderType.asc,
    UriType uriType = UriType.external,
    String? path,
  }) {
    return DeviceAudioQueryPlatform.instance.querySongs(
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
      path: path,
    );
  }

  // ─── Albums ──────────────────────────────────────────────────────────────────

  /// Queries all albums on the device.
  Future<List<AlbumModel>> queryAlbums({
    AlbumSortType sortType = AlbumSortType.album,
    OrderType orderType = OrderType.asc,
  }) {
    return DeviceAudioQueryPlatform.instance.queryAlbums(
      sortType: sortType,
      orderType: orderType,
    );
  }

  // ─── Artists ─────────────────────────────────────────────────────────────────

  /// Queries all artists on the device.
  Future<List<ArtistModel>> queryArtists({
    ArtistSortType sortType = ArtistSortType.artist,
    OrderType orderType = OrderType.asc,
  }) {
    return DeviceAudioQueryPlatform.instance.queryArtists(
      sortType: sortType,
      orderType: orderType,
    );
  }

  // ─── Playlists ───────────────────────────────────────────────────────────────

  /// Queries all playlists on the device.
  Future<List<PlaylistModel>> queryPlaylists({
    PlaylistSortType sortType = PlaylistSortType.playlist,
    OrderType orderType = OrderType.asc,
  }) {
    return DeviceAudioQueryPlatform.instance.queryPlaylists(
      sortType: sortType,
      orderType: orderType,
    );
  }

  /// Queries all songs that are members of [playlistId].
  Future<List<PlaylistMemberModel>> queryPlaylistMembers({
    required int playlistId,
  }) {
    return DeviceAudioQueryPlatform.instance.queryPlaylistMembers(
      playlistId: playlistId,
    );
  }

  // ─── Filtered songs ──────────────────────────────────────────────────────────

  /// Queries songs that belong to a specific album, artist, playlist, or genre.
  ///
  /// - [from] specifies the entity type (e.g. [AudiosFrom.album]).
  /// - [fromId] is the ID of that entity.
  Future<List<SongModel>> queryAudiosWith({
    required AudiosFrom from,
    required int fromId,
    SongSortType sortType = SongSortType.title,
    OrderType orderType = OrderType.asc,
  }) {
    return DeviceAudioQueryPlatform.instance.queryAudiosWith(
      from: from,
      fromId: fromId,
      sortType: sortType,
      orderType: orderType,
    );
  }

  // ─── Artwork ─────────────────────────────────────────────────────────────────

  /// Fetches artwork bytes for a song or album.
  ///
  /// - [id] is the song or album ID.
  /// - [type] selects [ArtworkType.audio] or [ArtworkType.album].
  /// - [format] selects [ArtworkFormat.jpeg] (default) or [ArtworkFormat.png].
  /// - [size] is the requested thumbnail edge size in pixels (default 200).
  ///
  /// Returns `null` if no artwork is available.
  Future<Uint8List?> queryArtwork({
    required int id,
    required ArtworkType type,
    ArtworkFormat format = ArtworkFormat.jpeg,
    int size = 200,
  }) {
    return DeviceAudioQueryPlatform.instance.queryArtwork(
      id: id,
      type: type,
      format: format,
      size: size,
    );
  }
}
