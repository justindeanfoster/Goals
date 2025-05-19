//
//  GoalsApp.swift
//  Goals
//
//  Created by Justin F on 12/24/24.
//

import SwiftUI
import SwiftData

@main
struct GoalsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Goal.self, Habit.self, JournalEntry.self, Milestone.self])
        }
    }
}
