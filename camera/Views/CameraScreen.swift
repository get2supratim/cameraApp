//
//  CameraScreen.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import SwiftData
import SwiftUI

struct CameraScreen: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel: CameraViewModel
    @State private var wheelValue = 0.25

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CameraPreviewView(session: viewModel.session)
                    .overlay(PreviewFallback())
                    .ignoresSafeArea()

                OverlayLayer(manualState: viewModel.manualState)

                VStack(spacing: 0) {
                    CameraTopBar(viewModel: viewModel)
                        .padding(.horizontal, 14)
                        .padding(.top, 8)

                    Spacer()

                    if viewModel.advancedControlsVisible {
                        QuickAccessDock(viewModel: viewModel)
                            .padding(.bottom, 12)
                    }

                    ThumbControlZone(viewModel: viewModel, wheelValue: $wheelValue)
                        .frame(height: proxy.size.height * 0.35)
                }
            }
            .foregroundStyle(AppTheme.primary)
            .task { await viewModel.start() }
            .onDisappear { viewModel.stop() }
            .gesture(cameraGestures)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Professional Camera")
        }
    }

    private var cameraGestures: some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { _ in viewModel.toggleExposureLock() }
            .simultaneously(with: DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.height < -30 {
                        withAnimation(.snappy) { viewModel.advancedControlsVisible = true }
                    } else if value.translation.height > 30 {
                        withAnimation(.snappy) { viewModel.advancedControlsVisible = false }
                    } else if abs(value.translation.width) > 60 {
                        switchControl(direction: value.translation.width > 0 ? 1 : -1)
                    }
                })
    }

    private func switchControl(direction: Int) {
        let controls = ManualControl.allCases
        guard let index = controls.firstIndex(of: viewModel.selectedControl) else { return }
        let next = (index + direction + controls.count) % controls.count
        viewModel.setControl(controls[next])
    }
}

private struct PreviewFallback: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.07, blue: 0.08),
                Color(red: 0.14, green: 0.18, blue: 0.18),
                Color(red: 0.03, green: 0.04, blue: 0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            VStack(spacing: 10) {
                Image(systemName: "camera.aperture")
                    .font(.system(size: 56, weight: .light))
                Text("Welcome to Camera App")
                    .font(.title2.weight(.semibold))
                Text("Manual capture workspace")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .allowsHitTesting(false)
        .opacity(0.92)
    }
}

private struct CameraTopBar: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        HStack(spacing: 10) {
            StatusChip(icon: "battery.75percent", text: "86%")
            StatusChip(icon: "internaldrive", text: "128G")
            Spacer()
            IconControlButton(systemName: viewModel.flashEnabled ? "bolt.fill" : "bolt.slash", title: "Flash", isActive: viewModel.flashEnabled) {
                viewModel.flashEnabled.toggle()
            }
            IconControlButton(systemName: viewModel.livePhotoEnabled ? "livephoto" : "livephoto.slash", title: "Live Photo", isActive: viewModel.livePhotoEnabled) {
                viewModel.livePhotoEnabled.toggle()
            }
            Menu {
                ForEach(CaptureFormat.allCases) { format in
                    Button(format.rawValue) { viewModel.format = format }
                }
            } label: {
                Text(viewModel.format.rawValue)
                    .font(.caption.weight(.bold))
                    .frame(width: 58, height: 36)
                    .background(viewModel.format == .raw || viewModel.format == .proRAW ? AppTheme.warning : Color.white.opacity(0.12), in: Capsule())
                    .foregroundStyle(viewModel.format == .raw || viewModel.format == .proRAW ? .black : AppTheme.primary)
            }
            .accessibilityLabel("Capture format")
            IconControlButton(systemName: "gearshape", title: "Settings") {}
        }
    }
}

private struct StatusChip: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .labelStyle(.titleAndIcon)
            .padding(.horizontal, 9)
            .frame(height: 34)
            .glassPanel(cornerRadius: 8)
    }
}

private struct QuickAccessDock: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ManualControl.allCases.prefix(4)) { control in
                IconControlButton(systemName: control.icon, title: control.rawValue, isActive: viewModel.selectedControl == control) {
                    viewModel.setControl(control)
                }
            }
            IconControlButton(systemName: "chart.bar.xaxis", title: "Histogram", isActive: viewModel.manualState.histogramMode != .hidden) {
                viewModel.manualState.histogramMode = viewModel.manualState.histogramMode == .hidden ? .rgb : .hidden
            }
            IconControlButton(systemName: "grid", title: "Grid", isActive: viewModel.manualState.gridOverlay != .none) {
                viewModel.manualState.gridOverlay = viewModel.manualState.gridOverlay == .none ? .thirds : .none
            }
            IconControlButton(systemName: "sparkles", title: "AI Tools", isActive: false) {}
        }
        .padding(8)
        .glassPanel(cornerRadius: 8)
    }
}

private struct ThumbControlZone: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: CameraViewModel
    @Binding var wheelValue: Double

    var body: some View {
        VStack(spacing: 14) {
            Picker("Capture mode", selection: $viewModel.mode) {
                ForEach(CaptureMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Capture mode")

            ManualDial(control: viewModel.selectedControl, value: $wheelValue) {
                viewModel.updateSelectedControl(value: wheelValue)
            }

            HStack(alignment: .center, spacing: 18) {
                Button {
                    viewModel.toggleFocusLock()
                } label: {
                    Image(systemName: viewModel.manualState.focusLocked ? "lock.fill" : "scope")
                        .font(.title3.weight(.semibold))
                        .frame(width: 54, height: 54)
                        .glassPanel(cornerRadius: 8)
                }
                .accessibilityLabel("Focus lock")

                Button {
                    Task { await viewModel.capture(context: modelContext) }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 78, height: 78)
                        Circle()
                            .fill(viewModel.isCapturing ? AppTheme.warning : Color.white)
                            .frame(width: 62, height: 62)
                    }
                }
                .accessibilityLabel("Capture photo")

                Button {
                    viewModel.toggleExposureLock()
                } label: {
                    Image(systemName: viewModel.manualState.exposureLocked ? "lock.circle.fill" : "plusminus.circle")
                        .font(.title3.weight(.semibold))
                        .frame(width: 54, height: 54)
                        .glassPanel(cornerRadius: 8)
                }
                .accessibilityLabel("Exposure lock")
            }

            Text(viewModel.statusMessage)
                .font(.footnote.weight(.medium))
                .foregroundStyle(AppTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .background(.ultraThinMaterial)
    }
}

private struct ManualDial: View {
    let control: ManualControl
    @Binding var value: Double
    var onChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(control.rawValue, systemImage: control.icon)
                    .font(.headline)
                Spacer()
                Text(readout)
                    .font(.system(.headline, design: .monospaced))
                    .foregroundStyle(AppTheme.warning)
            }

            Slider(value: $value, in: 0...1) {
                Text(control.rawValue)
            }
            .onChange(of: value) { _, _ in onChanged() }
            .tint(AppTheme.warning)
        }
        .padding(12)
        .glassPanel(cornerRadius: 8)
    }

    private var readout: String {
        switch control {
        case .iso: "ISO \(Int(50 + value * 3_150))"
        case .shutter: "\(String(format: "%.0f", max(1, 1 / max(1 / 8000, value * 2))))"
        case .focus: "\(Int(value * 100))%"
        case .whiteBalance: "\(Int(2_000 + value * 8_000))K"
        case .zoom: "\(String(format: "%.1f", 1 + value * 14))x"
        case .exposure: "\(String(format: "%+.1f", -3 + value * 6))EV"
        }
    }
}

private struct OverlayLayer: View {
    let manualState: ManualCameraState

    var body: some View {
        ZStack {
            GridOverlayView(kind: manualState.gridOverlay, opacity: manualState.gridOpacity)
            if manualState.histogramMode != .hidden {
                HistogramOverlay(mode: manualState.histogramMode)
                    .frame(width: manualState.histogramMode == .expanded ? 260 : 142, height: manualState.histogramMode == .expanded ? 118 : 72)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 68)
                    .padding(.trailing, 16)
            }
            if manualState.focusPeakingEnabled {
                FocusPeakingOverlay(color: manualState.peakingColor.color, intensity: manualState.peakingIntensity)
            }
            HorizonGuide()
        }
        .allowsHitTesting(false)
    }
}

private struct GridOverlayView: View {
    let kind: GridOverlay
    let opacity: Double

    var body: some View {
        Canvas { context, size in
            guard kind != .none else { return }
            var path = Path()
            let columns = kind == .square ? 4 : 3
            let rows = kind == .square ? 4 : 3
            for index in 1..<columns {
                let x = size.width * CGFloat(index) / CGFloat(columns)
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for index in 1..<rows {
                let y = size.height * CGFloat(index) / CGFloat(rows)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            if kind == .triangle {
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.move(to: CGPoint(x: size.width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size.height))
            }
            context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: 1)
        }
    }
}

private struct HistogramOverlay: View {
    let mode: HistogramMode

    var body: some View {
        Canvas { context, size in
            let bars = 26
            for index in 0..<bars {
                let x = size.width * CGFloat(index) / CGFloat(bars)
                let height = size.height * CGFloat((sin(Double(index) * 0.62) + 1.25) / 2.4)
                let rect = CGRect(x: x, y: size.height - height, width: size.width / CGFloat(bars) - 2, height: height)
                let color: Color = mode == .rgb ? [Color.red, Color.green, Color.blue][index % 3].opacity(0.72) : Color.white.opacity(0.72)
                context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(color))
            }
        }
        .padding(8)
        .glassPanel(cornerRadius: 8)
    }
}

private struct FocusPeakingOverlay: View {
    let color: Color
    let intensity: Double

    var body: some View {
        Canvas { context, size in
            for index in 0..<28 {
                let x = CGFloat((index * 61) % 331) / 331 * size.width
                let y = CGFloat((index * 97) % 503) / 503 * size.height
                let rect = CGRect(x: x, y: y, width: 34, height: 2)
                context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(color.opacity(0.18 + intensity * 0.45)))
            }
        }
        .blendMode(.screen)
    }
}

private struct HorizonGuide: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.warning.opacity(0.72))
            .frame(width: 96, height: 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
