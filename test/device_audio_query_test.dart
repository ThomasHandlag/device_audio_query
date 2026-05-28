import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:device_audio_query/device_audio_query.dart';
import 'package:device_audio_query/device_audio_query_platform_interface.dart';
import 'package:device_audio_query/device_audio_query_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceAudioQueryPlatform
    with MockPlatformInterfaceMixin
    implements DeviceAudioQueryPlatform {
  @override
  Future<PermissionStatus> requestPermission() =>
      Future.value(PermissionStatus.granted);

  @override
  Future<List<AlbumModel>> queryAlbums(
      {AlbumSortType sortType = AlbumSortType.album,
      OrderType orderType = OrderType.asc}) {
    throw UnimplementedError();
  }

  @override
  Future<List<ArtistModel>> queryArtists(
      {ArtistSortType sortType = ArtistSortType.artist,
      OrderType orderType = OrderType.asc}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> queryArtwork(
      {required int id,
      required ArtworkType type,
      ArtworkFormat format = ArtworkFormat.jpeg,
      int size = 200}) {
    throw UnimplementedError();
  }

  @override
  Future<List<SongModel>> queryAudiosWith(
      {required AudiosFrom from,
      required int fromId,
      SongSortType sortType = SongSortType.title,
      OrderType orderType = OrderType.asc}) {
    throw UnimplementedError();
  }

  @override
  Future<List<PlaylistMemberModel>> queryPlaylistMembers(
      {required int playlistId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<PlaylistModel>> queryPlaylists(
      {PlaylistSortType sortType = PlaylistSortType.playlist,
      OrderType orderType = OrderType.asc}) {
    throw UnimplementedError();
  }

  @override
  Future<List<SongModel>> querySongs(
      {SongSortType sortType = SongSortType.title,
      OrderType orderType = OrderType.asc,
      UriType uriType = UriType.external,
      String? path}) {
    throw UnimplementedError();
  }
  
  @override
  Future<PermissionStatus> checkPermission() {
    throw UnimplementedError();
  }
}

void main() {
  final DeviceAudioQueryPlatform initialPlatform =
      DeviceAudioQueryPlatform.instance;

  test('$MethodChannelDeviceAudioQuery is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceAudioQuery>());
  });

  test('requestPermission', () async {
    DeviceAudioQuery deviceAudioQueryPlugin = DeviceAudioQuery();
    MockDeviceAudioQueryPlatform fakePlatform = MockDeviceAudioQueryPlatform();
    DeviceAudioQueryPlatform.instance = fakePlatform;

    expect(await deviceAudioQueryPlugin.requestPermission(),
        PermissionStatus.granted);
  });
}
