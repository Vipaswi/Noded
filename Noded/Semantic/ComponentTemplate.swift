/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct defining the canonical geometry of a component type: its normalized
    bounding box and the relative positions of its terminals within that box. Acts as the
    source of truth for terminal layout. Never modified at runtime.
*/

import Foundation
import CoreGraphics

struct ComponentTemplate {
    let boundingBox: CGRect
    let terminalPositions: [Point2D]

    static let registry: [ComponentType: ComponentTemplate] = [:]
}
