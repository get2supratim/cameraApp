//
//  PhotoRepository.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import Foundation
import SwiftData

protocol PhotoRepository {
    func seedIfNeeded(in context: ModelContext)
    func saveCapture(_ result: CaptureResult, in context: ModelContext)
}

struct SwiftDataPhotoRepository: PhotoRepository {
    func seedIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<PhotoAsset>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        context.insert(PhotoAsset(captureFormat: .proRAW, isRAW: true, isProRAW: true, hasAIEdit: true, lensName: "48mm Main", albumName: "Portfolio"))
        context.insert(PhotoAsset(captureFormat: .raw, isRAW: true, lensName: "24mm Wide", albumName: "RAW"))
        context.insert(PhotoAsset(captureFormat: .heif, lensName: "77mm Telephoto", albumName: "Portraits"))
    }

    func saveCapture(_ result: CaptureResult, in context: ModelContext) {
        let asset = PhotoAsset(
            createdAt: result.createdAt,
            localIdentifier: result.localIdentifier,
            captureFormat: result.format,
            isRAW: result.isRAW,
            isProRAW: result.format == .proRAW,
            hasAIEdit: result.isAIEnhanced
        )
        context.insert(asset)
    }
}
