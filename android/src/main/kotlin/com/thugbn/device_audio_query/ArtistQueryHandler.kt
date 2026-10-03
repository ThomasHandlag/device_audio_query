package com.thugbn.device_audio_query

import android.content.ContentResolver
import android.database.Cursor
import android.provider.MediaStore

private val ARTIST_SORT_COLUMNS = arrayOf(
    MediaStore.Audio.Artists.ARTIST,              // 0 artist
    MediaStore.Audio.Artists.NUMBER_OF_TRACKS,    // 1 numOfTracks
    MediaStore.Audio.Artists.NUMBER_OF_ALBUMS,    // 2 numOfAlbums
)

/** Queries artist data from the Android MediaStore. */
class ArtistQueryHandler(private val contentResolver: ContentResolver) {

    fun queryArtists(
        sortTypeIndex: Int,
        orderTypeIndex: Int,
    ): List<Map<String, Any?>> {
        val sortColumn = ARTIST_SORT_COLUMNS.getOrElse(sortTypeIndex) {
            MediaStore.Audio.Artists.ARTIST
        }
        val sortOrder = if (orderTypeIndex == 0) "ASC" else "DESC"

        val projection = arrayOf(
            MediaStore.Audio.Artists._ID,
            MediaStore.Audio.Artists.ARTIST,
            MediaStore.Audio.Artists.NUMBER_OF_ALBUMS,
            MediaStore.Audio.Artists.NUMBER_OF_TRACKS,
        )

        val results = mutableListOf<Map<String, Any?>>()
        val cursor: Cursor? = contentResolver.query(
            MediaStore.Audio.Artists.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            "$sortColumn $sortOrder",
        )

        cursor?.use {
            fun col(name: String) = it.getColumnIndex(name)
            val idCol = col(MediaStore.Audio.Artists._ID)
            val artistCol = col(MediaStore.Audio.Artists.ARTIST)
            val numAlbumsCol = col(MediaStore.Audio.Artists.NUMBER_OF_ALBUMS)
            val numTracksCol = col(MediaStore.Audio.Artists.NUMBER_OF_TRACKS)

            fun getStringSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getString(idx) else null
            fun getLongSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getLong(idx) else 0L
            fun getIntSafe(idx: Int) = if (idx != -1 && !it.isNull(idx)) it.getInt(idx) else 0

            while (it.moveToNext()) {
                results.add(
                    mapOf(
                        "id" to getLongSafe(idCol),
                        "artist" to getStringSafe(artistCol),
                        "numberOfAlbums" to getIntSafe(numAlbumsCol),
                        "numberOfTracks" to getIntSafe(numTracksCol),
                    ),
                )
            }
        }
        return results
    }
}
