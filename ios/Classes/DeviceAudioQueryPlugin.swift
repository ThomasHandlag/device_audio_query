import Flutter
import MediaPlayer
import UIKit

public class DeviceAudioQueryPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "device_audio_query",
            binaryMessenger: registrar.messenger()
        )
        let instance = DeviceAudioQueryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]

        switch call.method {
        case "requestPermission":
            AudioQueryHandler.requestPermission(result: result)

        case "querySongs":
            let sortType  = args["sortType"]  as? Int ?? 0
            let orderType = args["orderType"] as? Int ?? 0
            let path      = args["path"]      as? String
            DispatchQueue.global(qos: .userInitiated).async {
                let songs = AudioQueryHandler.querySongs(
                    sortType: sortType, orderType: orderType, path: path)
                DispatchQueue.main.async { result(songs) }
            }

        case "queryAlbums":
            let sortType  = args["sortType"]  as? Int ?? 0
            let orderType = args["orderType"] as? Int ?? 0
            DispatchQueue.global(qos: .userInitiated).async {
                let albums = AlbumQueryHandler.queryAlbums(
                    sortType: sortType, orderType: orderType)
                DispatchQueue.main.async { result(albums) }
            }

        case "queryArtists":
            let sortType  = args["sortType"]  as? Int ?? 0
            let orderType = args["orderType"] as? Int ?? 0
            DispatchQueue.global(qos: .userInitiated).async {
                let artists = ArtistQueryHandler.queryArtists(
                    sortType: sortType, orderType: orderType)
                DispatchQueue.main.async { result(artists) }
            }

        case "queryPlaylists":
            let sortType  = args["sortType"]  as? Int ?? 0
            let orderType = args["orderType"] as? Int ?? 0
            DispatchQueue.global(qos: .userInitiated).async {
                let playlists = PlaylistQueryHandler.queryPlaylists(
                    sortType: sortType, orderType: orderType)
                DispatchQueue.main.async { result(playlists) }
            }

        case "queryPlaylistMembers":
            let playlistId = args["playlistId"] as? Int ?? 0
            DispatchQueue.global(qos: .userInitiated).async {
                let members = PlaylistQueryHandler.queryPlaylistMembers(
                    playlistId: playlistId)
                DispatchQueue.main.async { result(members) }
            }

        case "queryAudiosWith":
            let from      = args["from"]      as? Int ?? 0
            let fromId    = args["fromId"]    as? Int ?? 0
            let sortType  = args["sortType"]  as? Int ?? 0
            let orderType = args["orderType"] as? Int ?? 0
            DispatchQueue.global(qos: .userInitiated).async {
                let songs = AudioQueryHandler.queryAudiosWith(
                    from: from, fromId: fromId,
                    sortType: sortType, orderType: orderType)
                DispatchQueue.main.async { result(songs) }
            }

        case "queryArtwork":
            let id     = args["id"]     as? Int ?? 0
            let type   = args["type"]   as? Int ?? 0
            let format = args["format"] as? Int ?? 0
            let size   = args["size"]   as? Int ?? 200
            DispatchQueue.global(qos: .userInitiated).async {
                let bytes = ArtworkQueryHandler.queryArtwork(
                    id: id, type: type, format: format, size: size)
                DispatchQueue.main.async { result(bytes) }
            }

        case "checkPermissionStatus":
            AudioQueryHandler.checkPermissionState(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
