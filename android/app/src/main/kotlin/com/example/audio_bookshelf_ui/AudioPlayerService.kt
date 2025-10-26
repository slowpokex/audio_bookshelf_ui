package com.example.audio_bookshelf_ui

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class AudioPlayerService : Service() {
    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "audio_player_channel"
        private const val CHANNEL_NAME = "Audio Player"
        private const val METHOD_CHANNEL = "audio_player_service"
        
        const val ACTION_PLAY = "com.example.audio_bookshelf_ui.PLAY"
        const val ACTION_PAUSE = "com.example.audio_bookshelf_ui.PAUSE"
        const val ACTION_STOP = "com.example.audio_bookshelf_ui.STOP"
        const val ACTION_NEXT = "com.example.audio_bookshelf_ui.NEXT"
        const val ACTION_PREVIOUS = "com.example.audio_bookshelf_ui.PREVIOUS"
        const val ACTION_SEEK = "com.example.audio_bookshelf_ui.SEEK"
    }

    private val binder = AudioPlayerBinder()
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var methodChannel: MethodChannel? = null
    private var flutterEngine: FlutterEngine? = null
    private var lastNotificationUpdate = 0L
    private val notificationUpdateInterval = 1000L // 1 second minimum between updates
    
    // Current playback state
    private var currentTitle = ""
    private var currentArtist = ""
    private var currentAlbum = ""
    private var currentPosition = 0L
    private var currentDuration = 0L
    private var isPlaying = false

    inner class AudioPlayerBinder : Binder() {
        fun getService(): AudioPlayerService = this@AudioPlayerService
    }

    override fun onCreate() {
        super.onCreate()
        initializeAudioFocus()
        initializeWakeLock()
        initializeFlutterEngine()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_PLAY -> handlePlay()
            ACTION_PAUSE -> handlePause()
            ACTION_STOP -> handleStop()
            ACTION_NEXT -> handleNext()
            ACTION_PREVIOUS -> handlePrevious()
            ACTION_SEEK -> {
                val position = intent.getLongExtra("position", 0L)
                handleSeek(position)
            }
        }
        
        // Handle method channel calls
        when (intent?.getStringExtra("action")) {
            "updateMetadata" -> {
                val title = intent.getStringExtra("title") ?: ""
                val artist = intent.getStringExtra("artist") ?: ""
                val album = intent.getStringExtra("album") ?: ""
                val duration = intent.getLongExtra("duration", 0L)
                updateMetadata(title, artist, album, duration)
            }
            "updatePlaybackState" -> {
                val isPlaying = intent.getBooleanExtra("isPlaying", false)
                val position = intent.getLongExtra("position", 0L)
                val duration = intent.getLongExtra("duration", 0L)
                updatePlaybackState(isPlaying, position, duration)
            }
        }
        
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onDestroy() {
        super.onDestroy()
        releaseAudioFocus()
        releaseWakeLock()
        stopForeground(true)
    }

    private fun initializeFlutterEngine() {
        flutterEngine = FlutterEngineCache.getInstance().get("audio_player_engine")
        if (flutterEngine == null) {
            flutterEngine = FlutterEngine(this)
            flutterEngine?.dartExecutor?.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            FlutterEngineCache.getInstance().put("audio_player_engine", flutterEngine)
        }
        
        methodChannel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, METHOD_CHANNEL)
        
        // Set up method call handler
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    startForegroundService()
                    result.success(null)
                }
                "stopService" -> {
                    stopForeground(true)
                    stopSelf()
                    result.success(null)
                }
                "updateMetadata" -> {
                    val title = call.argument<String>("title") ?: ""
                    val artist = call.argument<String>("artist") ?: ""
                    val album = call.argument<String>("album") ?: ""
                    val duration = call.argument<Long>("duration") ?: 0L
                    updateMetadata(title, artist, album, duration)
                    result.success(null)
                }
                "updatePlaybackState" -> {
                    val isPlaying = call.argument<Boolean>("isPlaying") ?: false
                    val position = call.argument<Long>("position") ?: 0L
                    val duration = call.argument<Long>("duration") ?: 0L
                    updatePlaybackState(isPlaying, position, duration)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeAudioFocus() {
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
                
            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(audioAttributes)
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener(audioFocusChangeListener)
                .build()
        }
    }

    private fun initializeWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "AudioBookshelf::AudioPlayerService"
        )
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_MAX // Changed to MAX importance
            ).apply {
                description = "Audio player controls"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                enableLights(true)
                lightColor = android.graphics.Color.BLUE
                enableVibration(false)
                setSound(null, null)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        // Check notification permissions
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            if (!notificationManager.areNotificationsEnabled()) {
                // Notifications are disabled, try to show anyway
                android.util.Log.w("AudioPlayerService", "Notifications are disabled")
            }
        }
        
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        
        // Force show notification in notification manager
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(NOTIFICATION_ID, notification)
        
        android.util.Log.d("AudioPlayerService", "Notification created and shown with ID: $NOTIFICATION_ID")
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val playAction = NotificationCompat.Action(
            android.R.drawable.ic_media_play,
            "Play",
            createPendingIntent(ACTION_PLAY)
        )

        val pauseAction = NotificationCompat.Action(
            android.R.drawable.ic_media_pause,
            "Pause",
            createPendingIntent(ACTION_PAUSE)
        )

        val stopAction = NotificationCompat.Action(
            android.R.drawable.ic_menu_close_clear_cancel,
            "Stop",
            createPendingIntent(ACTION_STOP)
        )

        val nextAction = NotificationCompat.Action(
            android.R.drawable.ic_media_next,
            "Next",
            createPendingIntent(ACTION_NEXT)
        )

        val previousAction = NotificationCompat.Action(
            android.R.drawable.ic_media_previous,
            "Previous",
            createPendingIntent(ACTION_PREVIOUS)
        )

        // Calculate progress percentage
        val progressPercentage = if (currentDuration > 0) {
            ((currentPosition * 100) / currentDuration).toInt()
        } else {
            0
        }

        // Format time display
        val currentTimeFormatted = formatTime(currentPosition)
        val totalTimeFormatted = formatTime(currentDuration)
        val timeDisplay = "$currentTimeFormatted / $totalTimeFormatted"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(currentTitle.ifEmpty { "Audio Bookshelf" })
            .setContentText(currentArtist.ifEmpty { "Now Playing" })
            .setSubText(timeDisplay)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_TRANSPORT)
            .setPriority(NotificationCompat.PRIORITY_MAX) // Changed to MAX priority
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(false)
            .setShowWhen(true)
            .setWhen(System.currentTimeMillis())
            .setStyle(androidx.media.app.NotificationCompat.MediaStyle()
                .setShowActionsInCompactView(0, 1, 2)
                .setShowCancelButton(true)
                .setCancelButtonIntent(createPendingIntent(ACTION_STOP)))
            .addAction(previousAction)
            .addAction(if (isPlaying) pauseAction else playAction)
            .addAction(stopAction)
            .addAction(nextAction)
            .setProgress(100, progressPercentage, false)
            .build()
    }

    private fun createPendingIntent(action: String): PendingIntent {
        val intent = Intent(this, AudioPlayerService::class.java).apply {
            this.action = action
        }
        return PendingIntent.getService(
            this, action.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun updateNotification() {
        val notification = createNotification()
        val notificationManager = NotificationManagerCompat.from(this)
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun requestAudioFocus(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { request ->
                audioManager?.requestAudioFocus(request) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
            } ?: false
        } else {
            @Suppress("DEPRECATION")
            audioManager?.requestAudioFocus(
                audioFocusChangeListener,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun releaseAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { request ->
                audioManager?.abandonAudioFocusRequest(request)
            }
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus(audioFocusChangeListener)
        }
    }

    private val audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        when (focusChange) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                // Resume playback
                methodChannel?.invokeMethod("resumePlayback", null)
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                // Stop playback
                methodChannel?.invokeMethod("pausePlayback", null)
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                // Pause playback temporarily
                methodChannel?.invokeMethod("pausePlayback", null)
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                // Lower volume
                methodChannel?.invokeMethod("lowerVolume", null)
            }
        }
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld != true) {
            wakeLock?.acquire(10*60*1000L /*10 minutes*/)
        }
    }

    private fun releaseWakeLock() {
        if (wakeLock?.isHeld == true) {
            wakeLock?.release()
        }
    }

    // Action handlers
    private fun handlePlay() {
        if (requestAudioFocus()) {
            acquireWakeLock()
            startForegroundService()
            methodChannel?.invokeMethod("play", null)
        }
    }

    private fun handlePause() {
        methodChannel?.invokeMethod("pause", null)
    }

    private fun handleStop() {
        methodChannel?.invokeMethod("stop", null)
        releaseAudioFocus()
        releaseWakeLock()
        stopForeground(true)
        stopSelf()
    }

    private fun handleNext() {
        methodChannel?.invokeMethod("next", null)
    }

    private fun handlePrevious() {
        methodChannel?.invokeMethod("previous", null)
    }

    private fun handleSeek(position: Long) {
        methodChannel?.invokeMethod("seek", mapOf("position" to position))
    }

    fun updateMetadata(title: String, artist: String, album: String, duration: Long) {
        currentTitle = title
        currentArtist = artist
        currentAlbum = album
        currentDuration = duration
        // Update notification with metadata (throttled)
        updateNotificationThrottled()
    }

    fun updatePlaybackState(isPlaying: Boolean, position: Long, duration: Long) {
        this.isPlaying = isPlaying
        currentPosition = position
        currentDuration = duration
        // Update notification with playback state (throttled)
        updateNotificationThrottled()
    }
    
    private fun updateNotificationThrottled() {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastNotificationUpdate >= notificationUpdateInterval) {
            updateNotification()
            lastNotificationUpdate = currentTime
        }
    }

    private fun formatTime(timeMs: Long): String {
        val totalSeconds = timeMs / 1000
        val hours = totalSeconds / 3600
        val minutes = (totalSeconds % 3600) / 60
        val seconds = totalSeconds % 60

        return if (hours > 0) {
            String.format("%d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format("%d:%02d", minutes, seconds)
        }
    }
}