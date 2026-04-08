/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: An enum of all supported electrical component types. Each case is the key
    used to look up its ComponentTemplate in the static registry.
*/

import Foundation

enum ComponentType: String, Codable {
    case resistor
    case capacitor
    case inductor
    case voltageSource
    case currentSource
    case diode
    case transistor
    case ground
    case wire
    case opAmp
    case coupledInductor
    case magneticallyCoupledInductor
    case voltageControlledVoltageSource
    case currentControlledVoltageSource
    case voltageControlledCurrentSource
    case currentControlledCurrentSource
    case unknown
}
