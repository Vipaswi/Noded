/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct representing a named connection point on a component.
    Terminal positions are computed from the component's template and affine transform —
    never inferred from strokes. Must not reference Node directly.
*/

import Foundation

struct Terminal: Codable, Identifiable {
    let id: UUID
    let label: String
    let position: Point2D

    init(id: UUID = UUID(), label: String, position: Point2D) {
        self.id = id
        self.label = label
        self.position = position
    }
}
