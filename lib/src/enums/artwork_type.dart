/// Specifies whether artwork is for a song or an album.
enum ArtworkType {
  /// Artwork for a single audio track.
  audio,

  /// Artwork for an album.
  album,
}

/// Image format for returned artwork bytes.
enum ArtworkFormat {
  /// JPEG format (lossy, smaller size).
  jpeg,

  /// PNG format (lossless).
  png,
}

/// Specifies the URI type used when querying songs.
enum UriType {
  /// Query from the external storage MediaStore (default).
  external,

  /// Query from internal storage MediaStore (rarely used).
  internal,
}

/// Specifies the source entity when using [queryAudiosWith].
enum AudiosFrom {
  /// Filter songs that belong to a specific album.
  album,

  /// Filter songs that belong to a specific artist.
  artist,

  /// Filter songs that belong to a specific playlist.
  playlist,

  /// Filter songs that belong to a specific genre.
  genre,
}
