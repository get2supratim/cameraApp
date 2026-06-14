//
//  PhotoLibraryScreen.swift
//  camera
//
//  Created by Codex on 6/13/26.
//

import SwiftData
import SwiftUI

struct PhotoLibraryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PhotoAsset.createdAt, order: .reverse) private var assets: [PhotoAsset]
    let repository: PhotoRepository
    @State private var searchText = ""
    @State private var selectedAlbum = "All"

    var filteredAssets: [PhotoAsset] {
        assets.filter { asset in
            let albumMatches = selectedAlbum == "All" || asset.albumName == selectedAlbum
            let searchMatches = searchText.isEmpty
            || asset.cameraName.localizedCaseInsensitiveContains(searchText)
            || asset.lensName.localizedCaseInsensitiveContains(searchText)
            || (asset.albumName?.localizedCaseInsensitiveContains(searchText) ?? false)
            return albumMatches && searchMatches
        }
    }

    var albums: [String] {
        ["All"] + Array(Set(assets.compactMap(\.albumName))).sorted()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Album", selection: $selectedAlbum) {
                    ForEach(albums, id: \.self) { album in
                        Text(album).tag(album)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 10)], spacing: 10) {
                        ForEach(filteredAssets) { asset in
                            PhotoAssetTile(asset: asset)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 18)
                }
            }
            .navigationTitle("Library")
            .searchable(text: $searchText, prompt: "Camera, lens, date, subject")
            .task {
                repository.seedIfNeeded(in: modelContext)
            }
        }
    }
}

private struct PhotoAssetTile: View {
    let asset: PhotoAsset

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(tileGradient)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "camera.aperture")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.36))
                    }
                HStack(spacing: 4) {
                    if asset.isRAW {
                        Badge(text: asset.isProRAW ? "ProRAW" : "RAW")
                    }
                    if asset.hasAIEdit {
                        Badge(text: "AI")
                    }
                }
                .padding(6)
            }

            Text(asset.lensName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            Text(asset.createdAt, format: .dateTime.month().day().hour().minute())
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(asset.captureFormat.rawValue) photo from \(asset.lensName)")
    }

    private var tileGradient: LinearGradient {
        LinearGradient(
            colors: asset.isProRAW ? [.orange, .purple] : asset.isRAW ? [.cyan, .indigo] : [.mint, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct Badge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(AppTheme.warning, in: Capsule())
    }
}
