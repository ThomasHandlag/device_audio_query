/// Represents a playlist on the device.
class PlaylistModel {
  /// Unique identifier of the playlist.
  final int id;

  /// Playlist name.
  final String playlist;

  /// Number of songs in the playlist.
  final int? numOfSongs;

  /// Date the playlist was created (Unix timestamp in seconds).
  final int? dateAdded;

  /// Date the playlist was last modified (Unix timestamp in seconds).
  final int? dateModified;

  const PlaylistModel({
    required this.id,
    required this.playlist,
    this.numOfSongs,
    this.dateAdded,
    this.dateModified,
  });

  factory PlaylistModel.fromMap(Map<dynamic, dynamic> map) {
    return PlaylistModel(
      id: _parseInt(map['id']) ?? 0,
      playlist: map['playlist'] as String? ?? 'Unknown Playlist',
      numOfSongs: _parseInt(map['numOfSongs']),
      dateAdded: _parseInt(map['dateAdded']),
      dateModified: _parseInt(map['dateModified']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'playlist': playlist,
        'numOfSongs': numOfSongs,
        'dateAdded': dateAdded,
        'dateModified': dateModified,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  String toString() =>
      'PlaylistModel(id: $id, playlist: $playlist, songs: $numOfSongs)';
}
