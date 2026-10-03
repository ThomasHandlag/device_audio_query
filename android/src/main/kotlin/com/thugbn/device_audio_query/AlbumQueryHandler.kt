package com.thugbn.device_audio_query

import android.content.ContentResolver
import android.database.Cursor
import android.os.Build
import android.provider.MediaStore

private val ALBUM_SORT_COLUMNS = arrayOf(
    MediaStore.Audio.Albums.ALBUM,        // 0 album
    MediaStore.Audio.Albums.ARTIST,       // 1 artist
    MediaStore.Audio.Albums.NUMBER_OF_SONGS, // 2 numOfSongs
    MediaStore.Audio.Albums.LAST_YEAR,    // 3 year
)

/** Queries album data from the Android MediaStore. */
class AlbumQueryHandler(private val contentResolver: ContentResolver) {

    fun queryAlbums(
        sortTypeIndex: Int,
        orderTypeIndex: Int,
    ): List<Map<String, Any?>> {
        val sortColumn = ALBUM_SORT_COLUMNS.getOrElse(sortTypeIndex) {
            MediaStore.Audio.Albums.ALBUM
        }
        val sortOrder = if (orderTypeIndex == 0) "ASC" else "DESC"

        val projection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            arrayOf(
                MediaStore.Audio.Albums._ID,
                MediaStore.Audio.Albums.ALBUM,
                MediaStore.Audio.Albums.ARTIST,
                "artist_id",
                MediaStore.Audio.Albums.NUMBER_OF_SONGS,
                MediaStore.Audio.Albums.ALBUM_ART,
                MediaStore.Audio.Albums.LAST_YEAR,
            )
        } else {
            arrayOf(
                MediaStore.Audio.Albums._ID,
                MediaStore.Audio.Albums.ALBUM,
                MediaStore.Audio.Albums.ARTIST,
                MediaStore.Audio.Albums.NUMBER_OF_SONGS,
                MediaStore.Audio.Albums.ALBUM_ART,
                MediaStore.Audio.Albums.LAST_YEAR,
            )
        }

        val results = mutableListOf<Map<String, Any?>>()
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            "$sortColumn $sortOrder",
        )

        cursor?.use {
            fun col(name: String) = it.getColumnIndex(name)
            val idCol = col(MediaStore.Audio.Albums._ID)
            val albumCol = col(MediaStore.Audio.Albums.ALBUM)
            val artistCol = col(MediaStore.Audio.Albums.ARTIST)
            val artistIdCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                col("artist_id")
            } else -1
            val numSongsCol = col(MediaStore.Audio.Albums.NUMBER_OF_SONGS)
            val albumArtCol = col(MediaStore.Audio.Albums.ALBUM_ART)
            val yearCol = col(MediaStore.Audio.Albums.LAST_YEAR)

            fun getStringSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getString(idx) else null
            fun getLongSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getLong(idx) else 0L
            fun getIntSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getInt(idx) else 0

            while (it.moveToNext()) {
                results.add(
                    mapOf(
                        "id" to getLongSafe(idCol),
                        "album" to getStringSafe(albumCol),
                        "artist" to getStringSafe(artistCol),
                        "artistId" to if (artistIdCol != -1) getLongSafe(artistIdCol) else null,
                        "numOfSongs" to getIntSafe(numSongsCol),
                        "albumArtUri" to getStringSafe(albumArtCol),
                        "year" to getIntSafe(yearCol),
                    ),
                )
            }
        }
        return results
    }
}
