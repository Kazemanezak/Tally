//
//  TallyApp.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import SwiftUI
import SwiftData

@main
struct TallyApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Habit.self, HabitLog.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    DemoData.seedIfNeeded(modelContext: container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
