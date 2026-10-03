package com.thugbn.device_audio_query

import android.content.ContentResolver
import android.database.Cursor
import android.provider.MediaStore

private val PLAYLIST_SORT_COLUMNS = arrayOf(
    MediaStore.Audio.Playlists.NAME,          // 0 playlist
    MediaStore.Audio.Playlists.DATE_ADDED,    // 1 dateAdded
    MediaStore.Audio.Playlists.DATE_MODIFIED, // 2 dateModified
)

/**
 * Queries playlist data from the Android MediaStore.
 *
 * Note: MediaStore playlists were soft-deprecated in API 29 but still work
 * on most devices. Best-effort implementation is provided.
 */
class PlaylistQueryHandler(private val contentResolver: ContentResolver) {

    fun queryPlaylists(
        sortTypeIndex: Int,
        orderTypeIndex: Int,
    ): List<Map<String, Any?>> {
        val sortColumn = PLAYLIST_SORT_COLUMNS.getOrElse(sortTypeIndex) {
            MediaStore.Audio.Playlists.NAME
        }
        val sortOrder = if (orderTypeIndex == 0) "ASC" else "DESC"

        val projection = arrayOf(
            MediaStore.Audio.Playlists._ID,
            MediaStore.Audio.Playlists.NAME,
            MediaStore.Audio.Playlists.DATE_ADDED,
            MediaStore.Audio.Playlists.DATE_MODIFIED,
        )

        val results = mutableListOf<Map<String, Any?>>()
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Audio.Playlists.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            "$sortColumn $sortOrder",
        )

        cursor?.use {
            fun col(name: String) = it.getColumnIndex(name)
            val idCol = col(MediaStore.Audio.Playlists._ID)
            val nameCol = col(MediaStore.Audio.Playlists.NAME)
            val dateAddedCol = col(MediaStore.Audio.Playlists.DATE_ADDED)
            val dateModifiedCol = col(MediaStore.Audio.Playlists.DATE_MODIFIED)

            fun getStringSafe(idx: Int) =
                if (idx != -1 && !it.isNull(idx)) it.getString(idx) else null

            fun getLongSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getLong(idx) else 0L

            while (it.moveToNext()) {
                val playlistId = getLongSafe(idCol)
                val memberCount = getMemberCount(playlistId)
                results.add(
                    mapOf(
                        "id" to playlistId,
                        "playlist" to getStringSafe(nameCol),
                        "numOfSongs" to memberCount,
                        "dateAdded" to getLongSafe(dateAddedCol),
                        "dateModified" to getLongSafe(dateModifiedCol),
                    ),
                )
            }
        }
        return results
    }

    fun queryPlaylistMembers(playlistId: Long): List<Map<String, Any?>> {
        val membersUri = MediaStore.Audio.Playlists.Members.getContentUri("external", playlistId)

        val projection = arrayOf(
            MediaStore.Audio.Playlists.Members._ID,
            MediaStore.Audio.Playlists.Members.AUDIO_ID,
            MediaStore.Audio.Playlists.Members.PLAY_ORDER,
            MediaStore.Audio.Playlists.Members.TITLE,
            MediaStore.Audio.Playlists.Members.ARTIST,
        )

        val results = mutableListOf<Map<String, Any?>>()
        val cursor: Cursor? = contentResolver.query(
            membersUri,
            projection,
            null,
            null,
            "${MediaStore.Audio.Playlists.Members.PLAY_ORDER} ASC",
        )

        cursor?.use {
            fun col(name: String) = it.getColumnIndex(name)
            val idCol = col(MediaStore.Audio.Playlists.Members._ID)
            val audioIdCol = col(MediaStore.Audio.Playlists.Members.AUDIO_ID)
            val playOrderCol = col(MediaStore.Audio.Playlists.Members.PLAY_ORDER)
            val titleCol = col(MediaStore.Audio.Playlists.Members.TITLE)
            val artistCol = col(MediaStore.Audio.Playlists.Members.ARTIST)

            fun getStringSafe(idx: Int) =
                if (idx != -1 && !it.isNull(idx)) it.getString(idx) else null

            fun getLongSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getLong(idx) else 0L
            fun getIntSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getInt(idx) else 0

            while (it.moveToNext()) {
                results.add(
                    mapOf(
                        "id" to getLongSafe(idCol),
                        "playlistId" to playlistId,
                        "audioId" to getLongSafe(audioIdCol),
                        "playOrder" to getIntSafe(playOrderCol),
                        "title" to getStringSafe(titleCol),
                        "artist" to getStringSafe(artistCol),
                    ),
                )
            }
        }
        return results
    }

    private fun getMemberCount(playlistId: Long): Int {
        val membersUri = MediaStore.Audio.Playlists.Members.getContentUri("external", playlistId)
        val cursor = contentResolver.query(
            membersUri,
            arrayOf(MediaStore.Audio.Playlists.Members._ID),
            null,
            null,
            null
        )
        val count = cursor?.count ?: 0
        cursor?.close()
        return count
    }
}
