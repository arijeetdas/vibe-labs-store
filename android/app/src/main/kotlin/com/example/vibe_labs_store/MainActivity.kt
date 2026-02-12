package com.arijeet.vibelabs.store

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "vibe_labs/app_launcher"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            val pkg = call.argument<String>("package")

            when (call.method) {

                "openApp" -> {
                    try {
                        if (pkg == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        val launchIntent =
                            applicationContext.packageManager
                                .getLaunchIntentForPackage(pkg)

                        if (launchIntent != null) {
                            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            applicationContext.startActivity(launchIntent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }

                    } catch (e: Exception) {
                        result.success(false)
                    }
                }

                "uninstallApp" -> {
                    try {
                        if (pkg == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$pkg")
                        }
                        startActivity(intent)
                        result.success(true)

                    
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }

                "isInstalled" -> {
                    try {
                        if (pkg == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        applicationContext.packageManager.getPackageInfo(pkg, 0)
                        result.success(true)

                    } catch (e: PackageManager.NameNotFoundException) {
                        result.success(false)
                    }
                }

                "getVersionCode" -> {
                    try {
                        if (pkg == null) {
                            result.success(0)
                            return@setMethodCallHandler
                        }

                        val info =
                            applicationContext.packageManager
                                .getPackageInfo(pkg, 0)

                        val versionCode =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                info.longVersionCode.toInt()
                            } else {
                                @Suppress("DEPRECATION")
                                info.versionCode
                            }

                        result.success(versionCode)

                    } catch (e: Exception) {
                        result.success(0)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
