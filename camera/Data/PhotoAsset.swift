//
//  PhotoAsset.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import Foundation
import SwiftData

@Model
final class PhotoAsset {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var localIdentifier: String?
    var captureFormatRawValue: String
    var isFavorite: Bool
    var isRAW: Bool
    var isProRAW: Bool
    var hasAIEdit: Bool
    var cameraName: String
    var lensName: String
    var albumName: String?
    var editRecipeData: Data?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        localIdentifier: String? = nil,
        captureFormat: CaptureFormat = .heif,
        isFavorite: Bool = false,
        isRAW: Bool = false,
        isProRAW: Bool = false,
        hasAIEdit: Bool = false,
        cameraName: String = "iPhone",
        lensName: String = "Wide",
        albumName: String? = nil,
        editRecipe: EditRecipe = EditRecipe()
    ) {
        self.id = id
        self.createdAt = createdAt
        self.localIdentifier = localIdentifier
        self.captureFormatRawValue = captureFormat.rawValue
        self.isFavorite = isFavorite
        self.isRAW = isRAW
        self.isProRAW = isProRAW
        self.hasAIEdit = hasAIEdit
        self.cameraName = cameraName
        self.lensName = lensName
        self.albumName = albumName
        self.editRecipeData = try? JSONEncoder().encode(editRecipe)
    }

    var captureFormat: CaptureFormat {
        get { CaptureFormat(rawValue: captureFormatRawValue) ?? .heif }
        set { captureFormatRawValue = newValue.rawValue }
    }

    var editRecipe: EditRecipe {
        get {
            guard let editRecipeData,
                  let recipe = try? JSONDecoder().decode(EditRecipe.self, from: editRecipeData) else {
                return EditRecipe()
            }
            return recipe
        }
        set {
            editRecipeData = try? JSONEncoder().encode(newValue)
            hasAIEdit = newValue.ai != AIEditState()
        }
    }
}

enum CameraAppModelContainer {
    static let schema = Schema([PhotoAsset.self])

    @MainActor
    static let preview: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.insert(PhotoAsset(captureFormat: .proRAW, isRAW: true, isProRAW: true, hasAIEdit: true, lensName: "48mm Main", albumName: "Portfolio"))
        container.mainContext.insert(PhotoAsset(captureFormat: .raw, isRAW: true, lensName: "Ultra Wide", albumName: "Travel"))
        container.mainContext.insert(PhotoAsset(captureFormat: .heif, lensName: "Telephoto", albumName: "Portraits"))
        return container
    }()
}
