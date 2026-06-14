//
//  AppTheme.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.04, green: 0.045, blue: 0.05)
    static let panel = Color.white.opacity(0.12)
    static let panelStrong = Color.white.opacity(0.18)
    static let primary = Color(red: 0.96, green: 0.98, blue: 1)
    static let muted = Color.white.opacity(0.68)
    static let accent = Color(red: 0.38, green: 0.78, blue: 1)
    static let warning = Color(red: 1, green: 0.78, blue: 0.32)
}

struct GlassPanel: ViewModifier {
    var cornerRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            }
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = 8) -> some View {
        modifier(GlassPanel(cornerRadius: cornerRadius))
    }
}

struct IconControlButton: View {
    let systemName: String
    let title: String
    var isActive = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 42, height: 42)
                .foregroundStyle(isActive ? .black : AppTheme.primary)
                .background(isActive ? AppTheme.warning : Color.white.opacity(0.12), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .help(title)
    }
}
