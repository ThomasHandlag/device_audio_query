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
            val idCol = it.getColumnIndexOrThrow(MediaStore.Audio.Artists._ID)
            val artistCol = it.getColumnIndexOrThrow(MediaStore.Audio.Artists.ARTIST)
            val numAlbumsCol = it.getColumnIndexOrThrow(MediaStore.Audio.Artists.NUMBER_OF_ALBUMS)
            val numTracksCol = it.getColumnIndexOrThrow(MediaStore.Audio.Artists.NUMBER_OF_TRACKS)

            while (it.moveToNext()) {
                results.add(
                    mapOf(
                        "id" to it.getLong(idCol),
                        "artist" to it.getString(artistCol),
                        "numberOfAlbums" to it.getInt(numAlbumsCol),
                        "numberOfTracks" to it.getInt(numTracksCol),
                    ),
                )
            }
        }
        return results
    }
}
