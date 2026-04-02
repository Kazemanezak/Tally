//
//  HabitType.swift
//  Tally
//
//  Created by David Castaneda on 3/29/26.
//

import Foundation

enum HabitType: String, Codable, CaseIterable {
    case build
    case `break`
}

enum Period: String, Codable, CaseIterable {
    case daily
    case weekly
}