package com.thugbn.device_audio_query

import android.content.ContentResolver
import android.content.ContentUris
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.MediaStore

/** Sort column constants matching the Dart [SongSortType] enum index order. */
private val SONG_SORT_COLUMNS = arrayOf(
    MediaStore.Audio.Media.TITLE,        // 0 title
    MediaStore.Audio.Media.ARTIST,       // 1 artist
    MediaStore.Audio.Media.ALBUM,        // 2 album
    MediaStore.Audio.Media.DURATION,     // 3 duration
    MediaStore.Audio.Media.DATE_ADDED,   // 4 dateAdded
    MediaStore.Audio.Media.SIZE,         // 5 size
    MediaStore.Audio.Media.DISPLAY_NAME, // 6 displayName
)

/**
 * Queries audio/song data from the Android MediaStore.
 */
class AudioQueryHandler(private val contentResolver: ContentResolver) {

    fun querySongs(
        sortTypeIndex: Int,
        orderTypeIndex: Int,
        uriTypeIndex: Int,
        path: String?,
    ): List<Map<String, Any?>> {
        val baseUri: Uri = if (uriTypeIndex == 0) {
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        } else {
            MediaStore.Audio.Media.INTERNAL_CONTENT_URI
        }

        val sortColumn = SONG_SORT_COLUMNS.getOrElse(sortTypeIndex) {
            MediaStore.Audio.Media.TITLE
        }
        val sortOrder = if (orderTypeIndex == 0) "ASC" else "DESC"

        val selection = buildSelection(path)
        val selectionArgs = if (path != null) arrayOf("$path%") else null

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ARTIST_ID,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.DATE_MODIFIED,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.BITRATE,
        )

        val results = mutableListOf<Map<String, Any?>>()
        val cursor: Cursor? = contentResolver.query(
            baseUri,
            projection,
            selection,
            selectionArgs,
            "$sortColumn $sortOrder",
        )

        cursor?.use {
            val idCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val artistIdCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST_ID)
            val albumCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val albumIdCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val durationCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val sizeCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val dataCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val trackCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.TRACK)
            val yearCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.YEAR)
            val dateAddedCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
            val dateModifiedCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_MODIFIED)
            val mimeCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.MIME_TYPE)
            val bitrateCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.BITRATE)

            while (it.moveToNext()) {
                val id = it.getLong(idCol)
                val contentUri = ContentUris.withAppendedId(baseUri, id)
                results.add(
                    mapOf(
                        "id" to id,
                        "title" to it.getString(titleCol),
                        "artist" to it.getString(artistCol),
                        "artistId" to it.getLong(artistIdCol),
                        "album" to it.getString(albumCol),
                        "albumId" to it.getLong(albumIdCol),
                        "duration" to it.getLong(durationCol),
                        "size" to it.getLong(sizeCol),
                        "data" to it.getString(dataCol),
                        "uri" to contentUri.toString(),
                        "trackNumber" to it.getInt(trackCol),
                        "year" to it.getInt(yearCol),
                        "dateAdded" to it.getLong(dateAddedCol),
                        "dateModified" to it.getLong(dateModifiedCol),
                        "mimeType" to it.getString(mimeCol),
                        "bitrate" to it.getLong(bitrateCol),
                    ),
                )
            }
        }
        return results
    }

    fun queryAudiosWith(
        from: Int,
        fromId: Long,
        sortTypeIndex: Int,
        orderTypeIndex: Int,
    ): List<Map<String, Any?>> {
        val extraSelection = when (from) {
            0 -> "${MediaStore.Audio.Media.ALBUM_ID} = $fromId"   // album
            1 -> "${MediaStore.Audio.Media.ARTIST_ID} = $fromId"  // artist
            3 -> "${MediaStore.Audio.Media.GENRE_ID} = $fromId"   // genre (API 30+)
            else -> null
        }

        if (from == 2) {
            // playlist — delegate to playlist handler
            return PlaylistQueryHandler(contentResolver)
                .queryPlaylistMembers(fromId)
                .mapNotNull { member ->
                    val songId = member["audioId"] as? Long ?: return@mapNotNull null
                    querySongById(songId)
                }
        }

        val sortColumn = SONG_SORT_COLUMNS.getOrElse(sortTypeIndex) {
            MediaStore.Audio.Media.TITLE
        }
        val sortOrder = if (orderTypeIndex == 0) "ASC" else "DESC"

        val baseSelection = buildSelection(null)
        val fullSelection = if (extraSelection != null) {
            if (baseSelection != null) "($baseSelection) AND ($extraSelection)" else extraSelection
        } else baseSelection

        val results = mutableListOf<Map<String, Any?>>()
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            null,
            fullSelection,
            null,
            "$sortColumn $sortOrder",
        )
        cursor?.use {
            while (it.moveToNext()) {
                results.add(cursorRowToMap(it))
            }
        }
        return results
    }

    private fun querySongById(id: Long): Map<String, Any?>? {
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val cursor = contentResolver.query(
            uri,
            null,
            "${MediaStore.Audio.Media._ID} = $id",
            null,
            null,
        )
        return cursor?.use {
            if (it.moveToFirst()) cursorRowToMap(it) else null
        }
    }

    private fun cursorRowToMap(cursor: Cursor): Map<String, Any?> {
        fun col(name: String) = cursor.getColumnIndex(name)
        val id = cursor.getLong(col(MediaStore.Audio.Media._ID))
        val baseUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        return mapOf(
            "id" to id,
            "title" to cursor.getString(col(MediaStore.Audio.Media.TITLE)),
            "artist" to cursor.getString(col(MediaStore.Audio.Media.ARTIST)),
            "artistId" to cursor.getLong(col(MediaStore.Audio.Media.ARTIST_ID)),
            "album" to cursor.getString(col(MediaStore.Audio.Media.ALBUM)),
            "albumId" to cursor.getLong(col(MediaStore.Audio.Media.ALBUM_ID)),
            "duration" to cursor.getLong(col(MediaStore.Audio.Media.DURATION)),
            "size" to cursor.getLong(col(MediaStore.Audio.Media.SIZE)),
            "data" to cursor.getString(col(MediaStore.Audio.Media.DATA)),
            "uri" to ContentUris.withAppendedId(baseUri, id).toString(),
            "trackNumber" to cursor.getInt(col(MediaStore.Audio.Media.TRACK)),
            "year" to cursor.getInt(col(MediaStore.Audio.Media.YEAR)),
            "dateAdded" to cursor.getLong(col(MediaStore.Audio.Media.DATE_ADDED)),
            "dateModified" to cursor.getLong(col(MediaStore.Audio.Media.DATE_MODIFIED)),
            "mimeType" to cursor.getString(col(MediaStore.Audio.Media.MIME_TYPE)),
            "bitrate" to cursor.getLong(col(MediaStore.Audio.Media.BITRATE)),
        )
    }

    private fun buildSelection(path: String?): String? {
        val isMusic = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        return if (path != null) {
            "$isMusic AND ${MediaStore.Audio.Media.DATA} LIKE ?"
        } else {
            isMusic
        }
    }
}
