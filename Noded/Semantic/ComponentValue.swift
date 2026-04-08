/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct representing the electrical parameter of a component — resistance,
    capacitance, voltage, etc. Stores a magnitude and a unit type.
*/

import Foundation

enum UnitType: String, Codable {
    case ohms
    case volts
    case siemens
    case amperes
    case watts
    case farads
    case henries
    case none
}

struct ComponentValue: Codable {
    var magnitude: Double = 0.0
    var unit: UnitType = .none

    init(magnitude: Double = 0.0, unit: UnitType = .none) {
        self.magnitude = magnitude
        self.unit = unit
    }
}
