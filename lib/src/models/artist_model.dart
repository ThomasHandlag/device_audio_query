/// Represents an artist on the device.
class ArtistModel {
  /// Unique identifier of the artist.
  final int id;

  /// Artist name.
  final String artist;

  /// Number of albums by this artist.
  final int? numberOfAlbums;

  /// Number of tracks by this artist.
  final int? numberOfTracks;

  const ArtistModel({
    required this.id,
    required this.artist,
    this.numberOfAlbums,
    this.numberOfTracks,
  });

  factory ArtistModel.fromMap(Map<dynamic, dynamic> map) {
    return ArtistModel(
      id: _parseInt(map['id']) ?? 0,
      artist: map['artist'] as String? ?? 'Unknown Artist',
      numberOfAlbums: _parseInt(map['numberOfAlbums']),
      numberOfTracks: _parseInt(map['numberOfTracks']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'artist': artist,
        'numberOfAlbums': numberOfAlbums,
        'numberOfTracks': numberOfTracks,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  String toString() =>
      'ArtistModel(id: $id, artist: $artist, tracks: $numberOfTracks)';
}
