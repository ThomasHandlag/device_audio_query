package com.thugbn.device_audio_query

import android.content.ContentResolver
import android.content.ContentUris
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import java.io.ByteArrayOutputStream
import androidx.core.net.toUri

/**
 * Retrieves embedded artwork for songs and albums.
 *
 * On API >= 29: uses [ContentResolver.loadThumbnail] for efficient resized thumbnails.
 * On API < 29: uses [MediaMetadataRetriever] for audio files,
 *              and reads the album art path from MediaStore for albums.
 */
class ArtworkQueryHandler(private val contentResolver: ContentResolver) {

    fun queryArtwork(
        id: Long,
        type: Int,
        format: Int,
        size: Int,
    ): ByteArray? {
        return try {
            if (type == 1) {
                // Album artwork
                queryAlbumArt(id, format, size)
            } else {
                // Audio/song artwork
                queryAudioArt(id, format, size)
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun queryAudioArt(id: Long, format: Int, size: Int): ByteArray? {
        val uri = ContentUris.withAppendedId(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            id,
        )
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Log.d("ArtworkQueryHandler", "Loading thumbnail for audio ID $id")
            loadThumbnail(uri, size, format)
        } else {
            extractEmbeddedArt(uri, format)
        }
    }

    private fun queryAlbumArt(albumId: Long, format: Int, size: Int): ByteArray? {
        val albumArtUri = "content://media/external/audio/albumart/$albumId".toUri()
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            loadThumbnail(albumArtUri, size, format)
        } else {
            bitmapToBytes(
                android.graphics.BitmapFactory.decodeFile(
                    getAlbumArtPath(albumId),
                ) ?: return null,
                format,
            )
        }
    }

    private fun getAlbumArtPath(albumId: Long): String? {
        val cursor = contentResolver.query(
            MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.Audio.Albums.ALBUM_ART),
            "${MediaStore.Audio.Albums._ID} = $albumId",
            null,
            null,
        )
        return cursor?.use {
            if (it.moveToFirst()) it.getString(0) else null
        }
    }

    @androidx.annotation.RequiresApi(Build.VERSION_CODES.Q)
    private fun loadThumbnail(uri: Uri, size: Int, format: Int): ByteArray {
        val bitmap = contentResolver.loadThumbnail(uri, Size(size, size), null)
        return bitmapToBytes(bitmap, format)
    }

    private fun extractEmbeddedArt(uri: Uri, format: Int): ByteArray? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(contentResolver.openFileDescriptor(uri, "r")?.fileDescriptor)
            val raw = retriever.embeddedPicture ?: return null
            val bitmap = android.graphics.BitmapFactory.decodeByteArray(raw, 0, raw.size)
            bitmapToBytes(bitmap, format)
        } catch (e: Exception) {
            Log.e("ArtworkQueryHandler", "Failed to extract embedded art: ${e.message}")
            null
        } finally {
            retriever.release()
        }
    }

    private fun bitmapToBytes(bitmap: Bitmap, format: Int): ByteArray {
        val compressFormat =
            if (format == 1) Bitmap.CompressFormat.PNG else Bitmap.CompressFormat.JPEG
        val quality = if (format == 1) 100 else 90
        val stream = ByteArrayOutputStream()
        bitmap.compress(compressFormat, quality, stream)
        return stream.toByteArray()
    }
}
