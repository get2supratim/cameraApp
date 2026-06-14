//
//  EditorScreen.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import SwiftUI

struct EditorScreen: View {
    @StateObject var viewModel: EditorViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                EditorPreview(recipe: viewModel.recipe)

                Picker("Editor module", selection: $viewModel.selectedModule) {
                    ForEach(EditorViewModel.Module.allCases) { module in
                        Text(module.rawValue).tag(module)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)

                moduleContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Pro Editor")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        viewModel.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .disabled(viewModel.undoStack.isEmpty)
                    .accessibilityLabel("Undo")

                    Button {
                        viewModel.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                    }
                    .disabled(viewModel.redoStack.isEmpty)
                    .accessibilityLabel("Redo")
                }
            }
        }
    }

    @ViewBuilder
    private var moduleContent: some View {
        switch viewModel.selectedModule {
        case .core:
            CoreAdjustmentPanel(recipe: $viewModel.recipe) { viewModel.pushUndo() }
        case .curves:
            CurvesPanel(recipe: $viewModel.recipe)
        case .detail:
            DetailPanel(recipe: $viewModel.recipe) { viewModel.pushUndo() }
        case .looks:
            LooksPanel(viewModel: viewModel)
        case .ai:
            AIToolsPanel(viewModel: viewModel)
        case .crop:
            CropPanel(recipe: $viewModel.recipe) { viewModel.pushUndo() }
        }
    }
}

private struct EditorPreview: View {
    let recipe: EditRecipe

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.08 + recipe.core.exposure * 0.03, green: 0.12, blue: 0.16),
                    Color(red: 0.26, green: 0.32 + recipe.core.vibrance * 0.002, blue: 0.30),
                    Color(red: 0.08, green: 0.06, blue: 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 76, weight: .light))
                    .foregroundStyle(.white.opacity(0.35))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.selectedLook.name)
                    .font(.headline)
                Text("Non-destructive RAW recipe")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .foregroundStyle(.white)
            .padding(14)
        }
        .frame(height: 280)
        .clipShape(Rectangle())
        .accessibilityLabel("Image preview")
    }
}

private struct CoreAdjustmentPanel: View {
    @Binding var recipe: EditRecipe
    let beginEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                AdjustmentSlider(title: "Exposure", value: $recipe.core.exposure, range: -3...3, beginEdit: beginEdit)
                AdjustmentSlider(title: "Contrast", value: $recipe.core.contrast, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Highlights", value: $recipe.core.highlights, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Shadows", value: $recipe.core.shadows, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Whites", value: $recipe.core.whites, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Blacks", value: $recipe.core.blacks, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Saturation", value: $recipe.core.saturation, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Vibrance", value: $recipe.core.vibrance, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Temperature", value: $recipe.core.temperature, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Tint", value: $recipe.core.tint, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Clarity", value: $recipe.core.clarity, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Texture", value: $recipe.core.texture, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Vignette", value: $recipe.core.vignette, range: -100...100, beginEdit: beginEdit)
            }
            .padding()
        }
    }
}

private struct DetailPanel: View {
    @Binding var recipe: EditRecipe
    let beginEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                AdjustmentSlider(title: "Sharpening", value: $recipe.detail.sharpening, range: 0...2, beginEdit: beginEdit)
                AdjustmentSlider(title: "Radius", value: $recipe.detail.radius, range: 0.2...3, beginEdit: beginEdit)
                AdjustmentSlider(title: "Detail", value: $recipe.detail.detail, range: 0...1, beginEdit: beginEdit)
                AdjustmentSlider(title: "Masking", value: $recipe.detail.masking, range: 0...1, beginEdit: beginEdit)
                AdjustmentSlider(title: "Noise Reduction", value: $recipe.core.noiseReduction, range: 0...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Luminance NR", value: $recipe.detail.luminanceReduction, range: 0...1, beginEdit: beginEdit)
                AdjustmentSlider(title: "Color NR", value: $recipe.detail.colorNoiseReduction, range: 0...1, beginEdit: beginEdit)
            }
            .padding()
        }
    }
}

private struct CurvesPanel: View {
    @Binding var recipe: EditRecipe

    var body: some View {
        VStack(spacing: 16) {
            Canvas { context, size in
                var grid = Path()
                for step in 1..<4 {
                    let value = CGFloat(step) / 4
                    grid.move(to: CGPoint(x: size.width * value, y: 0))
                    grid.addLine(to: CGPoint(x: size.width * value, y: size.height))
                    grid.move(to: CGPoint(x: 0, y: size.height * value))
                    grid.addLine(to: CGPoint(x: size.width, y: size.height * value))
                }
                context.stroke(grid, with: .color(.secondary.opacity(0.35)), lineWidth: 1)

                var curve = Path()
                curve.move(to: CGPoint(x: 0, y: size.height))
                curve.addCurve(to: CGPoint(x: size.width, y: 0), control1: CGPoint(x: size.width * 0.32, y: size.height * 0.68), control2: CGPoint(x: size.width * 0.68, y: size.height * 0.28))
                context.stroke(curve, with: .color(AppTheme.accent), lineWidth: 3)
            }
            .frame(height: 240)
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 8))

            Text("RGB tone curve with histogram overlay")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

private struct LooksPanel: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 12) {
            Picker("Look category", selection: $viewModel.selectedLookCategory) {
                ForEach(LookCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 12)], spacing: 12) {
                    ForEach(viewModel.visibleLooks) { look in
                        Button {
                            viewModel.applyLook(look)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(lookGradient(look))
                                    .frame(height: 82)
                                Text(look.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("\(Int(look.intensity * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .background(.background, in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }

    private func lookGradient(_ look: PhotoLook) -> LinearGradient {
        let colors: [Color]
        switch look.category {
        case .natural: colors = [.mint, .cyan]
        case .cinematic: colors = [.teal, .orange]
        case .portrait: colors = [.pink, .indigo]
        case .landscape: colors = [.green, .yellow]
        case .urban: colors = [.purple, .blue]
        case .monochrome: colors = [.gray, .black]
        case .film: colors = [.yellow, .red]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private struct AIToolsPanel: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                AIToolRow(tool: .enhance, detail: "Balanced exposure, color, contrast") {
                    Task { await viewModel.applyEnhanceAI(strength: 0.7) }
                }
                AIToolRow(tool: .sky, detail: "Sky segmentation and replacement controls") {
                    viewModel.pushUndo()
                    viewModel.recipe.ai.skyBlend = 0.55
                }
                AIToolRow(tool: .structure, detail: "Texture without harsh halos") {
                    viewModel.pushUndo()
                    viewModel.recipe.ai.structure = 0.6
                    viewModel.recipe.core.texture = 24
                }
                AIToolRow(tool: .relight, detail: "Virtual foreground/background lighting") {
                    Task { await viewModel.applyRelightAI(intensity: 0.65) }
                }
                AIToolRow(tool: .erase, detail: "Content-aware removal brush") {
                    viewModel.pushUndo()
                    viewModel.recipe.ai.eraseBrushSize = 34
                }
                AIToolRow(tool: .foliage, detail: "Vegetation-aware green boost") {
                    viewModel.pushUndo()
                    viewModel.recipe.ai.foliageBoost = 0.65
                }
                AIToolRow(tool: .goldenHour, detail: "Warm highlights and soft shadow lift") {
                    viewModel.pushUndo()
                    viewModel.recipe.ai.goldenHour = 0.7
                    viewModel.recipe.core.temperature = 32
                }
                AIToolRow(tool: .dehaze, detail: "Atmospheric contrast recovery") {
                    viewModel.pushUndo()
                    viewModel.recipe.ai.dehaze = 0.55
                    viewModel.recipe.core.contrast = 18
                }
            }
            .padding()
        }
    }
}

private struct CropPanel: View {
    @Binding var recipe: EditRecipe
    let beginEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Picker("Aspect Ratio", selection: $recipe.crop.aspectRatio) {
                    ForEach(CropState.AspectRatio.allCases) { ratio in
                        Text(ratio.rawValue).tag(ratio)
                    }
                }
                .pickerStyle(.segmented)

                AdjustmentSlider(title: "Straighten", value: $recipe.crop.straighten, range: -45...45, beginEdit: beginEdit)
                AdjustmentSlider(title: "Rotate", value: $recipe.crop.rotation, range: -180...180, beginEdit: beginEdit)
                AdjustmentSlider(title: "Vertical", value: $recipe.crop.verticalCorrection, range: -100...100, beginEdit: beginEdit)
                AdjustmentSlider(title: "Horizontal", value: $recipe.crop.horizontalCorrection, range: -100...100, beginEdit: beginEdit)
            }
            .padding()
        }
    }
}

private struct AIToolRow: View {
    let tool: AITool
    let detail: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.accent.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.rawValue)
                        .font(.headline)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.background, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct AdjustmentSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let beginEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(value, format: .number.precision(.fractionLength(1)))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range) {
                Text(title)
            } onEditingChanged: { editing in
                if editing { beginEdit() }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}
