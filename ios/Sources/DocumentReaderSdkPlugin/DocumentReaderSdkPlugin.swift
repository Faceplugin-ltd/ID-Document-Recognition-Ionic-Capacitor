import Foundation
import Capacitor
import AVFoundation
import UIKit
import CoreImage
import CoreVideo

@objc(DocumentReaderSdkPlugin)
public class DocumentReaderSdkPlugin: CAPPlugin, CAPBridgedPlugin, AVCaptureVideoDataOutputSampleBufferDelegate {
  public let identifier = "DocumentReaderSdkPlugin"
  public let jsName = "DocumentReaderSdk"
  public let pluginMethods: [CAPPluginMethod] = [
    CAPPluginMethod(name: "getMachineCode", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "setActivation", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "init", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "deinit", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "startNewSession", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "locateDocument", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "recognize", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "documentRecognition", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "documentLiveness", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "lastLicenseError", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "getLicenseStatus", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "writeStatus", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "startLivePreview", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "stopLivePreview", returnType: CAPPluginReturnPromise),
    CAPPluginMethod(name: "takeLiveSnapshot", returnType: CAPPluginReturnPromise),
  ]

  private var captureSession: AVCaptureSession?
  private var previewContainer: UIView?
  private var previewLayer: AVCaptureVideoPreviewLayer?
  private var videoOutput: AVCaptureVideoDataOutput?
  private var boundsObserver: NSKeyValueObservation?
  private let videoQueue = DispatchQueue(label: "com.documentreadersdk.camera")
  private let frameLock = NSLock()
  private let ciContext = CIContext(options: nil)
  private var lastFrameTime: CFTimeInterval = 0
  private var capturing = false
  private var usingFrontCamera = false
  private var originalWebViewOpaque: Bool?
  private var lastLiveImage: UIImage?

  @objc func getMachineCode(_ call: CAPPluginCall) {
    guard DocSdkBridge.isAvailable() else {
      call.reject(
        "docsdk.framework not linked. Drop frameworks into ios/Frameworks/.",
        "E_SDK"
      )
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let mc = DocSdkBridge.getMachineCode()
      call.resolve(["value": mc])
    }
  }

  @objc func setActivation(_ call: CAPPluginCall) {
    guard let license = call.getString("license"), !license.isEmpty else {
      call.reject("license is required", "E_ACTIVATION")
      return
    }
    guard DocSdkBridge.isAvailable() else {
      call.reject("docsdk.framework not linked", "E_SDK")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let code = DocSdkBridge.setActivation(license)
      call.resolve(["value": code])
    }
  }

  @objc func `init`(_ call: CAPPluginCall) {
    guard DocSdkBridge.isAvailable() else {
      call.reject("docsdk.framework not linked", "E_SDK")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let code = DocSdkBridge.initSDK()
      call.resolve(["value": code])
    }
  }

  @objc(deinit:) func deinitSdk(_ call: CAPPluginCall) {
    guard DocSdkBridge.isAvailable() else {
      call.reject("docsdk.framework not linked", "E_SDK")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      DocSdkBridge.deinitSDK()
      call.resolve()
    }
  }

  @objc func startNewSession(_ call: CAPPluginCall) {
    let optionsJson = call.getString("optionsJson")
    guard DocSdkBridge.isAvailable() else {
      call.reject("docsdk.framework not linked", "E_SDK")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let json = DocSdkBridge.startNewSession(optionsJson)
      call.resolve(["value": json])
    }
  }

  @objc func locateDocument(_ call: CAPPluginCall) {
    guard let image = call.getString("image"), !image.isEmpty else {
      call.reject("image is required", "E_IMAGE")
      return
    }
    guard DocSdkBridge.isAvailable() else {
      call.reject("docsdk.framework not linked", "E_SDK")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let json = try DocSdkBridge.locateDocument(image)
        call.resolve(["value": json])
      } catch {
        call.reject(error.localizedDescription, "E_LOCATE", error)
      }
    }
  }

  @objc func recognize(_ call: CAPPluginCall) {
    guard let front = call.getString("front"), !front.isEmpty else {
      call.reject("front is required", "E_IMAGE")
      return
    }
    let back = call.getString("back")
    let authenticityMode = call.getString("authenticityMode")
      ?? ((call.getBool("authenticity") ?? true) ? "normal" : "none")
    guard DocSdkBridge.isAvailable() else {
      call.reject("docsdk.framework not linked", "E_SDK")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let json = try DocSdkBridge.recognizeFront(
          front,
          back: back,
          authenticityMode: authenticityMode
        )
        call.resolve(["value": json])
      } catch {
        call.reject(error.localizedDescription, "E_RECOGNIZE", error)
      }
    }
  }

  @objc func documentRecognition(_ call: CAPPluginCall) {
    processStill(call, livenessOnly: false)
  }

  @objc func documentLiveness(_ call: CAPPluginCall) {
    processStill(call, livenessOnly: true)
  }

  private func processStill(_ call: CAPPluginCall, livenessOnly: Bool) {
    guard let front = call.getString("front"), !front.isEmpty else {
      call.reject("front is required", "E_IMAGE")
      return
    }
    let back = call.getString("back")
    guard DocSdkBridge.isAvailable() else {
      call.reject("docsdk.framework not linked", "E_SDK")
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let json = try DocSdkBridge.processStill(
          front,
          back: back,
          livenessOnly: livenessOnly
        )
        call.resolve(["value": json])
      } catch {
        call.reject(
          error.localizedDescription,
          livenessOnly ? "E_LIVENESS" : "E_RECOGNITION",
          error
        )
      }
    }
  }

  @objc func lastLicenseError(_ call: CAPPluginCall) {
    call.resolve(["value": DocSdkBridge.lastLicenseError()])
  }

  @objc func getLicenseStatus(_ call: CAPPluginCall) {
    call.resolve(["value": DocSdkBridge.getLicenseStatus()])
  }

  @objc func writeStatus(_ call: CAPPluginCall) {
    let payload = call.getString("payload") ?? "{}"
    DocSdkBridge.writeStatusRaw(payload)
    call.resolve()
  }

  @objc func startLivePreview(_ call: CAPPluginCall) {
    // Documents default to rear camera when frontCamera is omitted.
    let front = call.getBool("frontCamera") ?? false
    DispatchQueue.main.async {
      self.stopSession()
      self.usingFrontCamera = front
      let session = AVCaptureSession()
      // 4:3 matches typical analysis frames and FILL_CENTER overlay math.
      session.sessionPreset = .photo
      let position: AVCaptureDevice.Position = front ? .front : .back
      guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
        ?? AVCaptureDevice.default(for: .video) else {
        call.reject("No camera", "E_CAMERA")
        return
      }
      do {
        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
          session.addInput(input)
        }
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
          kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.setSampleBufferDelegate(self, queue: self.videoQueue)
        if session.canAddOutput(output) {
          session.addOutput(output)
        }
        if let conn = output.connection(with: .video) {
          if conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
          }
          if conn.isVideoMirroringSupported {
            conn.isVideoMirrored = false
          }
        }
        self.videoOutput = output
        self.captureSession = session
        guard self.attachPreview(session: session, front: front) else {
          self.stopSession()
          call.reject("Could not attach camera preview", "E_CAMERA")
          return
        }
        self.setWebViewTransparent(true)
        DispatchQueue.global(qos: .userInitiated).async {
          session.startRunning()
          DispatchQueue.main.async {
            self.layoutPreview()
            self.applyPreviewConnection()
          }
          call.resolve()
        }
      } catch {
        call.reject(error.localizedDescription, "E_CAMERA", error)
      }
    }
  }

  @objc func stopLivePreview(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
      self.stopSession()
      call.resolve()
    }
  }

  @objc func takeLiveSnapshot(_ call: CAPPluginCall) {
    DispatchQueue.global(qos: .userInitiated).async {
      self.frameLock.lock()
      let image = self.lastLiveImage
      self.frameLock.unlock()
      guard let image = image else {
        call.reject("Live preview is not running", "E_CAMERA")
        return
      }
      guard let uri = self.writeLiveJpeg(image) else {
        call.reject("Could not write snapshot", "E_CAMERA")
        return
      }
      call.resolve([
        "uri": uri,
        "path": uri.replacingOccurrences(of: "file://", with: ""),
      ])
    }
  }

  public func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    let now = CACurrentMediaTime()
    if now - lastFrameTime < 0.12 || capturing {
      return
    }
    lastFrameTime = now
    capturing = true
    defer { capturing = false }
    guard let image = imageFromSampleBuffer(sampleBuffer) else { return }
    let prepared = scaleMax(image, maxEdge: 640)
    frameLock.lock()
    lastLiveImage = prepared
    frameLock.unlock()
  }

  private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
  }

  private func scaleMax(_ image: UIImage, maxEdge: CGFloat) -> UIImage {
    let size = image.size
    let edge = max(size.width, size.height)
    if edge <= maxEdge || edge <= 0 {
      return image
    }
    let scale = maxEdge / edge
    let target = CGSize(width: max(1, floor(size.width * scale)), height: max(1, floor(size.height * scale)))
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1
    format.opaque = true
    let renderer = UIGraphicsImageRenderer(size: target, format: format)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: target))
    }
  }

  private func writeLiveJpeg(_ image: UIImage) -> String? {
    guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
    let name = "drs_live_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
    do {
      try data.write(to: url, options: .atomic)
      return url.absoluteString
    } catch {
      return nil
    }
  }

  private func attachPreview(session: AVCaptureSession, front: Bool) -> Bool {
    guard let webView = self.webView else { return false }
    guard let host = webView.superview ?? self.bridge?.viewController?.view else {
      return false
    }
    // Pin to the WebView frame (not the full host) so FILL_CENTER crop matches
    // the HTML overlay inside the Capacitor WebView.
    let frame = webView.frame.isEmpty ? host.bounds : webView.frame
    let container = UIView(frame: frame)
    container.isUserInteractionEnabled = false
    container.backgroundColor = .black
    container.clipsToBounds = true

    let layer = AVCaptureVideoPreviewLayer(session: session)
    layer.videoGravity = .resizeAspectFill
    layer.frame = container.bounds
    if let conn = layer.connection {
      if conn.isVideoOrientationSupported {
        conn.videoOrientation = .portrait
      }
      if conn.isVideoMirroringSupported {
        conn.automaticallyAdjustsVideoMirroring = false
        conn.isVideoMirrored = front
      }
    }
    container.layer.addSublayer(layer)
    previewLayer = layer
    previewContainer = container

    if let idx = host.subviews.firstIndex(of: webView) {
      host.insertSubview(container, at: idx)
    } else {
      host.insertSubview(container, at: 0)
    }
    host.bringSubviewToFront(webView)

    boundsObserver?.invalidate()
    boundsObserver = webView.observe(\.frame, options: [.new, .initial]) { [weak self] view, _ in
      guard let self = self else { return }
      self.previewContainer?.frame = view.frame
      self.layoutPreview()
    }
    layoutPreview()
    return true
  }

  private func layoutPreview() {
    guard let container = previewContainer else { return }
    if let webView = webView, !webView.frame.isEmpty {
      container.frame = webView.frame
    }
    previewLayer?.frame = container.bounds
    applyPreviewConnection()
  }

  private func applyPreviewConnection() {
    guard let conn = previewLayer?.connection else { return }
    if conn.isVideoOrientationSupported {
      conn.videoOrientation = .portrait
    }
    if conn.isVideoMirroringSupported {
      conn.automaticallyAdjustsVideoMirroring = false
      conn.isVideoMirrored = usingFrontCamera
    }
  }

  private func setWebViewTransparent(_ transparent: Bool) {
    guard let webView = webView else { return }
    if originalWebViewOpaque == nil {
      originalWebViewOpaque = webView.isOpaque
    }
    webView.isOpaque = !transparent && (originalWebViewOpaque ?? true)
    webView.backgroundColor = transparent ? .clear : nil
    webView.scrollView.isOpaque = !transparent
    webView.scrollView.backgroundColor = transparent ? .clear : nil
    webView.scrollView.subviews.forEach { sub in
      if transparent {
        sub.backgroundColor = .clear
      }
    }
  }

  private func stopSession() {
    boundsObserver?.invalidate()
    boundsObserver = nil
    captureSession?.stopRunning()
    captureSession = nil
    videoOutput?.setSampleBufferDelegate(nil, queue: nil)
    videoOutput = nil
    previewLayer?.removeFromSuperlayer()
    previewLayer = nil
    previewContainer?.removeFromSuperview()
    previewContainer = nil
    setWebViewTransparent(false)
  }
}
