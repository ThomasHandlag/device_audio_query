package com.thugbn.device_audio_query

import android.app.Activity
import android.content.ContentResolver
import android.content.pm.PackageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** DeviceAudioQueryPlugin — main Flutter plugin entry point for Android. */
class DeviceAudioQueryPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var contentResolver: ContentResolver
    private var activity: Activity? = null

    /** Pending result from a [requestPermission] call — resolved in [onRequestPermissionsResult]. */
    private var pendingPermissionResult: Result? = null

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    // ─── FlutterPlugin ───────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "device_audio_query")
        channel.setMethodCallHandler(this)
        contentResolver = binding.applicationContext.contentResolver
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    // ─── ActivityAware ───────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    // ─── RequestPermissionsResultListener ────────────────────────────────────

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != PermissionHandler.REQUEST_CODE) return false
        val pending = pendingPermissionResult ?: return false
        pendingPermissionResult = null

        val act = activity ?: run {
            pending.success(1)
            return true
        }

        val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (granted) {
            pending.success(0)
        } else {
            val status = PermissionHandler.checkStatus(act)
            pending.success(status)
        }
        return true
    }

    // ─── MethodCallHandler ───────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "requestPermission" -> handleRequestPermission(result)
            "querySongs" -> handleQuerySongs(call, result)
            "queryAlbums" -> handleQueryAlbums(call, result)
            "queryArtists" -> handleQueryArtists(call, result)
            "queryPlaylists" -> handleQueryPlaylists(call, result)
            "queryPlaylistMembers" -> handleQueryPlaylistMembers(call, result)
            "queryAudiosWith" -> handleQueryAudiosWith(call, result)
            "queryArtwork" -> handleQueryArtwork(call, result)
            "checkPermissionStatus" -> checkPermissionStatus(result)
            else -> result.notImplemented()
        }
    }

    // ─── Handlers ────────────────────────────────────────────────────────────

    private fun handleRequestPermission(result: Result) {
        val act = activity ?: run {
            result.success(1)
            return
        }
        val current = PermissionHandler.checkStatus(act)
        if (current == 0) {
            result.success(0)
            return
        }
        // Store the result callback to be resolved via onRequestPermissionsResult
        pendingPermissionResult = result
        PermissionHandler(act).requestPermission()
    }

    private fun checkPermissionStatus(result: Result) {
        val act = activity ?: run {
            result.success(1)
            return
        }

        val current = PermissionHandler.checkStatus(act)
        if (current == 0) {
            result.success(0)
            return
        } else {
            result.success(1)
            return
        }
    }

    private fun handleQuerySongs(call: MethodCall, result: Result) {
        val sortType = call.argument<Int>("sortType") ?: 0
        val orderType = call.argument<Int>("orderType") ?: 0
        val uriType = call.argument<Int>("uriType") ?: 0
        val path = call.argument<String>("path")

        scope.launch {
            try {
                val songs = withContext(Dispatchers.IO) {
                    AudioQueryHandler(contentResolver)
                        .querySongs(sortType, orderType, uriType, path)
                }
                result.success(songs)
            } catch (e: Exception) {
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    private fun handleQueryAlbums(call: MethodCall, result: Result) {
        val sortType = call.argument<Int>("sortType") ?: 0
        val orderType = call.argument<Int>("orderType") ?: 0

        scope.launch {
            try {
                val albums = withContext(Dispatchers.IO) {
                    AlbumQueryHandler(contentResolver).queryAlbums(sortType, orderType)
                }
                result.success(albums)
            } catch (e: Exception) {
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    private fun handleQueryArtists(call: MethodCall, result: Result) {
        val sortType = call.argument<Int>("sortType") ?: 0
        val orderType = call.argument<Int>("orderType") ?: 0

        scope.launch {
            try {
                val artists = withContext(Dispatchers.IO) {
                    ArtistQueryHandler(contentResolver).queryArtists(sortType, orderType)
                }
                result.success(artists)
            } catch (e: Exception) {
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    private fun handleQueryPlaylists(call: MethodCall, result: Result) {
        val sortType = call.argument<Int>("sortType") ?: 0
        val orderType = call.argument<Int>("orderType") ?: 0

        scope.launch {
            try {
                val playlists = withContext(Dispatchers.IO) {
                    PlaylistQueryHandler(contentResolver).queryPlaylists(sortType, orderType)
                }
                result.success(playlists)
            } catch (e: Exception) {
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    private fun handleQueryPlaylistMembers(call: MethodCall, result: Result) {
        val playlistId = (call.argument<Int>("playlistId") ?: 0).toLong()

        scope.launch {
            try {
                val members = withContext(Dispatchers.IO) {
                    PlaylistQueryHandler(contentResolver).queryPlaylistMembers(playlistId)
                }
                result.success(members)
            } catch (e: Exception) {
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    private fun handleQueryAudiosWith(call: MethodCall, result: Result) {
        val from = call.argument<Int>("from") ?: 0
        val fromId = (call.argument<Int>("fromId") ?: 0).toLong()
        val sortType = call.argument<Int>("sortType") ?: 0
        val orderType = call.argument<Int>("orderType") ?: 0

        scope.launch {
            try {
                val songs = withContext(Dispatchers.IO) {
                    AudioQueryHandler(contentResolver)
                        .queryAudiosWith(from, fromId, sortType, orderType)
                }
                result.success(songs)
            } catch (e: Exception) {
                result.error("QUERY_ERROR", e.message, null)
            }
        }
    }

    private fun handleQueryArtwork(call: MethodCall, result: Result) {
        val id = call.argument<Int>("id") ?: 0
        val type = call.argument<Int>("type") ?: 0
        val format = call.argument<Int>("format") ?: 0
        val size = call.argument<Int>("size") ?: 200

        scope.launch {
            try {
                val bytes = withContext(Dispatchers.IO) {
                    ArtworkQueryHandler(contentResolver).queryArtwork(
                        id.toLong(),
                        type,
                        format,
                        size
                    )
                }
                result.success(bytes)
            } catch (e: Exception) {
                result.error("ARTWORK_ERROR", e.message, null)
            }
        }
    }
}
