/// Represents an audio file (song) on the device.
class SongModel {
  /// Unique identifier (MediaStore ID on Android, persistent ID on iOS).
  final int id;

  /// Display title of the song.
  final String title;

  /// Artist name.
  final String? artist;

  /// Album name.
  final String? album;

  /// Album ID.
  final int? albumId;

  /// Artist ID.
  final int? artistId;

  /// Genre name.
  final String? genre;

  /// Genre ID.
  final int? genreId;

  /// Duration in milliseconds.
  final int? duration;

  /// File size in bytes.
  final int? size;

  /// Absolute path to the audio file.
  final String? data;

  /// URI string for the audio file.
  final String? uri;

  /// Track number within the album.
  final int? trackNumber;

  /// Disc number.
  final int? discNumber;

  /// Year the song was released.
  final int? year;

  /// Date added to the device (Unix timestamp).
  final int? dateAdded;

  /// Date modified (Unix timestamp).
  final int? dateModified;

  /// MIME type (e.g. "audio/mpeg").
  final String? mimeType;

  /// Bitrate in bits per second.
  final int? bitrate;

  /// Sample rate in Hz.
  final int? sampleRate;

  /// Number of audio channels.
  final int? channels;

  /// Composer name.
  final String? composer;

  /// Whether the song is marked as favorite/liked.
  final bool? isFavorite;

  const SongModel({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.albumId,
    this.artistId,
    this.genre,
    this.genreId,
    this.duration,
    this.size,
    this.data,
    this.uri,
    this.trackNumber,
    this.discNumber,
    this.year,
    this.dateAdded,
    this.dateModified,
    this.mimeType,
    this.bitrate,
    this.sampleRate,
    this.channels,
    this.composer,
    this.isFavorite,
  });

  factory SongModel.fromMap(Map<dynamic, dynamic> map) {
    return SongModel(
      id: _parseInt(map['id']) ?? 0,
      title: map['title'] as String? ?? 'Unknown',
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      albumId: _parseInt(map['albumId']),
      artistId: _parseInt(map['artistId']),
      genre: map['genre'] as String?,
      genreId: _parseInt(map['genreId']),
      duration: _parseInt(map['duration']),
      size: _parseInt(map['size']),
      data: map['data'] as String?,
      uri: map['uri'] as String?,
      trackNumber: _parseInt(map['trackNumber']),
      discNumber: _parseInt(map['discNumber']),
      year: _parseInt(map['year']),
      dateAdded: _parseInt(map['dateAdded']),
      dateModified: _parseInt(map['dateModified']),
      mimeType: map['mimeType'] as String?,
      bitrate: _parseInt(map['bitrate']),
      sampleRate: _parseInt(map['sampleRate']),
      channels: _parseInt(map['channels']),
      composer: map['composer'] as String?,
      isFavorite: map['isFavorite'] as bool?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'albumId': albumId,
        'artistId': artistId,
        'genre': genre,
        'genreId': genreId,
        'duration': duration,
        'size': size,
        'data': data,
        'uri': uri,
        'trackNumber': trackNumber,
        'discNumber': discNumber,
        'year': year,
        'dateAdded': dateAdded,
        'dateModified': dateModified,
        'mimeType': mimeType,
        'bitrate': bitrate,
        'sampleRate': sampleRate,
        'channels': channels,
        'composer': composer,
        'isFavorite': isFavorite,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  String toString() => 'SongModel(id: $id, title: $title, artist: $artist)';
}
