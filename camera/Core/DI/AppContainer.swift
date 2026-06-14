//
//  AppContainer.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import Foundation
import Combine

@MainActor
final class AppContainer: ObservableObject {
    let cameraService: CameraServicing
    let editorService: ImageEditingServicing
    let aiService: AIEditingServicing
    let photoRepository: PhotoRepository

    init(
        cameraService: CameraServicing,
        editorService: ImageEditingServicing,
        aiService: AIEditingServicing,
        photoRepository: PhotoRepository
    ) {
        self.cameraService = cameraService
        self.editorService = editorService
        self.aiService = aiService
        self.photoRepository = photoRepository
    }

    static let live = AppContainer(
        cameraService: CameraService(),
        editorService: CoreImageEditingService(),
        aiService: VisionAIEditingService(),
        photoRepository: SwiftDataPhotoRepository()
    )

    static let preview = AppContainer(
        cameraService: PreviewCameraService(),
        editorService: CoreImageEditingService(),
        aiService: VisionAIEditingService(),
        photoRepository: SwiftDataPhotoRepository()
    )
}
