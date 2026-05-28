package com.thugbn.device_audio_query

import android.content.ContentResolver
import android.database.Cursor
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

        val projection = arrayOf(
            MediaStore.Audio.Albums._ID,
            MediaStore.Audio.Albums.ALBUM,
            MediaStore.Audio.Albums.ARTIST,
            MediaStore.Audio.Albums.ARTIST_ID,
            MediaStore.Audio.Albums.NUMBER_OF_SONGS,
            MediaStore.Audio.Albums.ALBUM_ART,
            MediaStore.Audio.Albums.LAST_YEAR,
        )

        val results = mutableListOf<Map<String, Any?>>()
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            "$sortColumn $sortOrder",
        )

        cursor?.use {
            val idCol = it.getColumnIndexOrThrow(MediaStore.Audio.Albums._ID)
            val albumCol = it.getColumnIndexOrThrow(MediaStore.Audio.Albums.ALBUM)
            val artistCol = it.getColumnIndexOrThrow(MediaStore.Audio.Albums.ARTIST)
            val artistIdCol = it.getColumnIndexOrThrow(MediaStore.Audio.Albums.ARTIST_ID)
            val numSongsCol = it.getColumnIndexOrThrow(MediaStore.Audio.Albums.NUMBER_OF_SONGS)
            val albumArtCol = it.getColumnIndexOrThrow(MediaStore.Audio.Albums.ALBUM_ART)
            val yearCol = it.getColumnIndexOrThrow(MediaStore.Audio.Albums.LAST_YEAR)

            while (it.moveToNext()) {
                results.add(
                    mapOf(
                        "id" to it.getLong(idCol),
                        "album" to it.getString(albumCol),
                        "artist" to it.getString(artistCol),
                        "artistId" to it.getLong(artistIdCol),
                        "numOfSongs" to it.getInt(numSongsCol),
                        "albumArtUri" to it.getString(albumArtCol),
                        "year" to it.getInt(yearCol),
                    ),
                )
            }
        }
        return results
    }
}
