/// Defines how songs are sorted in [querySongs].
enum SongSortType {
  /// Sort by the display title (default).
  title,

  /// Sort by artist name.
  artist,

  /// Sort by album name.
  album,

  /// Sort by duration.
  duration,

  /// Sort by date the file was added to the device.
  dateAdded,

  /// Sort by file size.
  size,

  /// Sort by display name (filename).
  displayName,
}

/// Defines how albums are sorted in [queryAlbums].
enum AlbumSortType {
  /// Sort by album title (default).
  album,

  /// Sort by artist name.
  artist,

  /// Sort by number of songs.
  numOfSongs,

  /// Sort by release year.
  year,
}

/// Defines how artists are sorted in [queryArtists].
enum ArtistSortType {
  /// Sort by artist name (default).
  artist,

  /// Sort by number of tracks.
  numOfTracks,

  /// Sort by number of albums.
  numOfAlbums,
}

/// Defines how playlists are sorted in [queryPlaylists].
enum PlaylistSortType {
  /// Sort by playlist name (default).
  playlist,

  /// Sort by date added.
  dateAdded,

  /// Sort by date modified.
  dateModified,

  /// Sort by number of members.
  numOfSongs,
}

/// Controls ascending or descending order for any sort.
enum OrderType {
  /// Ascending order A→Z / oldest→newest (default).
  asc,

  /// Descending order Z→A / newest→oldest.
  desc,
}
