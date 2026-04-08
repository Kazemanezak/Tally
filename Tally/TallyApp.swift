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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, HabitLog.self])
    }
}
