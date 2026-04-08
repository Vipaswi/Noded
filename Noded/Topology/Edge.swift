/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct representing a component's presence in the circuit graph.
    Stores the component UUID and the two node UUIDs that its terminals are connected to.
    An edge is a component, not a wire.
*/

import Foundation

struct Edge: Codable, Identifiable {
    let id: UUID
    let componentID: UUID
    let nodeA: UUID
    let nodeB: UUID

    init(id: UUID = UUID(), componentID: UUID, nodeA: UUID, nodeB: UUID) {
        self.id = id
        self.componentID = componentID
        self.nodeA = nodeA
        self.nodeB = nodeB
    }
}
