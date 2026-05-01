//
//  SpeakPlanApp.swift
//  SpeakPlan
//

import SwiftUI

@main
struct SpeakPlanApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// NOTE: SwiftData / ModelContainer removed because the app currently uses
// Codable + UserDefaults for persistence (see TaskViewModel).
// When you're ready to migrate to SwiftData, re-add:
//
//   .modelContainer(for: Task.self)
//
// and update TaskViewModel to use @Query.

