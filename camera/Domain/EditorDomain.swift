//
//  EditorDomain.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import Foundation
import CoreGraphics

struct EditingAdjustment: Equatable, Codable {
    var exposure: Double = 0
    var contrast: Double = 0
    var highlights: Double = 0
    var shadows: Double = 0
    var whites: Double = 0
    var blacks: Double = 0
    var brightness: Double = 0
    var saturation: Double = 0
    var vibrance: Double = 0
    var temperature: Double = 0
    var tint: Double = 0
    var clarity: Double = 0
    var texture: Double = 0
    var sharpness: Double = 0
    var noiseReduction: Double = 0
    var vignette: Double = 0
}

struct DetailAdjustment: Equatable, Codable {
    var sharpening: Double = 0.25
    var radius: Double = 1
    var detail: Double = 0.4
    var masking: Double = 0
    var luminanceReduction: Double = 0.2
    var colorNoiseReduction: Double = 0.2
}

struct CurvePoint: Equatable, Codable, Identifiable {
    var id = UUID()
    var x: Double
    var y: Double
}

struct ToneCurve: Equatable, Codable {
    var rgb: [CurvePoint] = [.init(x: 0, y: 0), .init(x: 1, y: 1)]
    var red: [CurvePoint] = [.init(x: 0, y: 0), .init(x: 1, y: 1)]
    var green: [CurvePoint] = [.init(x: 0, y: 0), .init(x: 1, y: 1)]
    var blue: [CurvePoint] = [.init(x: 0, y: 0), .init(x: 1, y: 1)]
}

enum LookCategory: String, CaseIterable, Identifiable, Codable {
    case natural = "Natural"
    case cinematic = "Cinematic"
    case portrait = "Portrait"
    case landscape = "Landscape"
    case urban = "Urban"
    case monochrome = "Mono"
    case film = "Film"

    var id: String { rawValue }
}

struct PhotoLook: Identifiable, Equatable, Codable {
    var id: String
    var name: String
    var category: LookCategory
    var intensity: Double
}

enum AITool: String, CaseIterable, Identifiable, Codable {
    case enhance = "Enhance"
    case sky = "Sky"
    case structure = "Structure"
    case relight = "Relight"
    case erase = "Erase"
    case foliage = "Foliage"
    case goldenHour = "Golden Hour"
    case dehaze = "Dehaze"

    var id: String { rawValue }
}

struct AIEditState: Equatable, Codable {
    var enhance: Double = 0
    var skyBlend: Double = 0
    var structure: Double = 0
    var relightIntensity: Double = 0
    var eraseBrushSize: Double = 24
    var foliageBoost: Double = 0
    var goldenHour: Double = 0
    var dehaze: Double = 0
}

struct CropState: Equatable, Codable {
    enum AspectRatio: String, CaseIterable, Identifiable, Codable {
        case freeform = "Free"
        case original = "Original"
        case square = "1:1"
        case fourFive = "4:5"
        case threeTwo = "3:2"
        case sixteenNine = "16:9"

        var id: String { rawValue }
    }

    var straighten: Double = 0
    var rotation: Double = 0
    var verticalCorrection: Double = 0
    var horizontalCorrection: Double = 0
    var aspectRatio: AspectRatio = .original
}

struct EditRecipe: Equatable, Codable {
    var core = EditingAdjustment()
    var detail = DetailAdjustment()
    var curve = ToneCurve()
    var ai = AIEditState()
    var crop = CropState()
    var selectedLook = PhotoLook(id: "balanced", name: "Balanced", category: .natural, intensity: 0)
}

enum ProfessionalLooks {
    static let all: [PhotoLook] = [
        .init(id: "balanced", name: "Balanced", category: .natural, intensity: 0.65),
        .init(id: "clean", name: "Clean", category: .natural, intensity: 0.55),
        .init(id: "soft", name: "Soft", category: .natural, intensity: 0.45),
        .init(id: "teal-orange", name: "Teal & Orange", category: .cinematic, intensity: 0.55),
        .init(id: "hollywood", name: "Hollywood", category: .cinematic, intensity: 0.6),
        .init(id: "drama", name: "Drama", category: .cinematic, intensity: 0.7),
        .init(id: "skin-soft", name: "Skin Soft", category: .portrait, intensity: 0.5),
        .init(id: "editorial", name: "Editorial", category: .portrait, intensity: 0.6),
        .init(id: "beauty", name: "Beauty", category: .portrait, intensity: 0.5),
        .init(id: "vivid-nature", name: "Vivid Nature", category: .landscape, intensity: 0.6),
        .init(id: "golden-hour", name: "Golden Hour", category: .landscape, intensity: 0.55),
        .init(id: "mountain-air", name: "Mountain Air", category: .landscape, intensity: 0.45),
        .init(id: "street", name: "Street", category: .urban, intensity: 0.55),
        .init(id: "neon", name: "Neon", category: .urban, intensity: 0.65),
        .init(id: "night-city", name: "Night City", category: .urban, intensity: 0.7),
        .init(id: "classic-mono", name: "Classic Mono", category: .monochrome, intensity: 0.65),
        .init(id: "high-contrast", name: "High Contrast", category: .monochrome, intensity: 0.7),
        .init(id: "fine-art", name: "Fine Art", category: .monochrome, intensity: 0.55),
        .init(id: "kodak-portra", name: "Kodak Portra", category: .film, intensity: 0.55),
        .init(id: "kodak-gold", name: "Kodak Gold", category: .film, intensity: 0.6),
        .init(id: "fuji-provia", name: "Fuji Provia", category: .film, intensity: 0.55),
        .init(id: "fuji-velvia", name: "Fuji Velvia", category: .film, intensity: 0.65),
        .init(id: "ilford-hp5", name: "Ilford HP5", category: .film, intensity: 0.6),
        .init(id: "cinestill", name: "CineStill", category: .film, intensity: 0.6)
    ]
}
