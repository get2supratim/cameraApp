//
//  RootTabView.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import SwiftUI

struct RootTabView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            CameraScreen(viewModel: CameraViewModel(cameraService: container.cameraService, repository: container.photoRepository))
                .tabItem {
                    Label("Camera", systemImage: "camera.aperture")
                }

            PhotoLibraryScreen(repository: container.photoRepository)
                .tabItem {
                    Label("Library", systemImage: "photo.on.rectangle")
                }

            EditorScreen(viewModel: EditorViewModel(editorService: container.editorService, aiService: container.aiService))
                .tabItem {
                    Label("Editor", systemImage: "slider.horizontal.3")
                }
        }
        .tint(AppTheme.accent)
    }
}
