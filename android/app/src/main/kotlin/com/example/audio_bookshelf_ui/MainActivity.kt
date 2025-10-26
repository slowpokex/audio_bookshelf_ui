package com.example.audio_bookshelf_ui

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "audio_player_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val intent = Intent(this, AudioPlayerService::class.java)
                    startService(intent)
                    result.success(null)
                }
                "stopService" -> {
                    val intent = Intent(this, AudioPlayerService::class.java)
                    stopService(intent)
                    result.success(null)
                }
                "updateMetadata" -> {
                    val title = call.argument<String>("title") ?: ""
                    val artist = call.argument<String>("artist") ?: ""
                    val album = call.argument<String>("album") ?: ""
                    val duration = (call.argument<Number>("duration")?.toLong()) ?: 0L
                    
                    val serviceIntent = Intent(this, AudioPlayerService::class.java)
                    serviceIntent.putExtra("action", "updateMetadata")
                    serviceIntent.putExtra("title", title)
                    serviceIntent.putExtra("artist", artist)
                    serviceIntent.putExtra("album", album)
                    serviceIntent.putExtra("duration", duration)
                    startService(serviceIntent)
                    result.success(null)
                }
                "updatePlaybackState" -> {
                    val isPlaying = call.argument<Boolean>("isPlaying") ?: false
                    val position = (call.argument<Number>("position")?.toLong()) ?: 0L
                    val duration = (call.argument<Number>("duration")?.toLong()) ?: 0L
                    
                    val serviceIntent = Intent(this, AudioPlayerService::class.java)
                    serviceIntent.putExtra("action", "updatePlaybackState")
                    serviceIntent.putExtra("isPlaying", isPlaying)
                    serviceIntent.putExtra("position", position)
                    serviceIntent.putExtra("duration", duration)
                    startService(serviceIntent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
