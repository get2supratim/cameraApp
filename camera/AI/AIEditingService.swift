//
//  AIEditingService.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import CoreImage
import CoreML
import Vision

protocol AIEditingServicing {
    func enhance(recipe: EditRecipe, strength: Double) async -> EditRecipe
    func detectSky(in image: CIImage) async -> CGRect?
    func relight(recipe: EditRecipe, intensity: Double) async -> EditRecipe
}

struct VisionAIEditingService: AIEditingServicing {
    func enhance(recipe: EditRecipe, strength: Double) async -> EditRecipe {
        var recipe = recipe
        recipe.ai.enhance = strength
        recipe.core.exposure = 0.18 * strength
        recipe.core.highlights = -18 * strength
        recipe.core.shadows = 22 * strength
        recipe.core.contrast = 8 * strength
        recipe.core.vibrance = 18 * strength
        return recipe
    }

    func detectSky(in image: CIImage) async -> CGRect? {
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(ciImage: image)
        try? handler.perform([request])
        return request.results?.first?.salientObjects?.first?.boundingBox
    }

    func relight(recipe: EditRecipe, intensity: Double) async -> EditRecipe {
        var recipe = recipe
        recipe.ai.relightIntensity = intensity
        recipe.core.shadows += 18 * intensity
        recipe.core.temperature += 8 * intensity
        return recipe
    }
}
