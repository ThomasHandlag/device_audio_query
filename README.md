# device_audio_query

A Flutter plugin to query audio files and their metadata from the device's storage. It provides an easy-to-use API for retrieving information about songs, albums, artists, and playlists, making it ideal for music player applications or any app that needs to access audio content on the device.

## Getting Started

### Installing

#### The following permission must be included

```xml
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
 <!-- Android 12 or below  -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### Usage

```dart
final _plugin = DeviceAudioQuery();
// Request permission
final status = await _plugin.checkPermission();

_plugin.querySongs(sortType: SongSortType.title),
_plugin.queryAlbums(sortType: AlbumSortType.album),
_plugin.queryArtists(sortType: ArtistSortType.artist),
_plugin.queryPlaylists(sortType: PlaylistSortType.playlist),
```

** Check out example code for more details
