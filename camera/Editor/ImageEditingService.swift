//
//  ImageEditingService.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Metal
import MetalPerformanceShaders
import UIKit

protocol ImageEditingServicing {
    func renderPreview(image: CIImage, recipe: EditRecipe) async -> CIImage
}

struct CoreImageEditingService: ImageEditingServicing {
    private let context: CIContext

    init() {
        if let device = MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: device)
        } else {
            context = CIContext(options: nil)
        }
    }

    func renderPreview(image: CIImage, recipe: EditRecipe) async -> CIImage {
        var working = image

        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = working
        colorControls.brightness = Float(recipe.core.brightness / 100)
        colorControls.contrast = Float(1 + recipe.core.contrast / 100)
        colorControls.saturation = Float(1 + recipe.core.saturation / 100)
        working = colorControls.outputImage ?? working

        let exposure = CIFilter.exposureAdjust()
        exposure.inputImage = working
        exposure.ev = Float(recipe.core.exposure)
        working = exposure.outputImage ?? working

        let temperature = CIFilter.temperatureAndTint()
        temperature.inputImage = working
        temperature.neutral = CIVector(x: 6_500 + recipe.core.temperature * 35, y: recipe.core.tint)
        temperature.targetNeutral = CIVector(x: 6_500, y: 0)
        working = temperature.outputImage ?? working

        if recipe.core.vignette != 0 {
            let vignette = CIFilter.vignette()
            vignette.inputImage = working
            vignette.intensity = Float(recipe.core.vignette / 50)
            vignette.radius = 1.6
            working = vignette.outputImage ?? working
        }

        if recipe.detail.sharpening > 0 {
            let sharpen = CIFilter.sharpenLuminance()
            sharpen.inputImage = working
            sharpen.sharpness = Float(recipe.detail.sharpening)
            working = sharpen.outputImage ?? working
        }

        return working
    }

    func makeUIImage(from image: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(image, from: image.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
