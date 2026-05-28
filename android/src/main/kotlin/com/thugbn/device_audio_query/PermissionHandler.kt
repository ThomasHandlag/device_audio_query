package com.thugbn.device_audio_query

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

/**
 * Handles runtime permission requests for audio/media access.
 *
 * On API < 33 we request READ_EXTERNAL_STORAGE.
 * On API >= 33 we request READ_MEDIA_AUDIO.
 */
class PermissionHandler(private val activity: Activity) {

    companion object {
        const val REQUEST_CODE = 7001

        /** Returns 0=granted, 1=denied, 2=deniedForever */
        fun checkStatus(activity: Activity): Int {
            val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                Manifest.permission.READ_MEDIA_AUDIO
            } else {
                Manifest.permission.READ_EXTERNAL_STORAGE
            }
            return when {
                ContextCompat.checkSelfPermission(
                    activity,
                    permission,
                ) == PackageManager.PERMISSION_GRANTED -> 0

                ActivityCompat.shouldShowRequestPermissionRationale(activity, permission) -> 1
                else -> 2
            }
        }
    }

    /** Asynchronously requests the permission and returns 0/1/2. */
    fun requestPermission(): Int {
        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

        if (ContextCompat.checkSelfPermission(
                activity,
                permission,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return 0
        }

        ActivityCompat.requestPermissions(activity, arrayOf(permission), REQUEST_CODE)
        // Re-check synchronously after the dialog dismissed is handled by the plugin's
        // onRequestPermissionsResult. We return 1 (denied) as optimistic value; the
        // plugin overrides the result via the pending result callback.
        return 1
    }
}
