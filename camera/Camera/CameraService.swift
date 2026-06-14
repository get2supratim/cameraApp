//
//  CameraService.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

@preconcurrency import AVFoundation
import Foundation
import Photos
import UIKit

protocol CameraServicing: AnyObject {
    var session: AVCaptureSession { get }
    var capabilities: CameraCapabilities { get }
    var authorizationStatus: AVAuthorizationStatus { get }
    func requestAccess() async -> Bool
    func configure() async
    func start()
    func stop()
    func apply(manualState: ManualCameraState)
    func capturePhoto(request: CaptureRequest) async throws -> CaptureResult
}

enum CameraError: Error {
    case notAuthorized
    case unavailable
}

final class CameraService: NSObject, CameraServicing {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "camera.session.queue", qos: .userInitiated)
    private var activeDevice: AVCaptureDevice?

    private(set) var capabilities = CameraCapabilities()

    var authorizationStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func configure() async {
        let isAuthorized = authorizationStatus == .authorized
        let hasAccess = isAuthorized ? true : await requestAccess()
        guard hasAccess else { return }

        #if targetEnvironment(simulator)
        return
        #else
        queue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            defer { self.session.commitConfiguration() }

            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }

            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: .back
            )
            guard let device = discovery.devices.first,
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input),
                  self.session.canAddOutput(self.output) else { return }

            self.activeDevice = device
            self.session.addInput(input)
            self.session.addOutput(self.output)
            self.output.maxPhotoQualityPrioritization = .quality
            self.updateCapabilities(for: device)
        }
        #endif
    }

    func start() {
        queue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func apply(manualState: ManualCameraState) {
        #if targetEnvironment(simulator)
        return
        #else
        queue.async { [weak self] in
            guard let device = self?.activeDevice else { return }
            do {
                try device.lockForConfiguration()
                if device.isExposureModeSupported(.custom) {
                    let duration = CMTime(seconds: manualState.shutterSpeed, preferredTimescale: 1_000_000_000)
                    let iso = Float(min(max(manualState.iso, Double(device.activeFormat.minISO)), Double(device.activeFormat.maxISO)))
                    device.setExposureModeCustom(duration: duration, iso: iso)
                }
                if device.isFocusModeSupported(.locked) {
                    device.setFocusModeLocked(lensPosition: Float(manualState.focus))
                }
                if device.isWhiteBalanceModeSupported(.locked) {
                    let gains = device.deviceWhiteBalanceGains(for: AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(
                        temperature: Float(manualState.kelvin),
                        tint: Float(manualState.tint)
                    ))
                    device.setWhiteBalanceModeLocked(with: gains)
                }
                device.videoZoomFactor = min(max(manualState.zoom, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
                device.unlockForConfiguration()
            } catch {
                device.unlockForConfiguration()
            }
        }
        #endif
    }

    func capturePhoto(request: CaptureRequest) async throws -> CaptureResult {
        guard authorizationStatus == .authorized else { throw CameraError.notAuthorized }

        #if targetEnvironment(simulator)
        return CaptureResult(createdAt: .now, format: request.format, localIdentifier: nil, isRAW: request.format == .raw || request.format == .proRAW, isAIEnhanced: false)
        #else
        return try await withCheckedThrowingContinuation { continuation in
            let settings = AVCapturePhotoSettings()
            settings.photoQualityPrioritization = .quality
            if output.availablePhotoCodecTypes.contains(.hevc), request.format == .heif {
                settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            }
            let delegate = PhotoCaptureDelegate(request: request, continuation: continuation)
            output.capturePhoto(with: settings, delegate: delegate)
            PhotoCaptureDelegateStore.shared.retain(delegate)
        }
        #endif
    }

    private func updateCapabilities(for device: AVCaptureDevice) {
        capabilities = CameraCapabilities(
            supportsRAW: !output.availableRawPhotoPixelFormatTypes.isEmpty,
            supportsProRAW: output.isAppleProRAWSupported,
            supportsDepth: output.isDepthDataDeliverySupported,
            supportsLivePhoto: output.isLivePhotoCaptureSupported,
            supportsMacroSwitching: device.deviceType == .builtInTripleCamera || device.deviceType == .builtInDualWideCamera,
            supportsManualExposure: device.isExposureModeSupported(.custom)
        )
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let request: CaptureRequest
    let continuation: CheckedContinuation<CaptureResult, Error>

    init(request: CaptureRequest, continuation: CheckedContinuation<CaptureResult, Error>) {
        self.request = request
        self.continuation = continuation
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer { PhotoCaptureDelegateStore.shared.release(self) }
        if let error {
            continuation.resume(throwing: error)
        } else {
            continuation.resume(returning: CaptureResult(
                createdAt: .now,
                format: request.format,
                localIdentifier: nil,
                isRAW: request.format == .raw || request.format == .proRAW,
                isAIEnhanced: false
            ))
        }
    }
}

private final class PhotoCaptureDelegateStore: @unchecked Sendable {
    static let shared = PhotoCaptureDelegateStore()
    private var delegates: [ObjectIdentifier: PhotoCaptureDelegate] = [:]
    private let lock = NSLock()

    func retain(_ delegate: PhotoCaptureDelegate) {
        lock.lock()
        delegates[ObjectIdentifier(delegate)] = delegate
        lock.unlock()
    }

    func release(_ delegate: PhotoCaptureDelegate) {
        lock.lock()
        delegates.removeValue(forKey: ObjectIdentifier(delegate))
        lock.unlock()
    }
}

final class PreviewCameraService: CameraServicing {
    let session = AVCaptureSession()
    let capabilities = CameraCapabilities(supportsRAW: true, supportsProRAW: true, supportsDepth: true, supportsLivePhoto: true, supportsMacroSwitching: true, supportsManualExposure: true)
    let authorizationStatus: AVAuthorizationStatus = .authorized

    func requestAccess() async -> Bool { true }
    func configure() async {}
    func start() {}
    func stop() {}
    func apply(manualState: ManualCameraState) {}

    func capturePhoto(request: CaptureRequest) async throws -> CaptureResult {
        CaptureResult(createdAt: .now, format: request.format, localIdentifier: nil, isRAW: request.format == .raw || request.format == .proRAW, isAIEnhanced: false)
    }
}
