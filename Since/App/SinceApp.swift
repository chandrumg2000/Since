//
//  SinceApp.swift
//  Since
//
//  Main application entry point configuring SwiftData container, appearance,
//  and URL deep linking.
//

import SwiftUI
import SwiftData

@main
struct SinceApp: App {
    @State private var environment = AppEnvironment.shared
    @State private var userSettings = UserSettings.shared
    @Environment(\.scenePhase) private var scenePhase
    
    private let persistenceService = PersistenceService.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(userSettings.appearance.colorScheme)
                .onOpenURL { url in
                    environment.handleDeepLink(url: url)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // Refresh notifications and widgets when returning to foreground
                    }
                }
        }
        .modelContainer(persistenceService.container)
    }
}
