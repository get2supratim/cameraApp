//
//  EditorViewModel.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import Combine
import CoreImage
import SwiftUI

@MainActor
final class EditorViewModel: ObservableObject {
    enum Module: String, CaseIterable, Identifiable {
        case core = "Core"
        case curves = "Curves"
        case detail = "Detail"
        case looks = "Looks"
        case ai = "AI"
        case crop = "Crop"

        var id: String { rawValue }
    }

    @Published var recipe = EditRecipe()
    @Published var selectedModule: Module = .core
    @Published var selectedLookCategory: LookCategory = .natural
    @Published var undoStack: [EditRecipe] = []
    @Published var redoStack: [EditRecipe] = []
    @Published var isRendering = false
    @Published var renderStatus = "GPU preview ready"

    private let editorService: ImageEditingServicing
    private let aiService: AIEditingServicing

    init(editorService: ImageEditingServicing, aiService: AIEditingServicing) {
        self.editorService = editorService
        self.aiService = aiService
    }

    var visibleLooks: [PhotoLook] {
        ProfessionalLooks.all.filter { $0.category == selectedLookCategory }
    }

    func pushUndo() {
        undoStack.append(recipe)
        redoStack.removeAll()
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(recipe)
        recipe = previous
    }

    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(recipe)
        recipe = next
    }

    func applyLook(_ look: PhotoLook) {
        pushUndo()
        recipe.selectedLook = look
        recipe.core.contrast = 12 * look.intensity
        recipe.core.vibrance = 16 * look.intensity
        recipe.core.saturation = look.category == .monochrome ? -100 : 8 * look.intensity
        recipe.core.temperature = look.category == .landscape || look.id == "kodak-gold" ? 18 * look.intensity : recipe.core.temperature
    }

    func applyEnhanceAI(strength: Double) async {
        pushUndo()
        recipe = await aiService.enhance(recipe: recipe, strength: strength)
        renderStatus = "Enhance AI applied"
    }

    func applyRelightAI(intensity: Double) async {
        pushUndo()
        recipe = await aiService.relight(recipe: recipe, intensity: intensity)
        renderStatus = "Relight AI applied"
    }
}
