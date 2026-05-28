/// Represents a single song entry within a playlist.
class PlaylistMemberModel {
  /// Unique ID of this member row.
  final int id;

  /// ID of the parent playlist.
  final int playlistId;

  /// ID of the audio/song.
  final int audioId;

  /// Play order (position) within the playlist (0-based).
  final int? playOrder;

  /// Title of the song.
  final String? title;

  /// Artist of the song.
  final String? artist;

  const PlaylistMemberModel({
    required this.id,
    required this.playlistId,
    required this.audioId,
    this.playOrder,
    this.title,
    this.artist,
  });

  factory PlaylistMemberModel.fromMap(Map<dynamic, dynamic> map) {
    return PlaylistMemberModel(
      id: _parseInt(map['id']) ?? 0,
      playlistId: _parseInt(map['playlistId']) ?? 0,
      audioId: _parseInt(map['audioId']) ?? 0,
      playOrder: _parseInt(map['playOrder']),
      title: map['title'] as String?,
      artist: map['artist'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'playlistId': playlistId,
        'audioId': audioId,
        'playOrder': playOrder,
        'title': title,
        'artist': artist,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  String toString() =>
      'PlaylistMemberModel(audioId: $audioId, order: $playOrder, title: $title)';
}
