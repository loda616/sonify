package com.example.sonify

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Remove the splash screen before showing the Flutter UI
        setTheme(android.R.style.Theme_Black_NoTitleBar)
        super.onCreate(savedInstanceState)
    }
}