/// Represents an album on the device.
class AlbumModel {
  /// Unique identifier of the album.
  final int id;

  /// Album title.
  final String album;

  /// Primary artist of the album.
  final String? artist;

  /// Artist ID.
  final int? artistId;

  /// Number of songs in this album.
  final int? numOfSongs;

  /// URI to the album art.
  final String? albumArtUri;

  /// Year the album was released.
  final int? year;

  const AlbumModel({
    required this.id,
    required this.album,
    this.artist,
    this.artistId,
    this.numOfSongs,
    this.albumArtUri,
    this.year,
  });

  factory AlbumModel.fromMap(Map<dynamic, dynamic> map) {
    return AlbumModel(
      id: _parseInt(map['id']) ?? 0,
      album: map['album'] as String? ?? 'Unknown Album',
      artist: map['artist'] as String?,
      artistId: _parseInt(map['artistId']),
      numOfSongs: _parseInt(map['numOfSongs']),
      albumArtUri: map['albumArtUri'] as String?,
      year: _parseInt(map['year']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'album': album,
        'artist': artist,
        'artistId': artistId,
        'numOfSongs': numOfSongs,
        'albumArtUri': albumArtUri,
        'year': year,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  String toString() => 'AlbumModel(id: $id, album: $album, artist: $artist)';
}
