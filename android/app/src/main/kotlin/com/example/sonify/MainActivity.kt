package com.example.sonify

import android.media.AudioFormat
import android.media.AudioRecord
import android.os.Build
import android.os.Bundle
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.example.sonify/tts_capture"
    private var audioRecord: AudioRecord? = null
    private var isRecording = false

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(android.R.style.Theme_Black_NoTitleBar)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startCapture" -> {
                    val path = call.argument<String>("path") ?: ""
                    try {
                        startCapture(path)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CAPTURE_FAILED", e.message, null)
                    }
                }
                "stopCapture" -> {
                    try {
                        stopCapture()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("STOP_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startCapture(path: String) {
        val sampleRate = 44100
        val channelConfig = AudioFormat.CHANNEL_IN_MONO
        val audioFormat = AudioFormat.ENCODING_PCM_16BIT
        val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)

        // PLAYBACK_CAPTURE = 10 (API 29+), MIC = 1
        val audioSource = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) 10 else 1

        audioRecord = AudioRecord(audioSource, sampleRate, channelConfig, audioFormat, bufferSize)
        audioRecord?.startRecording()
        isRecording = true

        Thread {
            val file = File(path)
            file.parentFile?.mkdirs()
            val outputStream = FileOutputStream(file)
            val buffer = ByteArray(bufferSize)

            while (isRecording) {
                val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                if (bytesRead > 0) {
                    outputStream.write(buffer, 0, bytesRead)
                }
            }

            outputStream.close()
        }.start()
    }

    private fun stopCapture() {
        isRecording = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
    }
}