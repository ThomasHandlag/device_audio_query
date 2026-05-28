import MediaPlayer

private enum AlbumSortType: Int {
    case album = 0, artist, numOfSongs, year
}

enum AlbumQueryHandler {

    static func queryAlbums(sortType: Int, orderType: Int) -> [[String: Any?]] {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return [] }

        let query = MPMediaQuery.albums()
        var collections = query.collections ?? []

        collections = sorted(collections: collections, sortType: sortType, orderType: orderType)

        return collections.map { collection -> [String: Any?] in
            let rep = collection.representativeItem
            return [
                "id":          Int(rep?.albumPersistentID ?? 0),
                "album":       rep?.albumTitle ?? "Unknown Album",
                "artist":      rep?.albumArtist ?? rep?.artist,
                "artistId":    rep != nil ? Int(rep!.artistPersistentID) : nil,
                "numOfSongs":  collection.items.count,
                "albumArtUri": nil,   // artwork is fetched via queryArtwork
                "year":        nil,
            ]
        }
    }

    private static func sorted(
        collections: [MPMediaItemCollection],
        sortType: Int,
        orderType: Int
    ) -> [MPMediaItemCollection] {
        let asc = orderType == 0
        switch AlbumSortType(rawValue: sortType) ?? .album {
        case .album:
            return collections.sorted {
                let a = $0.representativeItem?.albumTitle ?? ""
                let b = $1.representativeItem?.albumTitle ?? ""
                return asc
                    ? a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                    : a.localizedCaseInsensitiveCompare(b) == .orderedDescending
            }
        case .artist:
            return collections.sorted {
                let a = $0.representativeItem?.albumArtist ?? $0.representativeItem?.artist ?? ""
                let b = $1.representativeItem?.albumArtist ?? $1.representativeItem?.artist ?? ""
                return asc
                    ? a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                    : a.localizedCaseInsensitiveCompare(b) == .orderedDescending
            }
        case .numOfSongs:
            return collections.sorted {
                asc ? $0.items.count < $1.items.count : $0.items.count > $1.items.count
            }
        case .year:
            return collections.sorted { _, _ in asc }
        }
    }
}
