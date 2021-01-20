package com.mdreamfever.fstar

import android.os.Bundle
import android.os.PersistableBundle
import com.jaeger.library.StatusBarUtil
import com.qiniu.android.storage.Configuration
import com.qiniu.android.storage.UploadManager
import com.qiniu.android.storage.UploadOptions
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.mdreamfever.fstar/data"
    private val uploadChannel = "com.mdreamfever.fstar/qiniu"
    private val tag = "MainActivity"

    companion object {
        private val config = Configuration.Builder()
                .connectTimeout(90)              // 链接超时。默认90秒
                .useHttps(false)                  // 是否使用https上传域名
                .useConcurrentResumeUpload(true) // 使用并发上传，使用并发上传时，除最后一块大小不定外，其余每个块大小固定为4M，
                .concurrentTaskCount(3)          // 并发上传线程数量为3
                .responseTimeout(90)             // 服务器响应超时。默认90秒
//                .recorder(recorder)              // recorder分片上传时，已上传片记录器。默认null
//                .recorder(recorder, keyGen)      // keyGen 分片上传时，生成标识符，用于片记录器区分是那个文件的上传记录
//                .zone(FixedZone.zone2)           // 设置区域，不指定会自动选择。指定不同区域的上传域名、备用域名、备用IP。
                .build();
        val uploadManager = UploadManager(config)
    }

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        StatusBarUtil.setTransparent(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "saveCourse" -> {
                }
                "updateOpacity" -> {
                }
                else -> result.notImplemented()
            }
        }
        val uploadMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, uploadChannel)
        uploadMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "upload" -> {
                    val byteArray = call.argument<ByteArray>("data")
                    val key = call.argument<String>("key")
                    val token = call.argument<String>("token")
                    Log.d(tag, "byteArray: ${byteArray.toString()}, key: $key, token: $token")
                    uploadManager.put(byteArray, key, token, { key, info, response ->
                        result.success(mapOf("key" to key, "info" to info.toString(), "response" to response.toString()))
                    }, UploadOptions(null, null, false, { key, percent -> uploadMethodChannel.invokeMethod("progress", mapOf("key" to key, "percent" to percent)) }, null) {})
                }
                else -> result.notImplemented()
            }
        }
    }
}
