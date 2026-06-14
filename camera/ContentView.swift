//
//  ContentView.swift
//  camera
//
//  Created by Supratim Mandal on 6/13/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        RootTabView(container: container)
    }
}
