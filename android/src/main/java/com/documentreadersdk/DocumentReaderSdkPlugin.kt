package com.documentreadersdk

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Matrix
import android.os.SystemClock
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.camera.core.AspectRatio
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.core.UseCaseGroup
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.faceplugin.documentreadersdk.DocumentReaderSDK
import java.io.File
import java.util.concurrent.Executors

@CapacitorPlugin(name = "DocumentReaderSdk")
class DocumentReaderSdkPlugin : Plugin() {

  private val executor = Executors.newSingleThreadExecutor()
  private val analysisExecutor = Executors.newSingleThreadExecutor()
  @Volatile private var lastLiveBitmap: Bitmap? = null
  @Volatile private var analysisBusy = false
  @Volatile private var lastAnalysisMs = 0L

  private var cameraProvider: ProcessCameraProvider? = null
  private var previewView: PreviewView? = null
  private var previewHost: FrameLayout? = null

  @PluginMethod
  fun getMachineCode(call: PluginCall) {
    executor.execute {
      try {
        val mc = DocumentReaderSDK.getMachineCode(context.applicationContext) ?: ""
        val ret = JSObject()
        ret.put("value", mc)
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, "E_MACHINE_CODE", t)
      }
    }
  }

  @PluginMethod
  fun setActivation(call: PluginCall) {
    val license = call.getString("license")
    if (license.isNullOrBlank()) {
      call.reject("license is required", "E_ACTIVATION")
      return
    }
    executor.execute {
      try {
        val code = DocumentReaderSDK.setActivation(context.applicationContext, license)
        val ret = JSObject()
        ret.put("value", code)
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, "E_ACTIVATION", t)
      }
    }
  }

  @PluginMethod
  fun init(call: PluginCall) {
    executor.execute {
      try {
        val code = DocumentReaderSDK.init(context.applicationContext)
        val ret = JSObject()
        ret.put("value", code)
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, "E_INIT", t)
      }
    }
  }

  @PluginMethod
  fun deinit(call: PluginCall) {
    executor.execute {
      try {
        DocumentReaderSDK.deinit()
        call.resolve()
      } catch (t: Throwable) {
        reject(call, "E_DEINIT", t)
      }
    }
  }

  @PluginMethod
  fun startNewSession(call: PluginCall) {
    val optionsJson = call.getString("optionsJson")
    executor.execute {
      try {
        val json = if (optionsJson.isNullOrBlank()) {
          DocumentReaderSDK.startNewSession()
        } else {
          DocumentReaderSDK.startNewSession(optionsJson)
        }
        val ret = JSObject()
        ret.put("value", json ?: "")
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, "E_SESSION", t)
      }
    }
  }

  @PluginMethod
  fun locateDocument(call: PluginCall) {
    val imageUri = call.getString("image")
    if (imageUri.isNullOrBlank()) {
      call.reject("image is required", "E_IMAGE")
      return
    }
    executor.execute {
      try {
        val bitmap = loadBitmap(imageUri)
          ?: run {
            call.reject("Could not decode image: $imageUri", "E_IMAGE")
            return@execute
          }
        val upright = uprightPortrait(bitmap)
        val locateBmp = scaleMax(upright, LOCATE_MAX_EDGE)
        val json = DocumentReaderSDK.locateDocument(locateBmp)
        val scaled = rescaleLocateJson(
          json,
          locateBmp.width,
          locateBmp.height,
          upright.width,
          upright.height
        )
        val ret = JSObject()
        ret.put("value", scaled)
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, "E_LOCATE", t)
      }
    }
  }

  @PluginMethod
  fun recognize(call: PluginCall) {
    val frontUri = call.getString("front")
    if (frontUri.isNullOrBlank()) {
      call.reject("front is required", "E_IMAGE")
      return
    }
    val backUri = call.getString("back")
    val authenticityMode =
      call.getString("authenticityMode")
        ?: if (call.getBoolean("authenticity", true) == false) "none" else "normal"
    executor.execute {
      try {
        val frontRaw = loadBitmap(frontUri)
          ?: run {
            call.reject("Could not decode front image: $frontUri", "E_IMAGE")
            return@execute
          }
        val front = uprightPortrait(frontRaw)
        val back: Bitmap? =
          if (backUri.isNullOrBlank()) {
            null
          } else {
            loadBitmap(backUri)?.let { uprightPortrait(it) }
          }
        DocumentReaderSDK.startNewSession("{\"scenario\":\"FullProcess\",\"series\":false}")
        val json = DocumentReaderSDK.recognize(front, back, authenticityMode)
        val ret = JSObject()
        ret.put("value", json ?: "")
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, "E_RECOGNIZE", t)
      }
    }
  }

  @PluginMethod
  fun documentRecognition(call: PluginCall) {
    processStill(call, livenessOnly = false)
  }

  @PluginMethod
  fun documentLiveness(call: PluginCall) {
    processStill(call, livenessOnly = true)
  }

  private fun processStill(call: PluginCall, livenessOnly: Boolean) {
    val frontUri = call.getString("front")
    if (frontUri.isNullOrBlank()) {
      call.reject("front is required", "E_IMAGE")
      return
    }
    val backUri = call.getString("back")
    executor.execute {
      try {
        val frontRaw = loadBitmap(frontUri)
          ?: run {
            call.reject("Could not decode front image: $frontUri", "E_IMAGE")
            return@execute
          }
        val front = uprightPortrait(frontRaw)
        val back: Bitmap? =
          if (backUri.isNullOrBlank()) {
            null
          } else {
            loadBitmap(backUri)?.let { uprightPortrait(it) }
          }
        DocumentReaderSDK.startNewSession("{\"scenario\":\"FullProcess\",\"series\":false}")
        val json =
          if (livenessOnly) DocumentReaderSDK.documentLiveness(front, back)
          else DocumentReaderSDK.documentRecognition(front, back)
        val ret = JSObject()
        ret.put("value", json ?: "")
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, if (livenessOnly) "E_LIVENESS" else "E_RECOGNITION", t)
      }
    }
  }

  @PluginMethod
  fun lastLicenseError(call: PluginCall) {
    try {
      val ret = JSObject()
      ret.put("value", DocumentReaderSDK.lastLicenseError() ?: "")
      call.resolve(ret)
    } catch (t: Throwable) {
      reject(call, "E_LICENSE_ERROR", t)
    }
  }

  @PluginMethod
  fun getLicenseStatus(call: PluginCall) {
    try {
      val ret = JSObject()
      ret.put("value", DocumentReaderSDK.getLicenseStatus() ?: "{}")
      call.resolve(ret)
    } catch (t: Throwable) {
      reject(call, "E_LICENSE_STATUS", t)
    }
  }

  @PluginMethod
  fun writeStatus(call: PluginCall) {
    val json = call.getString("payload") ?: "{}"
    try {
      val file = java.io.File(context.filesDir, "docreader_status.json")
      file.writeText(json)
      call.resolve()
    } catch (t: Throwable) {
      reject(call, "E_STATUS", t)
    }
  }

  @PluginMethod
  fun startLivePreview(call: PluginCall) {
    // Documents default to rear camera when frontCamera is omitted.
    val front = call.getBoolean("frontCamera", false) ?: false
    val activity = activity
    if (activity == null) {
      call.reject("No activity", "E_CAMERA")
      return
    }
    activity.runOnUiThread {
      try {
        attachPreviewHost()
        val previewView = previewView ?: run {
          call.reject("Preview view missing", "E_CAMERA")
          return@runOnUiThread
        }
        // Wait for layout so ViewPort matches the WebView / overlay size.
        previewView.post {
          bindCameraUseCases(front, call)
        }
      } catch (t: Throwable) {
        reject(call, "E_CAMERA", t)
      }
    }
  }

  private fun bindCameraUseCases(front: Boolean, call: PluginCall) {
    val activity = activity ?: run {
      call.reject("No activity", "E_CAMERA")
      return
    }
    val previewView = previewView ?: run {
      call.reject("Preview view missing", "E_CAMERA")
      return
    }
    val future = ProcessCameraProvider.getInstance(context)
    future.addListener({
      try {
        val provider = future.get()
        cameraProvider?.unbindAll()
        cameraProvider = provider
        syncPreviewHostToWebView()

        val preview = Preview.Builder()
          .setTargetAspectRatio(AspectRatio.RATIO_4_3)
          .build()
          .also { it.setSurfaceProvider(previewView.surfaceProvider) }

        val analysis = ImageAnalysis.Builder()
          .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
          .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
          .setTargetAspectRatio(AspectRatio.RATIO_4_3)
          .build()
        analysis.setAnalyzer(analysisExecutor) { image ->
          ingestAnalysisFrame(image)
        }

        val selector = if (front) {
          CameraSelector.DEFAULT_FRONT_CAMERA
        } else {
          CameraSelector.DEFAULT_BACK_CAMERA
        }

        // Shared ViewPort = Preview and Analysis crop identically (FILL_CENTER).
        val viewPort = previewView.viewPort
        if (viewPort != null) {
          val group = UseCaseGroup.Builder()
            .addUseCase(preview)
            .addUseCase(analysis)
            .setViewPort(viewPort)
            .build()
          provider.bindToLifecycle(activity as LifecycleOwner, selector, group)
        } else {
          provider.bindToLifecycle(
            activity as LifecycleOwner,
            selector,
            preview,
            analysis
          )
        }
        setWebViewTransparent(true)
        call.resolve()
      } catch (t: Throwable) {
        reject(call, "E_CAMERA", t)
      }
    }, ContextCompat.getMainExecutor(context))
  }

  @PluginMethod
  fun stopLivePreview(call: PluginCall) {
    val activity = activity
    if (activity == null) {
      cameraProvider = null
      call.resolve()
      return
    }
    activity.runOnUiThread {
      try {
        cameraProvider?.unbindAll()
        setWebViewTransparent(false)
        detachPreviewHost()
        call.resolve()
      } catch (t: Throwable) {
        reject(call, "E_CAMERA", t)
      }
    }
  }

  @PluginMethod
  fun takeLiveSnapshot(call: PluginCall) {
    executor.execute {
      try {
        val prepared = lastLiveBitmap ?: run {
          call.reject("Live preview is not running", "E_CAMERA")
          return@execute
        }
        val uri = writeLiveJpeg(prepared)
        val ret = JSObject()
        ret.put("uri", uri)
        ret.put("path", uri.removePrefix("file://"))
        call.resolve(ret)
      } catch (t: Throwable) {
        reject(call, "E_CAMERA", t)
      }
    }
  }

  /** Keep latest preview bitmap only — no document SDK frame ingest. */
  private fun ingestAnalysisFrame(image: androidx.camera.core.ImageProxy) {
    val now = SystemClock.elapsedRealtime()
    if (now - lastAnalysisMs < 120L || analysisBusy) {
      image.close()
      return
    }
    analysisBusy = true
    lastAnalysisMs = now
    try {
      val bitmap = ImageUtils.bitmapFromImageProxy(image) ?: return
      val prepared = applyLiveTransform(bitmap, 0f, 640)
      if (prepared !== bitmap && !bitmap.isRecycled) {
        bitmap.recycle()
      }
      lastLiveBitmap = prepared
    } catch (_: Throwable) {
      // Drop a bad preview frame.
    } finally {
      image.close()
      analysisBusy = false
    }
  }

  private fun attachPreviewHost() {
    val activity = activity ?: return
    val webView = bridge.webView ?: return
    val parent = webView.parent as? ViewGroup ?: return
    if (previewHost != null) {
      syncPreviewHostToWebView()
      return
    }
    val host = FrameLayout(activity)
    host.setBackgroundColor(Color.BLACK)
    val view = PreviewView(activity)
    view.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
    view.scaleType = PreviewView.ScaleType.FILL_CENTER
    host.addView(
      view,
      FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT
      )
    )
    // Match WebView frame so FILL_CENTER crop matches the HTML overlay.
    val lp = ViewGroup.MarginLayoutParams(
      if (webView.width > 0) webView.width else ViewGroup.LayoutParams.MATCH_PARENT,
      if (webView.height > 0) webView.height else ViewGroup.LayoutParams.MATCH_PARENT
    )
    lp.leftMargin = webView.left
    lp.topMargin = webView.top
    parent.addView(host, 0, lp)
    host.isClickable = false
    host.isFocusable = false
    view.isClickable = false
    webView.bringToFront()
    previewHost = host
    previewView = view
    webView.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ ->
      syncPreviewHostToWebView()
    }
  }

  private fun syncPreviewHostToWebView() {
    val webView = bridge.webView ?: return
    val host = previewHost ?: return
    val lp = host.layoutParams as? ViewGroup.MarginLayoutParams ?: return
    if (webView.width <= 0 || webView.height <= 0) return
    if (
      lp.width == webView.width &&
      lp.height == webView.height &&
      lp.leftMargin == webView.left &&
      lp.topMargin == webView.top
    ) {
      return
    }
    lp.width = webView.width
    lp.height = webView.height
    lp.leftMargin = webView.left
    lp.topMargin = webView.top
    host.layoutParams = lp
  }

  private fun detachPreviewHost() {
    val host = previewHost ?: return
    (host.parent as? ViewGroup)?.removeView(host)
    previewHost = null
    previewView = null
  }

  private fun setWebViewTransparent(transparent: Boolean) {
    val webView = bridge.webView ?: return
    webView.setBackgroundColor(if (transparent) Color.TRANSPARENT else Color.BLACK)
    webView.setLayerType(android.view.View.LAYER_TYPE_HARDWARE, null)
    webView.bringToFront()
  }

  private fun writeLiveJpeg(prepared: Bitmap): String {
    val file = File(context.cacheDir, "drs_live_${System.currentTimeMillis()}.jpg")
    file.outputStream().use { out ->
      prepared.compress(Bitmap.CompressFormat.JPEG, 85, out)
    }
    return "file://${file.absolutePath}"
  }

  private fun applyLiveTransform(src: Bitmap, rotateDegrees: Float, maxEdge: Int): Bitmap {
    var frame = src
    val deg = rotateDegrees % 360f
    if (kotlin.math.abs(deg) > 0.01f) {
      val matrix = Matrix().apply { postRotate(deg) }
      val rotated = Bitmap.createBitmap(frame, 0, 0, frame.width, frame.height, matrix, true)
      if (rotated !== frame && frame !== src) frame.recycle()
      frame = rotated
    }
    return scaleMax(frame, maxEdge)
  }

  private fun reject(call: PluginCall, code: String, t: Throwable) {
    val msg = t.message ?: code
    val ex = if (t is Exception) t else Exception(t)
    call.reject(msg, code, ex)
  }

  private fun loadBitmap(uriOrBase64: String): Bitmap? {
    return if (uriOrBase64.startsWith("data:") || looksLikeBase64(uriOrBase64)) {
      ImageUtils.bitmapFromBase64(uriOrBase64)
    } else {
      ImageUtils.bitmapFromUri(context.applicationContext, uriOrBase64)
    }
  }

  private fun looksLikeBase64(value: String): Boolean {
    return value.length > 256 && !value.contains("://") && !value.startsWith("/") && !value.startsWith("file:")
  }

  private fun uprightPortrait(src: Bitmap): Bitmap {
    if (src.width <= src.height) return src
    val matrix = Matrix().apply { postRotate(90f) }
    return Bitmap.createBitmap(src, 0, 0, src.width, src.height, matrix, true)
  }

  private fun scaleMax(src: Bitmap, maxEdge: Int): Bitmap {
    val longest = maxOf(src.width, src.height)
    if (longest <= maxEdge) return src
    val scale = maxEdge.toFloat() / longest
    return Bitmap.createScaledBitmap(
      src,
      (src.width * scale).toInt().coerceAtLeast(1),
      (src.height * scale).toInt().coerceAtLeast(1),
      true
    )
  }

  private fun rescaleLocateJson(
    json: String,
    locateW: Int,
    locateH: Int,
    imageW: Int,
    imageH: Int
  ): String {
    if (json.isEmpty()) return json
    return try {
      val root = org.json.JSONObject(json)
      root.put("_locateImageWidth", imageW)
      root.put("_locateImageHeight", imageH)
      val pos = root.optJSONObject("position") ?: return root.toString()
      val sx = imageW.toFloat() / locateW.coerceAtLeast(1)
      val sy = imageH.toFloat() / locateH.coerceAtLeast(1)
      val corners = pos.optJSONArray("corners")
      if (corners != null && corners.length() >= 4) {
        for (i in 0 until corners.length()) {
          val p = corners.optJSONObject(i) ?: continue
          p.put("x", p.optDouble("x") * sx)
          p.put("y", p.optDouble("y") * sy)
        }
      } else {
        if (pos.has("left")) pos.put("left", pos.optDouble("left") * sx)
        if (pos.has("top")) pos.put("top", pos.optDouble("top") * sy)
        if (pos.has("right")) pos.put("right", pos.optDouble("right") * sx)
        if (pos.has("bottom")) pos.put("bottom", pos.optDouble("bottom") * sy)
      }
      root.toString()
    } catch (_: Throwable) {
      json
    }
  }

  companion object {
    private const val LOCATE_MAX_EDGE = 480
  }
}
