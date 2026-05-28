import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_audio_query_platform_interface.dart';

/// An implementation of [DeviceAudioQueryPlatform] using Flutter method channels.
class MethodChannelDeviceAudioQuery extends DeviceAudioQueryPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('device_audio_query');

  // ─── Permission ─────────────────────────────────────────────────────────────

  @override
  Future<PermissionStatus> requestPermission() async {
    final int code =
        await methodChannel.invokeMethod<int>('requestPermission') ?? 1;
    return PermissionStatus.values[code.clamp(0, 2)];
  }

  @override
  Future<PermissionStatus> checkPermission() async {
    final int code =
        await methodChannel.invokeMethod<int>('checkPermissionStatus') ?? 1;
    return PermissionStatus.values[code.clamp(0, 2)];
  }

  // ─── Songs ───────────────────────────────────────────────────────────────────

  @override
  Future<List<SongModel>> querySongs({
    SongSortType sortType = SongSortType.title,
    OrderType orderType = OrderType.asc,
    UriType uriType = UriType.external,
    String? path,
  }) async {
    final List<dynamic>? raw = await methodChannel
        .invokeListMethod<dynamic>('querySongs', {
          'sortType': sortType.index,
          'orderType': orderType.index,
          'uriType': uriType.index,
          'path': path,
        });
    return (raw ?? [])
        .map((e) => SongModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  // ─── Albums ──────────────────────────────────────────────────────────────────

  @override
  Future<List<AlbumModel>> queryAlbums({
    AlbumSortType sortType = AlbumSortType.album,
    OrderType orderType = OrderType.asc,
  }) async {
    final List<dynamic>? raw = await methodChannel.invokeListMethod<dynamic>(
      'queryAlbums',
      {'sortType': sortType.index, 'orderType': orderType.index},
    );
    return (raw ?? [])
        .map((e) => AlbumModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  // ─── Artists ─────────────────────────────────────────────────────────────────

  @override
  Future<List<ArtistModel>> queryArtists({
    ArtistSortType sortType = ArtistSortType.artist,
    OrderType orderType = OrderType.asc,
  }) async {
    final List<dynamic>? raw = await methodChannel.invokeListMethod<dynamic>(
      'queryArtists',
      {'sortType': sortType.index, 'orderType': orderType.index},
    );
    return (raw ?? [])
        .map((e) => ArtistModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  // ─── Playlists ───────────────────────────────────────────────────────────────

  @override
  Future<List<PlaylistModel>> queryPlaylists({
    PlaylistSortType sortType = PlaylistSortType.playlist,
    OrderType orderType = OrderType.asc,
  }) async {
    final List<dynamic>? raw = await methodChannel.invokeListMethod<dynamic>(
      'queryPlaylists',
      {'sortType': sortType.index, 'orderType': orderType.index},
    );
    return (raw ?? [])
        .map((e) => PlaylistModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  @override
  Future<List<PlaylistMemberModel>> queryPlaylistMembers({
    required int playlistId,
  }) async {
    final List<dynamic>? raw = await methodChannel.invokeListMethod<dynamic>(
      'queryPlaylistMembers',
      {'playlistId': playlistId},
    );
    return (raw ?? [])
        .map((e) => PlaylistMemberModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  // ─── Filtered songs ──────────────────────────────────────────────────────────

  @override
  Future<List<SongModel>> queryAudiosWith({
    required AudiosFrom from,
    required int fromId,
    SongSortType sortType = SongSortType.title,
    OrderType orderType = OrderType.asc,
  }) async {
    final List<dynamic>? raw = await methodChannel
        .invokeListMethod<dynamic>('queryAudiosWith', {
          'from': from.index,
          'fromId': fromId,
          'sortType': sortType.index,
          'orderType': orderType.index,
        });
    return (raw ?? [])
        .map((e) => SongModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  // ─── Artwork ─────────────────────────────────────────────────────────────────

  @override
  Future<Uint8List?> queryArtwork({
    required int id,
    required ArtworkType type,
    ArtworkFormat format = ArtworkFormat.jpeg,
    int size = 200,
  }) async {
    final Uint8List? bytes = await methodChannel.invokeMethod<Uint8List>(
      'queryArtwork',
      {'id': id, 'type': type.index, 'format': format.index, 'size': size},
    );
    return bytes;
  }
}
