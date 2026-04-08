/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct representing the resolved semantic interpretation of one or more strokes.
    Contains a component type, terminals, electrical value, references to source geometry,
    and the affine transform mapping template space to canvas space.
*/

import Foundation

struct Component: Codable, Identifiable {
    let id: UUID
    var type: ComponentType
    var terminals: [Terminal]
    var value: ComponentValue
    var geometryIDs: [UUID]
    var transform: AffineTransform

    init(
        id: UUID = UUID(),
        type: ComponentType,
        terminals: [Terminal] = [],
        value: ComponentValue = ComponentValue(),
        geometryIDs: [UUID] = [],
        transform: AffineTransform = AffineTransform()
    ) {
        self.id = id
        self.type = type
        self.terminals = terminals
        self.value = value
        self.geometryIDs = geometryIDs
        self.transform = transform
    }
}
