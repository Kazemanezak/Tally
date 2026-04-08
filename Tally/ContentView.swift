//
//  ContentView.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .preferredColorScheme(.dark)
    }
}
