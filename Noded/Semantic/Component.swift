/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A class representing a resolved interpretation of one or more strokes in a geometry document. Contains a UUID,
    component type, component value, and geometry ids referencing the source strokes. It is created externally.
*/

enum ComponentType {
    case Resistor
    case Capacitor
    case Inductor
    case VoltageSource
    case CurrentSource
    case Diode
    case Transistor
    case Ground
    case Wire
    case OpAmp
    case coupledInductor
    case magneticallyCoupledInductor
    case voltageControlledVoltageSource
    case currentControlledVoltageSource
    case voltageControlledCurrentSource
    case currentControlledCurrentSource
    case none
}

struct Component {
    var id: UUID := UUID();
    var type: ComponentType := .none;
    var value: ComponentValue := ComponentValue(magnitude: 0.0, unit: .none);
    var geometryIds: [UUID] := [];

    init(id: UUID = UUID(), type: String, value: ComponentValue, geometryIds: [UUID]) {
        self.id = id;
        self.type = type;
        self.value = value;
        self.geometryIds = geometryIds;
    }
}