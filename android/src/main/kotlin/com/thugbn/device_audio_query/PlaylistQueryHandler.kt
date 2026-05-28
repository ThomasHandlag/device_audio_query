package com.thugbn.device_audio_query

import android.content.ContentResolver
import android.content.ContentUris
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
            val idCol = it.getColumnIndexOrThrow(MediaStore.Audio.Playlists._ID)
            val nameCol = it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.NAME)
            val dateAddedCol = it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.DATE_ADDED)
            val dateModifiedCol =
                it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.DATE_MODIFIED)

            while (it.moveToNext()) {
                val playlistId = it.getLong(idCol)
                val memberCount = getMemberCount(playlistId)
                results.add(
                    mapOf(
                        "id" to playlistId,
                        "playlist" to it.getString(nameCol),
                        "numOfSongs" to memberCount,
                        "dateAdded" to it.getLong(dateAddedCol),
                        "dateModified" to it.getLong(dateModifiedCol),
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
            val idCol = it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.Members._ID)
            val audioIdCol = it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.Members.AUDIO_ID)
            val playOrderCol =
                it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.Members.PLAY_ORDER)
            val titleCol = it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.Members.TITLE)
            val artistCol = it.getColumnIndexOrThrow(MediaStore.Audio.Playlists.Members.ARTIST)

            while (it.moveToNext()) {
                results.add(
                    mapOf(
                        "id" to it.getLong(idCol),
                        "playlistId" to playlistId,
                        "audioId" to it.getLong(audioIdCol),
                        "playOrder" to it.getInt(playOrderCol),
                        "title" to it.getString(titleCol),
                        "artist" to it.getString(artistCol),
                    ),
                )
            }
        }
        return results
    }

    private fun getMemberCount(playlistId: Long): Int {
        val membersUri = MediaStore.Audio.Playlists.Members.getContentUri("external", playlistId)
        val cursor = contentResolver.query(membersUri, arrayOf(MediaStore.Audio.Playlists.Members._ID), null, null, null)
        val count = cursor?.count ?: 0
        cursor?.close()
        return count
    }
}
