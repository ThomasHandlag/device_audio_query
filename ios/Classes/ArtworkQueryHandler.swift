import MediaPlayer
import UIKit

/// Retrieves album/audio artwork bytes from the iOS media library.
///
/// [type]   — 0 = audio item, 1 = album
/// [format] — 0 = JPEG, 1 = PNG
enum ArtworkQueryHandler {

    static func queryArtwork(id: Int, type: Int, format: Int, size: Int) -> FlutterStandardTypedData? {
        guard MPMediaLibrary.authorizationStatus() == .authorized else { return nil }

        let query: MPMediaQuery
        let property: String

        if type == 1 {
            // Album artwork
            query = MPMediaQuery.albums()
            property = MPMediaItemPropertyAlbumPersistentID
        } else {
            // Song/audio artwork
            query = MPMediaQuery.songs()
            property = MPMediaItemPropertyPersistentID
        }

        query.addFilterPredicate(
            MPMediaPropertyPredicate(
                value: id,
                forProperty: property,
                comparisonType: .equalTo
            )
        )

        guard let item = query.items?.first,
              let artwork = item.artwork else {
            return nil
        }

        let targetSize = CGSize(width: size, height: size)
        let image = artwork.image(at: targetSize)
        guard let img = image else { return nil }

        let data: Data?
        if format == 1 {
            data = img.pngData()
        } else {
            data = img.jpegData(compressionQuality: 0.9)
        }

        guard let bytes = data else { return nil }
        return FlutterStandardTypedData(bytes: bytes)
    }
}
