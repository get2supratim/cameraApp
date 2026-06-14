//
//  CameraViewModel.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import Foundation
import AVFoundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var mode: CaptureMode = .photo
    @Published var format: CaptureFormat = .heif
    @Published var manualState = ManualCameraState()
    @Published var selectedControl: ManualControl = .iso
    @Published var advancedControlsVisible = true
    @Published var livePhotoEnabled = false
    @Published var flashEnabled = false
    @Published var levelIndicatorEnabled = true
    @Published var statusMessage = "Welcome to Camera App"
    @Published var lastCapture: CaptureResult?
    @Published var isCapturing = false

    private let cameraService: CameraServicing
    private let repository: PhotoRepository

    init(cameraService: CameraServicing, repository: PhotoRepository) {
        self.cameraService = cameraService
        self.repository = repository
    }

    var capabilities: CameraCapabilities {
        cameraService.capabilities
    }

    var session: AVCaptureSession {
        cameraService.session
    }

    func start() async {
        let granted = await cameraService.requestAccess()
        guard granted else {
            statusMessage = "Camera access needed"
            return
        }
        await cameraService.configure()
        cameraService.start()
        statusMessage = "Ready"
    }

    func stop() {
        cameraService.stop()
    }

    func setControl(_ control: ManualControl) {
        selectedControl = control
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func updateSelectedControl(value: Double) {
        switch selectedControl {
        case .iso:
            manualState.iso = 50 + value * 3_150
        case .shutter:
            manualState.shutterSpeed = max(1 / 8_000, value * 2)
        case .focus:
            manualState.focus = value
        case .whiteBalance:
            manualState.kelvin = 2_000 + value * 8_000
        case .zoom:
            manualState.zoom = 1 + value * 14
        case .exposure:
            manualState.exposureCompensation = -3 + value * 6
        }
        cameraService.apply(manualState: manualState)
    }

    func capture(context: ModelContext) async {
        guard !isCapturing else { return }
        isCapturing = true
        defer { isCapturing = false }

        do {
            let request = CaptureRequest(mode: mode, format: format, manualState: manualState)
            let result = try await cameraService.capturePhoto(request: request)
            lastCapture = result
            repository.saveCapture(result, in: context)
            statusMessage = "\(format.rawValue) captured"
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            statusMessage = "Capture failed"
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    func toggleExposureLock() {
        manualState.exposureLocked.toggle()
        statusMessage = manualState.exposureLocked ? "EV locked" : "EV unlocked"
    }

    func toggleFocusLock() {
        manualState.focusLocked.toggle()
        statusMessage = manualState.focusLocked ? "Focus locked" : "Focus unlocked"
    }
}
