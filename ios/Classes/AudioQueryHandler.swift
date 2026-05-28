import MediaPlayer

/// Column indices matching the Dart SongSortType enum.
private enum SongSortType: Int {
    case title = 0, artist, album, duration, dateAdded, size, displayName
}

enum AudioQueryHandler {

    // MARK: - Permission

    static func checkPermissionState(result: @escaping FlutterResult) {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            result(0)
        case .denied, .restricted:
            result(2)
        case .notDetermined:
            result(1)
        @unknown default:
            result(1)
        }
    }

    static func requestPermission(result: @escaping FlutterResult) {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            result(0)
        case .denied, .restricted:
            result(2)
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    result(newStatus == .authorized ? 0 : 1)
                }
            }
        @unknown default:
            result(1)
        }
    }

    // MARK: - Query songs

    static func querySongs(
        sortType: Int,
        orderType: Int,
        path: String?
    ) -> [[String: Any?]] {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return [] }

        let query = MPMediaQuery.songs()
        query.groupingType = .title

        var items = query.items ?? []

        // Apply path filter (approximate – match by title/artist substring on iOS)
        if let p = path, !p.isEmpty {
            items = items.filter {
                ($0.title ?? "").localizedCaseInsensitiveContains(p) ||
                ($0.artist ?? "").localizedCaseInsensitiveContains(p)
            }
        }

        // Sort
        items = sorted(items: items, sortType: sortType, orderType: orderType)

        return items.map { songToMap($0) }
    }

    // MARK: - Query audios with filter

    static func queryAudiosWith(
        from: Int,
        fromId: Int,
        sortType: Int,
        orderType: Int
    ) -> [[String: Any?]] {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return [] }

        let query: MPMediaQuery
        switch from {
        case 0: // album
            query = MPMediaQuery.albums()
            query.addFilterPredicate(
                MPMediaPropertyPredicate(
                    value: fromId,
                    forProperty: MPMediaItemPropertyAlbumPersistentID,
                    comparisonType: .equalTo
                )
            )
        case 1: // artist
            query = MPMediaQuery.artists()
            query.addFilterPredicate(
                MPMediaPropertyPredicate(
                    value: fromId,
                    forProperty: MPMediaItemPropertyArtistPersistentID,
                    comparisonType: .equalTo
                )
            )
        case 2: // playlist
            return PlaylistQueryHandler.querySongsInPlaylist(playlistId: fromId)
        case 3: // genre
            query = MPMediaQuery.genres()
            query.addFilterPredicate(
                MPMediaPropertyPredicate(
                    value: fromId,
                    forProperty: MPMediaItemPropertyGenrePersistentID,
                    comparisonType: .equalTo
                )
            )
        default:
            query = MPMediaQuery.songs()
        }

        var items = query.items ?? []
        items = sorted(items: items, sortType: sortType, orderType: orderType)
        return items.map { songToMap($0) }
    }

    // MARK: - Internal helpers

    static func songToMap(_ item: MPMediaItem) -> [String: Any?] {
        [
            "id":            Int(item.persistentID),
            "title":         item.title,
            "artist":        item.artist,
            "artistId":      Int(item.artistPersistentID),
            "album":         item.albumTitle,
            "albumId":       Int(item.albumPersistentID),
            "genre":         item.genre,
            "genreId":       Int(item.genrePersistentID),
            "duration":      Int(item.playbackDuration * 1000),
            "size":          item.value(forProperty: MPMediaItemPropertyAssetURL) != nil ? 0 : nil,
            "data":          (item.assetURL?.absoluteString),
            "uri":           (item.assetURL?.absoluteString),
            "trackNumber":   item.albumTrackNumber,
            "discNumber":    item.discNumber,
            "year":          nil,
            "dateAdded":     item.dateAdded != nil ? Int(item.dateAdded!.timeIntervalSince1970) : nil,
            "dateModified":  nil,
            "mimeType":      nil,
            "bitrate":       nil,
            "sampleRate":    nil,
            "channels":      nil,
            "composer":      item.composer,
            "isFavorite":    nil,
        ]
    }

    private static func sorted(
        items: [MPMediaItem],
        sortType: Int,
        orderType: Int
    ) -> [MPMediaItem] {
        let ascending = orderType == 0
        let sorted: [MPMediaItem]
        switch SongSortType(rawValue: sortType) ?? .title {
        case .title:
            sorted = items.sorted { compare($0.title, $1.title, ascending) }
        case .artist:
            sorted = items.sorted { compare($0.artist, $1.artist, ascending) }
        case .album:
            sorted = items.sorted { compare($0.albumTitle, $1.albumTitle, ascending) }
        case .duration:
            sorted = items.sorted {
                ascending
                    ? $0.playbackDuration < $1.playbackDuration
                    : $0.playbackDuration > $1.playbackDuration
            }
        case .dateAdded:
            sorted = items.sorted {
                let a = $0.dateAdded ?? Date.distantPast
                let b = $1.dateAdded ?? Date.distantPast
                return ascending ? a < b : a > b
            }
        case .size, .displayName:
            sorted = items.sorted { compare($0.title, $1.title, ascending) }
        }
        return sorted
    }

    private static func compare(_ a: String?, _ b: String?, _ ascending: Bool) -> Bool {
        let lhs = a ?? ""
        let rhs = b ?? ""
        return ascending
            ? lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
            : lhs.localizedCaseInsensitiveCompare(rhs) == .orderedDescending
    }
}
