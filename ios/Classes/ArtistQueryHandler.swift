import MediaPlayer

private enum ArtistSortType: Int {
    case artist = 0, numOfTracks, numOfAlbums
}

enum ArtistQueryHandler {

    static func queryArtists(sortType: Int, orderType: Int) -> [[String: Any?]] {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return [] }

        let query = MPMediaQuery.artists()
        var collections = query.collections ?? []

        collections = sorted(collections: collections, sortType: sortType, orderType: orderType)

        return collections.map { collection -> [String: Any?] in
            let rep = collection.representativeItem
            let artistName = rep?.artist ?? "Unknown Artist"

            // Count albums for this artist
            let albumQuery = MPMediaQuery.albums()
            albumQuery.addFilterPredicate(
                MPMediaPropertyPredicate(
                    value: rep?.artistPersistentID ?? 0,
                    forProperty: MPMediaItemPropertyArtistPersistentID,
                    comparisonType: .equalTo
                )
            )
            let numAlbums = albumQuery.collections?.count ?? 0

            return [
                "id":             rep != nil ? Int(rep!.artistPersistentID) : 0,
                "artist":         artistName,
                "numberOfAlbums": numAlbums,
                "numberOfTracks": collection.items.count,
            ]
        }
    }

    private static func sorted(
        collections: [MPMediaItemCollection],
        sortType: Int,
        orderType: Int
    ) -> [MPMediaItemCollection] {
        let asc = orderType == 0
        switch ArtistSortType(rawValue: sortType) ?? .artist {
        case .artist:
            return collections.sorted {
                let a = $0.representativeItem?.artist ?? ""
                let b = $1.representativeItem?.artist ?? ""
                return asc
                    ? a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                    : a.localizedCaseInsensitiveCompare(b) == .orderedDescending
            }
        case .numOfTracks:
            return collections.sorted {
                asc ? $0.items.count < $1.items.count : $0.items.count > $1.items.count
            }
        case .numOfAlbums:
            return collections.sorted {
                asc ? $0.items.count < $1.items.count : $0.items.count > $1.items.count
            }
        }
    }
}
