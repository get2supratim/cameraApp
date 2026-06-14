//
//  cameraApp.swift
//  camera
//
//  Created by Supratim Mandal on 6/13/26.
//

import SwiftUI
import SwiftData

@main
struct cameraApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = CameraAppModelContainer.schema
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppContainer.live)
        }
        .modelContainer(sharedModelContainer)
    }
}
