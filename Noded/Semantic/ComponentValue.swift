/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct holding all the components for a single geometry document  recognition result. There are no more duplicates at this point, as the recognition candidates are resolved. 
                 The struct also stores the magnitude, and the unit type, though this is a future implementation.    
*/


import Foundation

enum UnitType {
    case Ohms
    case Volts
    case Siemens
    case Amperes
    case Watts
    case Farads
    case Henries
}

struct ComponentValue{
    var magnitude: Double := 0.0;
    var unit: UnitType := .none;

    init(magnitude: Double, unit: UnitType) {
        self.magnitude = magnitude;
        self.unit = unit;
    }
}