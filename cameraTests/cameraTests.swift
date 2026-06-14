//
//  cameraTests.swift
//  cameraTests
//
//  Created by Supratim Mandal on 6/13/26.
//

import Testing
@testable import camera

struct cameraTests {

    @Test func professionalLooksIncludeRequiredCategories() async throws {
        let categories = Set(ProfessionalLooks.all.map(\.category))
        #expect(categories.contains(.natural))
        #expect(categories.contains(.cinematic))
        #expect(categories.contains(.portrait))
        #expect(categories.contains(.landscape))
        #expect(categories.contains(.urban))
        #expect(categories.contains(.film))
    }

    @Test func enhanceAIProducesNonDestructiveRecipeChanges() async throws {
        let service = VisionAIEditingService()
        let original = EditRecipe()
        let enhanced = await service.enhance(recipe: original, strength: 0.75)

        #expect(original.core.exposure == 0)
        #expect(enhanced.ai.enhance == 0.75)
        #expect(enhanced.core.shadows > original.core.shadows)
        #expect(enhanced.core.highlights < original.core.highlights)
    }

    @Test func photoAssetRoundTripsEditRecipe() async throws {
        var recipe = EditRecipe()
        recipe.core.exposure = 1.25
        recipe.ai.structure = 0.5

        let asset = PhotoAsset(editRecipe: recipe)
        #expect(asset.editRecipe.core.exposure == 1.25)
        #expect(asset.hasAIEdit)
    }
}
