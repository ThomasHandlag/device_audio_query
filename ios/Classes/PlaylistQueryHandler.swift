import MediaPlayer

private enum PlaylistSortType: Int {
    case playlist = 0, dateAdded, dateModified, numOfSongs
}

enum PlaylistQueryHandler {

    // MARK: - Playlists

    static func queryPlaylists(sortType: Int, orderType: Int) -> [[String: Any?]] {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return [] }

        let query = MPMediaQuery.playlists()
        var collections = (query.collections as? [MPMediaPlaylist]) ?? []

        collections = sorted(playlists: collections, sortType: sortType, orderType: orderType)

        return collections.map { playlist -> [String: Any?] in
            [
                "id":           Int(playlist.persistentID),
                "playlist":     playlist.name ?? "Unknown Playlist",
                "numOfSongs":   playlist.items.count,
                "dateAdded":    nil,
                "dateModified": nil,
            ]
        }
    }

    // MARK: - Members

    static func queryPlaylistMembers(playlistId: Int) -> [[String: Any?]] {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return [] }

        let query = MPMediaQuery.playlists()
        query.addFilterPredicate(
            MPMediaPropertyPredicate(
                value: playlistId,
                forProperty: MPMediaPlaylistPropertyPersistentID,
                comparisonType: .equalTo
            )
        )

        guard let playlist = (query.collections as? [MPMediaPlaylist])?.first else {
            return []
        }

        return playlist.items.enumerated().map { (index, item) -> [String: Any?] in
            [
                "id":         index,
                "playlistId": playlistId,
                "audioId":    Int(item.persistentID),
                "playOrder":  index,
                "title":      item.title,
                "artist":     item.artist,
            ]
        }
    }

    // MARK: - Songs in playlist (used by queryAudiosWith)

    static func querySongsInPlaylist(playlistId: Int) -> [[String: Any?]] {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return [] }

        let query = MPMediaQuery.playlists()
        query.addFilterPredicate(
            MPMediaPropertyPredicate(
                value: playlistId,
                forProperty: MPMediaPlaylistPropertyPersistentID,
                comparisonType: .equalTo
            )
        )

        let items = (query.collections as? [MPMediaPlaylist])?.first?.items ?? []
        return items.map { AudioQueryHandler.songToMap($0) }
    }

    // MARK: - Sort helper

    private static func sorted(
        playlists: [MPMediaPlaylist],
        sortType: Int,
        orderType: Int
    ) -> [MPMediaPlaylist] {
        let asc = orderType == 0
        switch PlaylistSortType(rawValue: sortType) ?? .playlist {
        case .playlist:
            return playlists.sorted {
                let a = $0.name ?? ""
                let b = $1.name ?? ""
                return asc
                    ? a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                    : a.localizedCaseInsensitiveCompare(b) == .orderedDescending
            }
        case .numOfSongs:
            return playlists.sorted {
                asc ? $0.items.count < $1.items.count : $0.items.count > $1.items.count
            }
        case .dateAdded, .dateModified:
            return playlists
        }
    }
}
