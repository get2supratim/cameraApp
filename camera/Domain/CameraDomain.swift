//
//  CameraDomain.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import Foundation
import SwiftUI

enum CaptureMode: String, CaseIterable, Identifiable, Codable {
    case photo = "Photo"
    case portrait = "Portrait"
    case night = "Night"
    case macro = "Macro"
    case panorama = "Pano"
    case burst = "Burst"

    var id: String { rawValue }
}

enum CaptureFormat: String, CaseIterable, Identifiable, Codable {
    case jpeg = "JPEG"
    case heif = "HEIF"
    case raw = "RAW"
    case proRAW = "ProRAW"

    var id: String { rawValue }
}

enum ManualControl: String, CaseIterable, Identifiable, Codable {
    case iso = "ISO"
    case shutter = "Shutter"
    case focus = "Focus"
    case whiteBalance = "WB"
    case zoom = "Zoom"
    case exposure = "EV"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .iso: "sensor"
        case .shutter: "timer"
        case .focus: "scope"
        case .whiteBalance: "thermometer.sun"
        case .zoom: "plus.magnifyingglass"
        case .exposure: "plusminus.circle"
        }
    }
}

enum WhiteBalancePreset: String, CaseIterable, Identifiable, Codable {
    case auto = "Auto"
    case daylight = "Daylight"
    case cloudy = "Cloudy"
    case shade = "Shade"
    case tungsten = "Tungsten"
    case fluorescent = "Fluorescent"
    case flash = "Flash"

    var id: String { rawValue }
}

enum HistogramMode: String, CaseIterable, Identifiable, Codable {
    case hidden = "Hidden"
    case luminance = "Luma"
    case rgb = "RGB"
    case expanded = "Expanded"

    var id: String { rawValue }
}

enum GridOverlay: String, CaseIterable, Identifiable, Codable {
    case none = "Off"
    case thirds = "Thirds"
    case goldenRatio = "Golden"
    case goldenSpiral = "Spiral"
    case triangle = "Triangle"
    case square = "Square"
    case custom = "Custom"

    var id: String { rawValue }
}

enum PeakingColor: String, CaseIterable, Identifiable, Codable {
    case red = "Red"
    case blue = "Blue"
    case yellow = "Yellow"
    case green = "Green"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .red: .red
        case .blue: .blue
        case .yellow: .yellow
        case .green: .green
        }
    }
}

struct ManualCameraState: Equatable, Codable {
    var iso: Double = 100
    var shutterSpeed: Double = 1 / 120
    var exposureCompensation: Double = 0
    var exposureLocked = false
    var bracketingEnabled = false
    var focus: Double = 0.5
    var focusLocked = false
    var rackFocusEnabled = false
    var focusPeakingEnabled = true
    var peakingIntensity: Double = 0.65
    var peakingColor: PeakingColor = .yellow
    var kelvin: Double = 5_200
    var tint: Double = 0
    var whiteBalancePreset: WhiteBalancePreset = .auto
    var zoom: Double = 1
    var histogramMode: HistogramMode = .rgb
    var gridOverlay: GridOverlay = .thirds
    var gridOpacity: Double = 0.32
}

struct CameraCapabilities: Equatable {
    var supportsRAW = false
    var supportsProRAW = false
    var supportsDepth = false
    var supportsLivePhoto = false
    var supportsMacroSwitching = false
    var supportsManualExposure = false
}

struct CaptureRequest: Equatable {
    var mode: CaptureMode
    var format: CaptureFormat
    var manualState: ManualCameraState
}

struct CaptureResult: Equatable, Identifiable {
    let id = UUID()
    var createdAt: Date
    var format: CaptureFormat
    var localIdentifier: String?
    var isRAW: Bool
    var isAIEnhanced: Bool
}
