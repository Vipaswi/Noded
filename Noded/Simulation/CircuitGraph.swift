/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A class representing the complete electrical topology of a canvas.
    Built incrementally as the user snaps terminals. Consumed by SpiceExporter.
    Contains no geometry, no recognition scores, no UI state.
*/

import Foundation

class CircuitGraph: Codable {
    var nodes: [UUID: Node] = [:]
    var edges: [UUID: Edge] = [:]

    init() {}

    func connect(terminalA: UUID, terminalB: UUID) {}

    var subGraphs: [SubGraph] {
        return []
    }
}
